# --- AZURE INFRASTRUCTURE VARIABLES ---

variable "prod_subscription_ids" {
  description = "A list of Production Azure Subscription IDs where strict roles are defined and enforced."
  type        = list(string)
}

variable "nonprod_subscription_ids" {
  description = "A list of Non-Production Azure Subscription IDs where developers have more operational leeway."
  type        = list(string)
}

# --- AWS IDENTITY VARIABLES ---

variable "team_assignments" {
  description = "A mapping of team names (matching JSON filenames) to their respective IAM Users and Groups."
  type = map(object({
    iam_users  = list(string)
    iam_groups = list(string)
  }))
  default = {
    "devops-internal" = {
      iam_users  = ["Khirmer.Dia"]
      iam_groups = ["Admins"]
    },
    "devops-ext-l1" = {
      iam_users  = ["contractor-senior-01"]
      iam_groups = ["External-L1"]
    },
    "devops-ext-l2" = {
      iam_users  = ["contractor-junior-01"]
      iam_groups = ["External-L2"]
    },
    "sre-team" = {
      iam_users  = ["sre-lead-01"]
      iam_groups = ["SRE-Team"]
    },
    "dev-team" = {
      iam_users  = []
      iam_groups = ["Developers"]
    },
    "cicd-service-account" = {
      iam_users  = ["cicd-pipeline-user"]
      iam_groups = ["ServiceAccounts"]
    }
  }
}