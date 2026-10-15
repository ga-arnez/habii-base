# <Project name>

<!-- Habii template. Keep it under 80 lines. For each line, ask:
     "would removing it make Claude get things wrong?" If not, cut it. Comments like this one do not reach the context. -->

<One sentence: what the system does and for whom.>

Always respond to the user in Brazilian Portuguese (pt-BR); code, identifiers and commits in English.

## Commands
- Install: `<command>`
- Dev: `<command>`
- Typecheck: `<command>`
- Lint: `<command>`
- Test a single file: `<command> <path>`
- Full verification: `.claude/verify.sh`

## Architecture
<!-- Only local decisions that are not visible from the code. Bigger decisions go in docs/adr/. -->
- <e.g.: apps/api is Fastify + Zod; shared contracts in packages/contracts>
- <e.g.: every external integration goes through packages/integrations; never call it directly from the app>

## Pitfalls
- <e.g.: required env vars: DATABASE_URL, FOCUS_NFE_TOKEN>
- <e.g.: Prisma migrations only via `pnpm db:migrate`, never `prisma db push` on staging>

## When compacting
Preserve the list of modified files and the test commands used.
