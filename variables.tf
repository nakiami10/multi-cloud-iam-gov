# --- ENVIRONMENT SETTINGS ---

variable "environment" {
  description = "Target environment name (e.g., prod, dev, staging)."
  type        = string
}

variable "enable_strict_governance" {
  description = "If true, injects restrictive shared components (PassRole locks, etc.). Set to false for Non-Prod leeway."
  type        = boolean
  default     = true
}

# --- AZURE SUBSCRIPTIONS ---

variable "prod_subscription_ids" {
  description = "A list of Production Azure Subscription IDs where strict roles are defined and enforced."
  type        = list(string)
}

variable "nonprod_subscription_ids" {
  description = "A list of Non-Production Azure Subscription IDs where developers have more operational leeway."
  type        = list(string)
}

# --- IDENTITY MAPPINGS ---

variable "azure_team_principals" {
  description = "A list of objects mapping a Team to a Subscription and an Entra ID Principal (User/Group)."
  type = list(object({
    team            = string
    subscription_id = string
    principal_id    = string
  }))
}

variable "team_assignments" {
  description = "AWS-specific team assignments for Group/User attachment logic (often used in orchestration)."
  type = map(object({
    iam_users  = list(string)
    iam_groups = list(string)
  }))
  default = {
    "devops-internal" = {
      iam_users  = ["Khirmer.Dia"]
      iam_groups = ["Admins"]
    }
    "devops-ext-l1" = {
      iam_users  = ["contractor-senior-01"]
      iam_groups = ["External-L1"]
    }
    "devops-ext-l2" = {
      iam_users  = ["contractor-junior-01"]
      iam_groups = ["External-L2"]
    }
    "sre-team" = {
      iam_users  = ["sre-lead-01"]
      iam_groups = ["SRE-Team"]
    }
    "dev-team" = {
      iam_users  = []
      iam_groups = ["Developers"]
    }
    "cicd-service-account" = {
      iam_users  = ["cicd-pipeline-user"]
      iam_groups = ["ServiceAccounts"]
    }
  }
}