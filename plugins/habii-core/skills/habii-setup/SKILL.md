---
name: habii-setup
description: Prepares a project repository for the Habii harness (configurar projeto, setup) — creates a lean CLAUDE.md, .claude/verify.sh and registers the habii marketplace in .claude/settings.json. Use only when the user asks to set up the project.
disable-model-invocation: true
---

# Habii project setup

Prepare the current repository in the steps below. Do not overwrite anything that already exists without asking; when a file exists, propose the diff.

## 1. Detect the stack
Inspect the root: `turbo.json`/`pnpm-workspace.yaml` (Turborepo/TS), `Gemfile` with `rails` (Rails), `expo` in `package.json` (React Native with Expo; also note whether it uses `expo-router` or `@react-navigation/*`). Find the real typecheck, lint and test commands by reading `package.json`, `turbo.json`, `Gemfile`, `bin/`.

## 2. CLAUDE.md
If it does not exist, create it from `templates/CLAUDE.md` (in this skill's folder), filling it with what you **verified** in step 1. Rules:
- Under 200 lines; ideally under 80.
- Only what Claude cannot discover by reading the code: commands, environment quirks, local architecture decisions, pitfalls.
- No file-by-file descriptions, no obvious language conventions.
- Notes for humans go in HTML comments (`<!-- -->`), which do not reach the context.

## 3. .claude/verify.sh
Create it from `templates/verify.sh` with the commands verified in step 1, and `chmod +x` it. It is the project's "green": the habii-core Stop hook runs it before Claude finishes. It must be **fast** (seconds, not minutes): typecheck and lint of what changed plus affected unit tests; leave e2e to CI.

Run the script once. If the project is already red (legacy), tell the user and agree on a path: fix it first, or start with a narrower verify.sh.

## 4. .claude/settings.json
Ensure (merging with whatever exists) the entries from `templates/settings.json`. In `enabledPlugins`, always enable `habii-core@habii` and `context7@claude-plugins-official` (version-specific library docs; each person authenticates on first use), and add the plugins for the detected stack that already exist in the marketplace:
- Rails → `habii-rails@habii`
- TypeScript (React web and/or Fastify) → `habii-ts@habii`
- Expo → `habii-mobile@habii`, plus Expo's official plugin: add to `extraKnownMarketplaces` the entry `"expo-plugins": { "source": { "source": "github", "repo": "expo/skills" } }` and enable `expo@expo-plugins`
- Monorepo with more than one (e.g. Expo app + Rails API) → enable all of them

## 5. Library skills (TanStack Intent)
If `package.json` (any workspace) depends on `@trpc/*` or `@tanstack/*`, run `npx @tanstack/intent@latest install` at the root. Those libraries ship their skills inside the npm package, so the guidance matches the installed version; do not vendor them. Show the user the resulting diff.

## When done
List the files created/changed and the output of the first `verify.sh` run. Remind the user to commit `.claude/settings.json` and `CLAUDE.md`, and to turn on marketplace auto-update in `/plugin` → Marketplaces.
