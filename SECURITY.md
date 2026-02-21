# Security Policy

## Supported scope

This project manages IAM governance artifacts and Terraform composition logic for AWS and Azure.

## Reporting a vulnerability

Please report security issues privately and do not open public issues for sensitive findings.

Include:

- Affected file(s) and role/policy path
- Reproduction steps
- Expected vs actual behavior
- Potential impact

## Response goals

- Initial acknowledgment: within 3 business days
- Triage decision: within 7 business days
- Fix or mitigation plan: as soon as practical based on severity

## Hardening baseline

- Use short-lived federated credentials (OIDC) for CI/CD
- Keep root/admin break-glass only
- Require PR reviews and protected applies for production changes
