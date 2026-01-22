# --- 1. PROVIDERS ---
provider "aws" { region = "us-east-1" }
provider "azurerm" { features {} }

# --- 2. AWS COMPOSITION LOGIC ---
locals {
  # Load Base Components
  base_monitoring = jsondecode(file("${path.module}/aws_policies/components/base-monitoring.json"))
  base_ssm        = jsondecode(file("${path.module}/aws_policies/components/ssm-inventory.json"))
  
  # Find Team Policy Files (ignores /components subfolder automatically)
  aws_team_files = fileset("${path.module}/aws_policies", "*.json")
  
  # Composition Engine
  aws_final_policies = {
    for f in local.aws_team_files :
    replace(f, ".json", "") => {
      Version = "2012-10-17"
      Statement = f == "devops-internal.json" ? 
        jsondecode(file("${path.module}/aws_policies/${f}")).Statement : 
        concat(
          local.base_monitoring.Statement,
          local.base_ssm.Statement,
          jsondecode(file("${path.module}/aws_policies/${f}")).Statement
        )
    }
  }
}

# Create Composed Policies
resource "aws_iam_policy" "composed" {
  for_each = local.aws_final_policies
  name     = "iam-composed-${each.key}"
  path     = "/customer-managed/"
  policy   = jsonencode(each.value)
}

# Attach to Groups (Linked to variables.tf mapping)
resource "aws_iam_group_policy_attachment" "automated_attach" {
  for_each = {
    for team, assignment in var.team_assignments : team => assignment
    if contains(keys(local.aws_final_policies), team)
  }

  group      = each.value.iam_groups[0]
  policy_arn = aws_iam_policy.composed[each.key].arn
}

# --- 3. AZURE RBAC LOGIC ---
locals {
  az_role_files = fileset("${path.module}/azure_roles", "*.yaml")
}

resource "azurerm_role_definition" "teams" {
  for_each = { for f in local.az_role_files : replace(f, ".yaml", "") => yamldecode(file("${path.module}/azure_roles/${f}")) }
  
  name  = "Custom-${each.value.name}"
  # Fixed variable naming consistency
  scope = "/subscriptions/${var.subscription_id}"

  permissions {
    actions     = each.value.actions
    not_actions = lookup(each.value, "notActions", [])
  }

  assignable_scopes = ["/subscriptions/${var.subscription_id}"]
}