# Role Matrix (High-Level)

This matrix summarizes intended capability boundaries by team role.

| Role                  | Read/Observe | Operate Runtime            | Provision/Change  | Delete Operations                                                                   | Identity Mutation                             |
| --------------------- | ------------ | -------------------------- | ----------------- | ----------------------------------------------------------------------------------- | --------------------------------------------- |
| DevOps External L1    | Yes          | Yes (safe triage)          | Limited           | No (blocked)                                                                        | No (blocked)                                  |
| DevOps External L2    | Yes          | Yes                        | Yes               | Selected deletes with MFA; critical data/crypto deletes denied                      | Restricted                                    |
| DevOps Internal       | Yes          | Yes                        | Yes (broad)       | Selected deletes with MFA; critical data/crypto deletes denied                      | Broader role ops, boundary protections remain |
| SRE Team              | Yes          | Yes (incident remediation) | Limited           | Selected delete-capable ops with MFA; destructive deletes denied                    | No (blocked)                                  |
| Dev Team              | Yes          | Yes (app deploy/debug)     | Yes (app-scoped)  | Selected delete-capable ops with MFA; destructive deletes denied                    | No (blocked)                                  |
| CI/CD Service Account | Yes          | Automation only            | Yes (deploy path) | Scoped for deployment workflows; high-risk destructive data/identity actions denied | No broad IAM mutation                         |

## Notes

- This is an intent map, not a substitute for policy source review.
- Effective permissions also depend on org controls (SCP, Azure policy) and assignment scope.
- Refer to policy files under `aws_policies/` and `azure_roles/` for exact actions.
