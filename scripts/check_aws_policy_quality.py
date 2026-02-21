#!/usr/bin/env python3
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
AWS_POLICIES_DIR = ROOT / "aws_policies"

ACTION_PATTERN = r"^[a-z0-9-]+:[A-Za-z*][A-Za-z0-9*]*$"

FORBIDDEN_BROAD_ACTIONS = {
    "*",
    "iam:*",
    "organizations:*",
    "account:*",
    "ec2:*",
    "rds:*",
    "s3:*",
    "kms:*",
    "secretsmanager:*",
}

NON_INTERNAL_FILES = {
    "dev-team.json",
    "devops-external-l1.json",
    "devops-external-l2.json",
    "sre-team.json",
    "cicd-service-account.json",
}


def normalize_list(value: Any) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        return [str(v) for v in value]
    return []


def action_looks_valid(action: str) -> bool:
    import re

    return bool(re.match(ACTION_PATTERN, action))


def key_for_statement(stmt: dict[str, Any]) -> str:
    return json.dumps(stmt, sort_keys=True, separators=(",", ":"))


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    files = sorted(AWS_POLICIES_DIR.rglob("*.json"))
    if not files:
        print("No AWS policy files found.")
        return 0

    for file_path in files:
        rel = file_path.relative_to(ROOT)
        try:
            data = json.loads(file_path.read_text())
        except Exception as exc:
            errors.append(f"{rel}: invalid JSON ({exc})")
            continue

        statements = data.get("Statement")
        if not isinstance(statements, list):
            errors.append(f"{rel}: missing or invalid Statement array")
            continue

        sid_seen: set[str] = set()
        statement_seen: set[str] = set()
        action_effect_index: dict[str, set[str]] = {}

        for i, stmt in enumerate(statements):
            if not isinstance(stmt, dict):
                errors.append(f"{rel}: Statement[{i}] must be an object")
                continue

            sid = stmt.get("Sid")
            effect = stmt.get("Effect")
            if sid:
                if sid in sid_seen:
                    errors.append(f"{rel}: duplicate Sid '{sid}'")
                sid_seen.add(sid)

            if effect not in {"Allow", "Deny"}:
                errors.append(f"{rel}: Statement[{i}] has invalid Effect '{effect}'")

            stmt_key = key_for_statement(stmt)
            if stmt_key in statement_seen:
                errors.append(f"{rel}: duplicate statement object detected (index {i})")
            statement_seen.add(stmt_key)

            actions = normalize_list(stmt.get("Action"))
            if not actions:
                errors.append(f"{rel}: Statement[{i}] missing Action")
                continue

            for action in actions:
                if "." in action and ":" not in action:
                    errors.append(f"{rel}: suspicious action '{action}' (dot notation likely typo)")

                if not action_looks_valid(action):
                    errors.append(f"{rel}: invalid action format '{action}'")

                if rel.name in NON_INTERNAL_FILES and effect == "Allow" and action in FORBIDDEN_BROAD_ACTIONS:
                    errors.append(
                        f"{rel}: forbidden broad allow action '{action}' for role tier"
                    )

                action_effect_index.setdefault(action, set()).add(effect)

        for action, effects in action_effect_index.items():
            if effects == {"Allow", "Deny"}:
                warnings.append(
                    f"{rel}: action '{action}' appears in both Allow and Deny (verify intent/conditions)"
                )

    if warnings:
        print("Policy quality warnings:")
        for warning in warnings:
            print(f"- {warning}")

    if errors:
        print("Policy quality errors:")
        for err in errors:
            print(f"- {err}")
        return 1

    print(f"AWS policy quality checks passed for {len(files)} files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
