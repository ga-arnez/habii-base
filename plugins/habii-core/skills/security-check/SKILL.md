---
name: security-check
description: Runs the habii security-check subagent — security review of the current diff (default) or of the whole repository (`full`), in a clean context. Manual only.
argument-hint: "[full | base-ref]"
disable-model-invocation: true
---

# Security check

Arguments: `$ARGUMENTS`

- `full` → **full** mode: audit the whole repository.
- a git ref (branch, tag, sha) → **diff** mode against that base.
- empty → **diff** mode against `HEAD` (uncommitted changes). If there are no changes, ask whether to compare against the default branch or run `full`.

1. Launch the `habii-core:security-check` subagent with the mode and base. For `full` in a large repo or monorepo, you may launch one subagent per app/package in parallel, each with its path as scope.
2. Relay the report to the user as it came — do not soften severities or drop findings.
3. Never print secret values, even if the subagent did by mistake — replace them with `<REDACTED>`.
4. Ask which findings to fix before changing any code. High findings: recommend fixing before merging.
