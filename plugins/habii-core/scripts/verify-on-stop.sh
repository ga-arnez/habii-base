#!/usr/bin/env bash
# habii-core verification gate (Stop hook).
#
# Before Claude ends its turn, runs the project's `.claude/verify.sh`, if it exists.
# If it fails, returns the output to Claude (exit 2) so it fixes it before finishing.
#
# The core does not know the stack: the project defines what "green" means (or the
# habii-ts / habii-rails / habii-mobile plugins, which generate this script during setup).
#
# Disable for a single run: HABII_SKIP_VERIFY=1
set -uo pipefail

[[ "${HABII_SKIP_VERIFY:-0}" == "1" ]] && exit 0
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0

VERIFY=".claude/verify.sh"
[[ -x "$VERIFY" ]] || exit 0

# No working tree changes, nothing to verify.
if git rev-parse --verify -q HEAD >/dev/null 2>&1 \
   && git diff --quiet HEAD -- 2>/dev/null \
   && [[ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
  exit 0
fi

out="$("$VERIFY" 2>&1)"
code=$?
[[ $code -eq 0 ]] && exit 0

{
  echo "Project verification failed (.claude/verify.sh exited with $code)."
  echo "Fix the root cause before finishing; do not suppress the error. Last lines:"
  echo "$out" | tail -n 60
} >&2
exit 2
