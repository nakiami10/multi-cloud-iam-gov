# Roadmap

## Vision

Make multi-cloud IAM governance practical for real engineering teams: secure by default, fast to operate, and easy to audit.

## v0.1 (Current foundation)

- AWS and Azure policy/role composition with shared components
- Team-tier role model (L1/L2/internal/SRE/dev/CI)
- MFA-gated delete model for human-operated AWS roles
- CI/CD workflow skeleton with OIDC-ready authentication

## v0.2 (Quality + verification)

- Add policy linting and static checks in CI
- Add effective-permission snapshots for each team role
- Add drift detection workflow (`plan` on schedule)
- Add documented threat model and trust boundaries

## v0.3 (Adoption pack)

- Publish opinionated templates for common org archetypes
- Add migration guide from existing IAM baselines
- Add examples for prod vs non-prod governance modes
- Add role matrix generator for audit/compliance reviews

## v0.4 (Enterprise hardening)

- Optional policy tests for forbidden actions by role
- Optional break-glass workflow with approval and expiry
- Optional per-environment isolated state + deployment identities
- Optional organization-level baseline controls (SCP / Azure Policy integration)

## Nice-to-have

- Web docs site with interactive role explorer
- Change impact summaries generated from Terraform plan output
- Benchmark mode against cloud managed policies
