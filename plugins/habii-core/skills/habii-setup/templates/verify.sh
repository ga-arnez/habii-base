#!/usr/bin/env bash
# Verificação rápida do projeto. Rodada pelo hook Stop do habii-core antes de o Claude encerrar.
# Saída 0 = verde. Qualquer outra saída devolve o erro ao Claude para correção.
# Mantenha em segundos: typecheck/lint/testes afetados. E2E fica no CI.
set -euo pipefail

# Exemplos — troque pelos comandos reais do projeto:
# Turborepo:   pnpm turbo run typecheck lint --filter='...[HEAD]'
# Rails:       bundle exec rubocop --force-exclusion $(git diff --name-only HEAD -- '*.rb')
# Testes:      pnpm turbo run test --filter='...[HEAD]'

echo "TODO: configure .claude/verify.sh" >&2
exit 0
