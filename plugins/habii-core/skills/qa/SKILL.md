---
name: qa
description: Runs the habii qa subagent — functional QA of the current change against the test scenarios written in the Asana card linked in the PR, driving the real app (browser or simulator) in a clean context. Manual only.
argument-hint: "[PR number/URL | Asana card URL]"
disable-model-invocation: true
---

# QA against the Asana card

Arguments: `$ARGUMENTS`

The QA always runs against **written scenarios**. The source of truth is the Asana card; the PR only tells us which card.

## 1. Find the Asana card
- Argument is an Asana URL (`app.asana.com`) → use it.
- Argument is a PR number/URL → `gh pr view <arg> --json url,title,body`.
- Empty → `gh pr view --json url,title,body` (PR of the current branch).

Look for an `app.asana.com` link in the PR body. If there is no PR or no link, **ask the user for the card link**. If they have no card, ask them to **describe what must be tested** (go to step 3 with that description).

## 2. Read the scenarios from the card
Use the Asana MCP tools to fetch the task — name, description (notes), subtasks and comments. The task id is the long number after `/task/` in the URL (old format `app.asana.com/0/<project>/<task>`: the last number).

If no Asana MCP tool is available, tell the user to install `asana@claude-plugins-official` and run `/asana:asana-setup` (one-time OAuth app per person), and offer to continue with the scenarios pasted in the chat.

Extract the test scenarios (usually a "Cenários", "Cenários de teste", "Critérios de aceite" or "QA" section, or a checklist). Keep their wording; number them.
- **Card has no scenarios:** do not invent them silently. Tell the user, and offer a draft derived from the card description and the diff for them to approve or edit — or ask them to describe what to test.
- Ambiguous scenario (no expected result, unknown user/role, missing test data): ask before running.

## 3. Confirm the run
Show the numbered scenarios and confirm, in one message:
- **Target:** local (which URL / which simulator) or a deployed environment. If the app is not running, ask whether to start it (read CLAUDE.md for the command) or use another environment.
- **Test accounts / data** the scenarios need. Pass credentials to the subagent but never echo them back in the chat.

## 4. Run
Launch the `habii-core:qa` subagent with: the numbered scenarios (full text), the card URL and title, the PR URL if any, the target, the credentials, and the base ref of the change (`gh pr view --json baseRefName`, or `HEAD`). For many independent scenarios on web you may split them across parallel subagents; on a single simulator, keep one.

## 5. Report
Relay the subagent's report as it came — do not turn a ❌ or ⚠️ into ✅. Show the evidence paths.

Then ask:
- whether to **post the result as a comment on the Asana card** (only post after a yes; outward-facing), and
- for each ❌, whether to investigate/fix now.

## 6. Fix (only after a yes)
The QA context is full of scenarios and screenshots, not code — do not jump straight into the file the report points at. For each ❌:
1. Load the `habii-core:habii-workflow` skill and follow it.
2. Investigate the root cause from the report's hint; the hint is a starting point, not the fix.
3. Before editing, launch the `habii-core:explorer` subagent to find the closest existing pattern for what the fix touches (sibling file, equivalent action/hook/component/query, how the same case is handled elsewhere). State which pattern you will follow, citing `path:line`. Also respect the stack's convention skill when one applies (e.g. `habii-rails:habii-rails`, `habii-core:habii-apollo-client`).
4. Make the minimal fix that follows that pattern.
5. Launch the `habii-core:code-reviewer` subagent on the fix and apply its `must` items.
6. Re-run only the failed scenarios with the `habii-core:qa` subagent, and report again as in step 5.
