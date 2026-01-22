# --- ENVIRONMENT SETTINGS ---
environment              = "production"
enable_strict_governance = true

# --- AZURE SUBSCRIPTIONS ---
# Production subscriptions receive strict custom roles
prod_subscription_ids = [
  "00000000-0000-0000-0000-000000000000"
]

# Non-production subscriptions receive built-in Contributor roles (leeway)
nonprod_subscription_ids = [
  "11111111-1111-1111-1111-111111111111",
  "22222222-2222-2222-2222-222222222222"
]

# --- AZURE IDENTITY MAPPINGS ---
# Map specific Entra ID Principal IDs to teams across various subscriptions
azure_team_principals = [
  {
    team            = "devops-ext-l1"
    subscription_id = "00000000-0000-0000-0000-000000000000" # Prod
    principal_id    = "55555555-5555-5555-5555-555555555555"
  },
  {
    team            = "devops-ext-l1"
    subscription_id = "11111111-1111-1111-1111-111111111111" # Non-Prod
    principal_id    = "55555555-5555-5555-5555-555555555555"
  },
  {
    team            = "sre-team"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    principal_id    = "99999999-9999-9999-9999-999999999999"
  }
]

# --- AWS IDENTITY ASSIGNMENTS ---
# These mappings correspond to the JSON filenames in /aws_policies
team_assignments = {
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