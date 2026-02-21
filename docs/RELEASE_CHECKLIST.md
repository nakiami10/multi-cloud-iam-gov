# First Release Checklist

## Repository hygiene

- [x] Add `LICENSE` (recommended: MIT or Apache-2.0)
- [x] Add `CONTRIBUTING.md`
- [x] Add `CODE_OF_CONDUCT.md`
- [x] Add `SECURITY.md` with disclosure process
- [x] Add `CHANGELOG.md`

## Documentation

- [x] Ensure `README.md` reflects current architecture
- [x] Publish architecture and trust boundaries
- [x] Publish role matrix (who can do what)
- [x] Document known limitations and assumptions
- [x] Add quickstart for local `plan` and CI-based `apply`

## CI/CD and safety

- [ ] Configure OIDC trust for AWS deploy role
- [ ] Configure OIDC trust for Azure workload identity
- [ ] Protect `main` with required reviews + status checks
- [ ] Require manual approval for production `apply`
- [ ] Enable Terraform state locking and encryption

## IAM quality controls

- [x] Add CI check for invalid/typo action names
- [x] Add CI check for forbidden broad actions by role tier
- [x] Add CI check for duplicate statements / conflicting effects
- [ ] Add sample policy simulation scenarios for critical roles

## Release packaging

- [ ] Tag `v0.1.0`
- [ ] Add release notes with migration notes
- [x] Include sample `global.tfvars` template (sanitized)
- [x] Include sample org rollout plan (pilot -> broad rollout)

## Post-release

- [ ] Collect early adopter feedback and issue taxonomy
- [ ] Prioritize top 5 friction points
- [ ] Publish v0.2 milestones and dates
