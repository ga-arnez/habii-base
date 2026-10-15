#!/usr/bin/env bash
# Sincroniza as skills de terceiros listadas em vendor/skills.txt para dentro dos plugins.
# Instala numa pasta temporária com `npx skills add --copy` (sem symlinks, que o cache de plugins ignora)
# e copia cada skill para plugins/<plugin>/skills/<nome> (um ou mais plugins, separados por vírgula). O lock resultante vai para vendor/skills-lock.json.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIST="$ROOT/vendor/skills.txt"
PLUGINS="$ROOT/plugins"
LOCK="$ROOT/vendor/skills-lock.json"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git -C "$TMP" init -q

names=()
targets=()
while read -r plugins repo name; do
  [[ -z "${plugins:-}" || "$plugins" == \#* ]] && continue
  for plugin in ${plugins//,/ }; do
    if [[ ! -d "$PLUGINS/$plugin" ]]; then
      echo "plugin inexistente: $plugin (linha da skill $name)" >&2
      exit 1
    fi
  done
  echo "→ $plugins/$name ($repo)"
  (cd "$TMP" && npx -y skills@latest add "$repo" --skill "$name" -a claude-code --copy -y </dev/null >/dev/null)
  names+=("$name")
  targets+=("$plugins")
done < "$LIST"

# Remove skills vendorizadas que saíram da lista (as próprias, habii-*, nunca são tocadas).
if [[ -f "$LOCK" ]]; then
  for old in $(jq -r '.skills | keys[]' "$LOCK"); do
    if [[ ! " ${names[*]} " =~ " $old " && "$old" != habii-* ]]; then
      echo "✗ removendo $old"
      rm -rf "$PLUGINS"/*/skills/"${old:?}"
    fi
  done
fi

# Apaga a skill de qualquer plugin antes de copiar, para que mudar o plugin de destino na lista a mova.
for i in "${!names[@]}"; do
  name="${names[$i]}"
  rm -rf "$PLUGINS"/*/skills/"${name:?}"
  for plugin in ${targets[$i]//,/ }; do
    mkdir -p "$PLUGINS/$plugin/skills"
    cp -R "$TMP/.claude/skills/$name" "$PLUGINS/$plugin/skills/$name"
  done
done

cp "$TMP/skills-lock.json" "$LOCK"
echo "✓ ${#names[@]} skills sincronizadas. Revise o diff antes de commitar."
