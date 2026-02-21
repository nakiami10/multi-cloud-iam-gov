# --- 1. PROVIDERS ---

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

terraform {
  # --- OPTION A: AWS S3 (Recommended if AWS is your primary hub) ---
  # Requires: S3 Bucket (versioning enabled) and DynamoDB Table (LockID primary key)
  
  /*
  backend "s3" {
    bucket         = "org-terraform-state-prod"
    key            = "iam-governance/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
  */

  # --- OPTION B: Azure Blob Storage (Recommended if Azure is your primary hub) ---
  # Requires: Storage Account and Container
  
  
  backend "azurerm" {
    resource_group_name  = "rg-governance-prod"
    storage_account_name = "stiamgovernanceprod"
    container_name       = "tfstate"
    key                  = "iam.terraform.tfstate"
  }
  
}

# --- 2. AWS COMPOSITION ENGINE (Environment Aware) ---

locals {
  # Load Shared Components
  aws_component_files = fileset("${path.module}/aws_policies/components", "*.json")
  aws_shared_statements = flatten([
    for f in local.aws_component_files : 
    jsondecode(file("${path.module}/aws_policies/components/${f}")).Statement
  ])
  
  aws_l1_raw = jsondecode(file("${path.module}/aws_policies/devops-external-l1.json")).Statement
  aws_team_files = fileset("${path.module}/aws_policies", "*.json")
  
  # Logic: If var.enable_strict_governance is false (Non-Prod), 
  # we skip the restricted components to give teams leeway.
  aws_final_policies = {
    for f in local.aws_team_files :
    replace(f, ".json", "") => {
      Version = "2012-10-17"
      Statement = f == "devops-internal.json" ? (
        jsondecode(file("${path.module}/aws_policies/${f}")).Statement 
      ) : (var.enable_strict_governance ? (
          # PROD / STRICT MODE: Merge all shared components + inheritance
          concat(
            local.aws_shared_statements,
            f == "devops-external-l2.json" ? local.aws_l1_raw : [],
            jsondecode(file("${path.module}/aws_policies/${f}")).Statement
          )
        ) : (
          # NON-PROD / LEEWAY: Only team-specific logic (skipping restrictive components)
          jsondecode(file("${path.module}/aws_policies/${f}")).Statement
        )
      )
    }
  }
}

resource "aws_iam_policy" "composed" {
  for_each = local.aws_final_policies
  name     = "iam-composed-${each.key}-${var.environment}"
  path     = "/org-managed/"
  policy   = jsonencode(each.value)
}

# --- 3. AZURE COMPOSITION & ASSIGNMENT (The Leeway Logic) ---

locals {
  az_role_files = fileset("${path.module}/azure_roles", "*.yaml")
  az_component_files = fileset("${path.module}/azure_roles/components", "*.yaml")

  az_component_actions = distinct(flatten([
    for f in local.az_component_files :
    lookup(yamldecode(file("${path.module}/azure_roles/components/${f}")), "actions", [])
  ]))

  az_component_not_actions = distinct(flatten([
    for f in local.az_component_files :
    lookup(yamldecode(file("${path.module}/azure_roles/components/${f}")), "notActions", [])
  ]))

  az_roles_raw = {
    for f in local.az_role_files :
    replace(f, ".yaml", "") => yamldecode(file("${path.module}/azure_roles/${f}"))
  }

  az_l1_actions = lookup(local.az_roles_raw["devops-external-l1"], "actions", [])
  az_l1_not_actions = lookup(local.az_roles_raw["devops-external-l1"], "notActions", [])

  az_roles_composed = {
    for role_key, role in local.az_roles_raw :
    role_key => merge(role, {
      actions = distinct(concat(
        local.az_component_actions,
        role_key == "devops-external-l2" ? local.az_l1_actions : [],
        lookup(role, "actions", [])
      ))
      notActions = distinct(concat(
        local.az_component_not_actions,
        role_key == "devops-external-l2" ? local.az_l1_not_actions : [],
        lookup(role, "notActions", [])
      ))
    })
  }
  
  # Multi-line concat for all assignable scopes
  all_azure_subs = concat(
    var.prod_subscription_ids, 
    var.nonprod_subscription_ids
  )
}

# 3a. Create Custom Role Definitions (Strict)
resource "azurerm_role_definition" "teams" {
  for_each = local.az_roles_composed
  
  name  = "Custom-${each.value.name}"
  scope = "/subscriptions/${local.all_azure_subs[0]}"

  permissions {
    actions     = each.value.actions
    not_actions = lookup(each.value, "notActions", [])
  }

  assignable_scopes = [for id in local.all_azure_subs : "/subscriptions/${id}"]
}

# 3b. PROD ASSIGNMENTS: Assign Custom Strict Roles
resource "azurerm_role_assignment" "prod_strict" {
  for_each = {
    for mapping in var.azure_team_principals : "${mapping.team}-${mapping.subscription_id}" => mapping
    if contains(var.prod_subscription_ids, mapping.subscription_id)
  }

  scope              = "/subscriptions/${each.value.subscription_id}"
  role_definition_id = azurerm_role_definition.teams[each.value.team].id
  principal_id       = each.value.principal_id
}

# 3c. NON-PROD ASSIGNMENTS: Assign Built-in "Contributor" for Leeway
resource "azurerm_role_assignment" "nonprod_leeway" {
  for_each = {
    for mapping in var.azure_team_principals : "${mapping.team}-${mapping.subscription_id}" => mapping
    if contains(var.nonprod_subscription_ids, mapping.subscription_id)
  }

  scope                = "/subscriptions/${each.value.subscription_id}"
  role_definition_name = "Contributor" # Built-in role grants full write/delete leeway
  principal_id         = each.value.principal_id
}