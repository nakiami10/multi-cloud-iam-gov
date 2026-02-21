# Multi-Cloud IAM Governance Framework

Multi-cloud IAM as code for AWS + Azure, with composable role baselines, shared guardrails, environment-aware strictness, and CI/CD-safe deployment.

## Why this project

Most IAM programs fail by either becoming too restrictive (teams blocked) or too broad (security drift). This project aims for a middle path:

- **Composable permissions** (shared components + team overlays)
- **Tiered role model** (junior/senior/internal + SRE/dev/CI)
- **Guardrails by default** (explicit deny + MFA-gated deletes)
- **Policy-as-code workflows** (reviewable via Terraform plan/apply)

## What it manages

- **AWS**: IAM policies under `aws_policies/` with component inheritance from `aws_policies/components/`
- **Azure**: Custom role definitions under `azure_roles/` with component inheritance from `azure_roles/components/`
- **Orchestration**: Terraform composition engine in `main.tf`

## Role philosophy

- **DevOps External L1 (Junior)**: triage and safe runtime ops
- **DevOps External L2 (Senior)**: broader provisioning and operations, destructive operations gated by MFA
- **DevOps Internal**: broad lifecycle ownership with selective hard-deny guardrails for catastrophic actions
- **SRE Team**: observability + incident remediation
- **Dev Team**: app-scoped build/deploy permissions
- **CI/CD Service Account**: deployment automation with strict pass-role and identity guardrails

## Security model

- Explicit deny for identity-boundary changes where needed
- MFA-conditional deletes for human-operated roles
- Hard deny for critical data/crypto destruction in higher-risk contexts
- Environment-aware strictness through Terraform variables

## Quick start

1. Configure `global.tfvars` for environment and subscription mapping.
2. Review role files in `aws_policies/` and `azure_roles/`.
3. Run:
   - `terraform init`
   - `terraform validate`
   - `terraform plan -var-file=global.tfvars`

## CI/CD execution model (recommended)

Use GitHub Actions + OIDC federation (no root credentials for routine operations).

- Workflow: `.github/workflows/terraform-iam.yml`
- PR: `terraform plan`
- Main merge: `terraform apply` via protected environment

Required GitHub secrets:

- `AWS_TERRAFORM_ROLE_ARN`
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

## Project docs

- Architecture: `docs/ARCHITECTURE.md`
- Roadmap: `docs/ROADMAP.md`
- First release checklist: `docs/RELEASE_CHECKLIST.md`

## Intended audience

- Platform/security engineers building IAM guardrails as code
- Teams standardizing access patterns across cloud providers
- Organizations that need auditable least-privilege with operational practicality
