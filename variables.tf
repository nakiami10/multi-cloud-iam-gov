variable "team_assignments" {
  description = "Maps policy files to specific IAM Groups or Users"
  type = map(object({
    iam_users  = list(string)
    iam_groups = list(string)
  }))
  default = {
    "devops-internal" = {
      iam_users  = [""],
      iam_groups = ["Admins"]
    },
    "devops-ext-l1" = {
      iam_users  = ["contractor-senior-01"],
      iam_groups = ["External-L1"]
    },
    "devops-ext-l2" = {
      iam_users  = ["contractor-junior-01"],
      iam_groups = ["External-L2"]
    },
    "sre-team" = {
      iam_users  = ["sre-lead-01"],
      iam_groups = ["SRE-Team"]
    },
    "cicd-service-account" = {
      iam_users  = ["cicd-pipeline-user"],
      iam_groups = ["ServiceAccounts"]
    }
  }
}