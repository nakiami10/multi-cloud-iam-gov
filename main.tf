# --- 1. PROVIDERS ---

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

# --- 2. AWS COMPOSITION ENGINE ---

locals {
  # Load Shared AWS Components
  aws_component_files = fileset("${path.module}/aws_policies/components", "*.json")
  
  aws_shared_statements = flatten([
    for f in local.aws_component_files : 
    jsondecode(file("${path.module}/aws_policies/components/${f}")).Statement
  ])
  
  # Load L1 Base for Inheritance
  aws_l1_raw = jsondecode(file("${path.module}/aws_policies/devops-ext-l1.json")).Statement

  aws_team_files = fileset("${path.module}/aws_policies", "*.json")
  
  # Multi-line Composition Engine for readability
  aws_final_policies = {
    for f in local.aws_team_files :
    replace(f, ".json", "") => {
      Version = "2012-10-17"
      Statement = f == "devops-internal.json" ? (
        # Internal gets raw
        jsondecode(file("${path.module}/aws_policies/${f}")).Statement 
      ) : f == "devops-ext-l2.json" ? (
        # L2 inherits L1 + Shared
        concat(
          local.aws_shared_statements, 
          local.aws_l1_raw, 
          jsondecode(file("${path.module}/aws_policies/${f}")).Statement
        )
      ) : (
        # Everyone else gets Shared + specific policy
        concat(
          local.aws_shared_statements, 
          jsondecode(file("${path.module}/aws_policies/${f}")).Statement
        )
      )
    }
  }
}

resource "aws_iam_policy" "composed" {
  for_each = local.aws_final_policies
  name     = "iam-composed-${each.key}"
  path     = "/customer-managed/"
  policy   = jsonencode(each.value)
}

# --- 3. AZURE COMPOSITION ENGINE ---

locals {
  az_component_files = fileset("${path.module}/azure_roles/components", "*.yaml")
  
  az_shared_actions = flatten([
    for f in local.az_component_files : 
    yamldecode(file("${path.module}/azure_roles/components/${f}")).actions
  ])

  # Load L1 Base for Inheritance
  az_l1_actions = yamldecode(file("${path.module}/azure_roles/devops-ext-l1.yaml")).actions

  az_role_files = fileset("${path.module}/azure_roles", "*.yaml")
  
  all_azure_subs = concat(
    var.prod_subscription_ids, 
    var.nonprod_subscription_ids
  )
}

resource "azurerm_role_definition" "teams" {
  for_each = { 
    for f in local.az_role_files : 
    replace(f, ".yaml", "") => yamldecode(file("${path.module}/azure_roles/${f}")) 
  }
  
  name  = "Custom-${each.value.name}"
  scope = "/subscriptions/${var.prod_subscription_ids[0]}"

  permissions {
    # Broken down into a multi-line concat/distinct block
    actions = distinct(
      concat(
        local.az_shared_actions,
        # Conditional injection: If L2, add L1 actions
        each.key == "devops-ext-l2" ? local.az_l1_actions : [],
        each.value.actions
      )
    )
    
    not_actions = lookup(each.value, "notActions", [])
  }

  assignable_scopes = [
    for id in local.all_azure_subs : 
    "/subscriptions/${id}"
  ]
}