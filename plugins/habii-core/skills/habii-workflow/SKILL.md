---
name: habii-workflow
description: Habii Tech's standard workflow for implementing features, fixing bugs and refactoring (implementar feature, corrigir bug, refatorar) — when to plan, how to verify, when to delegate to subagents and when to clear context. Use when starting any coding task that touches more than one file.
---

# Habii workflow

Context is the most expensive resource. Everything here exists to keep it small and verifiable.

## 1. Size the task

- **Can you describe the diff in one sentence?** Just do it, no plan.
- **Uncertain approach, several files or unfamiliar code?** Explore and plan first (plan mode).
- **Large feature or ambiguous requirement?** Use `grill-with-docs` to interview the user, record decisions in ADRs and write a `SPEC.md`. Implement in a fresh session, starting from the SPEC.

## 2. Explore without polluting context

- Broad reading (many files, logs, history) → delegate to the `explorer` subagent and work from the map it returns.
- Before creating something, find the closest existing pattern in the project and follow it.
- Read `GLOSSARY.md` and ADRs in `docs/adr/` when they exist; use the domain vocabulary.

## 3. Implement against a check

- Decide up front how you will know it worked: test, typecheck, build, screenshot.
- New behavior or bug → `tdd`: failing test first, then the fix.
- The project may have `.claude/verify.sh`; the Stop hook runs it and blocks finishing if it fails. Fix the root cause — never disable a check, never use `any`/`@ts-ignore`/`skip` to get it passing.

## 4. Prove, don't claim

When done, show the evidence: the command you ran and its result. "Should work" is not a conclusion.

## 5. Review in a clean context

Meaningful change → `reviewer` subagent against the SPEC/plan. Fix only what affects correctness or requirements; treat the rest as optional.

## 6. Session hygiene

- Fixed the same thing twice and it's still wrong? Stop, summarize what you learned and suggest `/clear` with a better prompt.
- Unrelated tasks → separate sessions.
- Prefer CLIs (`gh`, `turbo`, `pnpm`, `bin/rails`) over MCPs when both work.
