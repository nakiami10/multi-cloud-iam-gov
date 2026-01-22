# --- Azure Environment Separation ---
# It is recommended to separate these so you can apply different 
# levels of "leeway" per environment type.

prod_subscription_ids = [
  "00000000-0000-0000-0000-000000000000" # Production (Strict Lockdown)
]

nonprod_subscription_ids = [
  "11111111-1111-1111-1111-111111111111", # Development
  "22222222-2222-2222-2222-222222222222"  # Staging/Sandbox
]

# --- AWS Team Assignments ---
# Maps the filenames in /aws_policies to specific IAM entities.
# Note: You can also create separate maps for 'prod_assignments' 
# and 'nonprod_assignments' if users differ across accounts.

team_assignments = {
  "devops-internal" = {
    iam_users  = ["Khirmer.Dia", "admin.user"]
    iam_groups = ["Admins"]
  },
  "devops-ext-l1" = {
    iam_users  = ["external-senior-contractor"]
    iam_groups = ["External-Senior-Ops"]
  },
  "devops-ext-l2" = {
    iam_users  = ["external-junior-contractor"]
    iam_groups = ["External-Junior-Ops"]
  },
  "sre-team" = {
    iam_users  = ["sre.engineer"]
    iam_groups = ["SRE-Team"]
  },
  "dev-team" = {
    iam_users  = []
    iam_groups = ["Application-Developers"]
  },
  "cicd-service-account" = {
    iam_users  = ["github-actions-user"]
    iam_groups = ["Service-Accounts"]
  }
}