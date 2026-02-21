# Public Release Checklist (Sanitized Mirror)

Use this checklist before pushing to your public repository.

## 1) Keep vs Exclude

## Keep (safe to publish)

- `aws_policies/**`
- `azure_roles/**`
- `main.tf`
- `variables.tf`
- `.github/workflows/**`
- `scripts/**`
- `README.md`
- `docs/**`
- `LICENSE`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`
- `CHANGELOG.md`
- `global.tfvars.example`

## Exclude (do not publish)

- `global.tfvars`
- `.terraform/**`
- `*.tfstate`
- `*.tfstate.*`
- any local scratch files (`*.scratch`)
- any local notes with client names, account IDs, or principal IDs

## 2) Make sure ignored files are not tracked

Run from repo root:

```bash
git rm --cached global.tfvars || true
git rm -r --cached .terraform 2>/dev/null || true
git rm --cached *.tfstate *.tfstate.* 2>/dev/null || true
```

Then verify:

```bash
git status --short
```

## 3) Quick client-identifier scan

Run targeted scans and confirm no sensitive hits:

```bash
git grep -nEi 'customer|client|companyname|internal-only|confidential|account-id|tenant-id|principal-id'
git grep -nEi 'khirmer|dia|deco'
```

Expected result: no sensitive identifiers in tracked files.

## 4) Validate policy/tooling before publish

```bash
terraform validate
python3 scripts/check_aws_policy_quality.py
```

## 5) Create and push public mirror

Option A: separate mirror remote

```bash
git remote add mirror <YOUR_PUBLIC_REPO_URL>
git push mirror main
```

Option B: push both from origin

```bash
git remote set-url --add --push origin <PRIMARY_REPO_URL>
git remote set-url --add --push origin <YOUR_PUBLIC_REPO_URL>
git push origin main
```

## 6) First public release steps

- Tag release:

```bash
git tag v0.1.0
git push --tags
```

- Create GitHub release notes from `CHANGELOG.md`.
- Add branch protection and required checks in public repo.

## 7) Legal and ownership safety

- Confirm your contract allows publishing generalized framework work.
- Confirm no client identifiers, proprietary naming conventions, or live IDs remain.
- Keep examples generic in all docs and tfvars templates.
