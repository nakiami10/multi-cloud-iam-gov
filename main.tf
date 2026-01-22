# --- 1. PROVIDERS ---

provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

# --- 2. AWS COMPOSITION ENGINE ---

locals {
  # Dynamically load all AWS shared component statements from the components folder
  aws_component_files = fileset("${path.module}/aws_policies/components", "*.json")
  
  # Flatten all statements into a single list for merging
  aws_shared_statements = flatten([
    for f in local.aws_component_files : jsondecode(file("${path.module}/aws_policies/components/${f}")).Statement
  ])
  
  # Find all team-specific policy files at the root of /aws_policies
  aws_team_files = fileset("${path.module}/aws_policies", "*.json")
  
  # Composition Logic:
  # If the file is "devops-internal.json", use it raw (unrestricted).
  # Otherwise, concatenate the shared statements with the team-specific ones.
  aws_final_policies = {
    for f in local.aws_team_files :
    replace(f, ".json", "") => {
      Version = "2012-10-17"
      Statement = f == "devops-internal.json" ? jsondecode(file("${path.module}/aws_policies/${f}")).Statement : concat(local.aws_shared_statements, jsondecode(file("${path.module}/aws_policies/${f}")).Statement)
    }
  }
}

# Create the composed IAM policies in AWS
resource "aws_iam_policy" "composed" {
  for_each = local.aws_final_policies
  name     = "iam-composed-${each.key}"
  path     = "/customer-managed/"
  policy   = jsonencode(each.value)
}

# Attach policies to groups based on the mapping in variables.tf
resource "aws_iam_group_policy_attachment" "automated_attach" {
  for_each = {
    for team, assignment in var.team_assignments : team => assignment
    if contains(keys(local.aws_final_policies), team)
  }

  group      = each.value.iam_groups[0]
  policy_arn = aws_iam_policy.composed[each.key].arn
}

# --- 3. AZURE COMPOSITION ENGINE ---

locals {
  # Dynamically ingest ALL Azure shared components
  az_component_files = fileset("${path.module}/azure_roles/components", "*.yaml")
  
  az_shared_actions = flatten([
    for f in local.az_component_files : yamldecode(file("${path.module}/azure_roles/components/${f}")).actions
  ])
  
  az_role_files = fileset("${path.module}/azure_roles", "*.yaml")
  
  # Combine all subscription IDs for assignable_scopes
  all_azure_subs = concat(var.prod_subscription_ids, var.nonprod_subscription_ids)
}

# Create Custom Role Definitions in Azure
resource "azurerm_role_definition" "teams" {
  for_each = { for f in local.az_role_files : replace(f, ".yaml", "") => yamldecode(file("${path.module}/azure_roles/${f}")) }
  
  name  = "Custom-${each.value.name}"
  
  # Define the role at the scope of the primary production subscription
  scope = "/subscriptions/${var.prod_subscription_ids[0]}"

  permissions {
    # Merge shared actions with team-specific actions
    actions = distinct(concat(
      local.az_shared_actions,
      each.value.actions
    ))
    not_actions = lookup(each.value, "notActions", [])
  }

  # Make the role assignable across both Prod and Non-Prod environments
  assignable_scopes = [for id in local.all_azure_subs : "/subscriptions/${id}"]
}