# Sample Rollout Plan

## Phase 1: Pilot (1-2 teams)

- Select one non-production AWS account and one Azure subscription.
- Onboard `dev-team` and `sre-team` first.
- Run PR-based `terraform plan` for two weeks before production applies.
- Track blocked-action incidents and tune policy deltas.

## Phase 2: Controlled expansion

- Add `devops-external-l1` and `devops-external-l2` in non-prod.
- Enforce MFA for delete-capable operational actions.
- Enable production applies behind approval gates.

## Phase 3: Production adoption

- Roll out role mappings to production subscriptions/accounts.
- Require protected branch + environment approvals.
- Require break-glass playbook for exceptional deletes.

## Phase 4: Governance maturity

- Add policy simulation checks in CI.
- Schedule drift checks and quarterly access reviews.
- Publish role matrix and change log updates to stakeholders.

## Exit criteria

- No critical privilege-escalation findings.
- Acceptable operational unblock time for teams.
- Auditable PR-to-apply trail for all IAM changes.
