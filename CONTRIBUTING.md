# Contributing

Thanks for your interest in improving this project.

## Workflow

1. Create a branch from `main`.
2. Make focused changes.
3. Run local checks:
   - `terraform init`
   - `terraform validate`
   - `terraform plan -var-file=global.tfvars`
4. Open a pull request with:
   - Problem statement
   - Change summary
   - Risk notes
   - Plan output highlights

## Contribution guidelines

- Keep changes minimal and scoped.
- Prefer composition updates over duplicating policy logic.
- Preserve least privilege and existing guardrail intent.
- Document behavior changes in `CHANGELOG.md`.

## Pull request checklist

- [ ] Terraform validate passes
- [ ] Plan reviewed for IAM drift
- [ ] Security-sensitive changes called out
- [ ] Docs updated when behavior changed

## Pushing to two repositories

You can publish to two Git remotes from the same local repo.

Option A: separate remotes

- `git remote add upstream <PRIMARY_REPO_URL>`
- `git remote add mirror <SECONDARY_REPO_URL>`
- `git push upstream main`
- `git push mirror main`

Option B: multiple push URLs on origin

- `git remote set-url --add --push origin <PRIMARY_REPO_URL>`
- `git remote set-url --add --push origin <SECONDARY_REPO_URL>`
- `git push origin main`

Use `git remote -v` to verify configuration.
