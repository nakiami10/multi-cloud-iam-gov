# multi-cloud-iam-gov

This creates IaC to create groups, better for managing and visibility

##

│
├── main.tf # Main Orchestrator
├── providers.tf # AWS & Azure provider config
│
├── /aws_policies
│ ├── devops-internal.json # Full Admin (Internal)
│ ├── devops-ext-l1.json # Senior Contractor (No Delete)
│ ├── devops-ext-l2.json # Junior Contractor (Ops Only)
│ ├── sre-team.json # Observability & Metrics
│ └── dev-team.json # Application Devs
│
└── /azure_roles
├── devops-internal.yaml # Full Owner (Internal)
├── devops-ext-l1.yaml # Contributor (No Delete)
├── devops-ext-l2.yaml # Reader + Ops (No Delete)
└── sre-team.yaml # Insights & Maintenance
