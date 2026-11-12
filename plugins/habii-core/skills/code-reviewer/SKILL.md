---
name: code-reviewer
description: Runs the habii code-reviewer subagent on the current diff — quality review (reuse, conventions, complexity, weak tests) in a clean context. Manual only.
argument-hint: "[base-ref]"
disable-model-invocation: true
---

# Code review (quality)

Base: `$ARGUMENTS` (if empty, use `HEAD` — i.e. the uncommitted changes; if there are none, ask which base to compare against, suggesting the default branch).

1. Check there is something to review: `git status --porcelain` and `git diff --stat <base>`.
2. Launch the `habii-core:code-reviewer` subagent with: the base, and the SPEC/plan/issue for this change if one was mentioned in the conversation (path only, it reads it).
3. Relay its findings to the user as they came — do not soften, reorder or add your own.
4. Ask which items to apply before changing any code. When fixing, keep to the reported items.
