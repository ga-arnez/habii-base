#!/usr/bin/env bash
# Gate de verificação do habii-core (hook Stop).
#
# Antes do Claude encerrar o turno, roda o `.claude/verify.sh` do projeto, se ele existir.
# Se falhar, devolve a saída ao Claude (exit 2) para que ele corrija antes de terminar.
#
# O core não sabe qual é a stack: quem define o "verde" é o projeto (ou os plugins
# habii-ts / habii-rails / habii-rn, que geram esse script no setup).
#
# Desligar pontualmente: HABII_SKIP_VERIFY=1
set -uo pipefail

[[ "${HABII_SKIP_VERIFY:-0}" == "1" ]] && exit 0
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0

VERIFY=".claude/verify.sh"
[[ -x "$VERIFY" ]] || exit 0

# Sem mudanças no working tree, não há o que verificar.
if git rev-parse --verify -q HEAD >/dev/null 2>&1 \
   && git diff --quiet HEAD -- 2>/dev/null \
   && [[ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
  exit 0
fi

out="$("$VERIFY" 2>&1)"
code=$?
[[ $code -eq 0 ]] && exit 0

{
  echo "A verificação do projeto falhou (.claude/verify.sh saiu com $code)."
  echo "Corrija a causa raiz antes de encerrar; não suprima o erro. Últimas linhas:"
  echo "$out" | tail -n 60
} >&2
exit 2
