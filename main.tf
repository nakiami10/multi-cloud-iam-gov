# --- 1. PROVIDERS ---

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

# --- 2. AWS COMPOSITION ENGINE (Environment Aware) ---

locals {
  # Load Shared Components
  aws_component_files = fileset("${path.module}/aws_policies/components", "*.json")
  aws_shared_statements = flatten([
    for f in local.aws_component_files : 
    jsondecode(file("${path.module}/aws_policies/components/${f}")).Statement
  ])
  
  aws_l1_raw = jsondecode(file("${path.module}/aws_policies/devops-ext-l1.json")).Statement
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
  path     = "/customer-managed/"
  policy   = jsonencode(each.value)
}

# --- 3. AZURE COMPOSITION & ASSIGNMENT (The Leeway Logic) ---

locals {
  az_role_files = fileset("${path.module}/azure_roles", "*.yaml")
  
  # Multi-line concat for all assignable scopes
  all_azure_subs = concat(
    var.prod_subscription_ids, 
    var.nonprod_subscription_ids
  )
}

# 3a. Create Custom Role Definitions (Strict)
resource "azurerm_role_definition" "teams" {
  for_each = { 
    for f in local.az_role_files : 
    replace(f, ".yaml", "") => yamldecode(file("${path.module}/azure_roles/${f}")) 
  }
  
  name  = "Custom-${each.value.name}"
  scope = "/subscriptions/${var.prod_subscription_ids[0]}"

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
  role_definition_id = azurerm_role_definition.teams[each.value.team].role_definition_resource_id
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