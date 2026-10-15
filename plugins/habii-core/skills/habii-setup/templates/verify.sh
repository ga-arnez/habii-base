#!/usr/bin/env bash
# Fast project verification. Run by the habii-core Stop hook before Claude finishes.
# Exit 0 = green. Any other exit returns the error to Claude to fix.
# Keep it to seconds: typecheck/lint/affected tests. E2E stays in CI.
set -euo pipefail

# Examples — replace with the project's real commands:
# Turborepo:   pnpm turbo run typecheck lint --filter='...[HEAD]'
# Rails:       bundle exec rubocop --force-exclusion $(git diff --name-only HEAD -- '*.rb')   (only if .rubocop.yml exists)
#              bundle exec rspec $(git diff --name-only HEAD -- 'spec/**/*_spec.rb')        (specs touched)
# Tests:       pnpm turbo run test --filter='...[HEAD]'
# Expo:        npx tsc --noEmit && npx expo lint   (add jest only if the app has tests; no native build: too slow)

echo "TODO: configure .claude/verify.sh" >&2
exit 0
