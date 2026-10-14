#!/usr/bin/env bash
# Sincroniza as skills de terceiros listadas em vendor/skills.txt para dentro do plugin habii-core.
# Instala numa pasta temporária com `npx skills add --copy` (sem symlinks, que o cache de plugins ignora)
# e copia cada skill para plugins/habii-core/skills/<nome>. O lock resultante vai para vendor/skills-lock.json.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIST="$ROOT/vendor/skills.txt"
DEST="$ROOT/plugins/habii-core/skills"
LOCK="$ROOT/vendor/skills-lock.json"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git -C "$TMP" init -q

names=()
while read -r repo name; do
  [[ -z "${repo:-}" || "$repo" == \#* ]] && continue
  echo "→ $name ($repo)"
  (cd "$TMP" && npx -y skills@latest add "$repo" --skill "$name" -a claude-code --copy -y </dev/null >/dev/null)
  names+=("$name")
done < "$LIST"

# Remove skills vendorizadas que saíram da lista (as próprias, habii-*, nunca são tocadas).
if [[ -f "$LOCK" ]]; then
  for old in $(jq -r '.skills | keys[]' "$LOCK"); do
    if [[ ! " ${names[*]} " =~ " $old " && "$old" != habii-* ]]; then
      echo "✗ removendo $old"
      rm -rf "${DEST:?}/$old"
    fi
  done
fi

for name in "${names[@]}"; do
  rm -rf "${DEST:?}/$name"
  cp -R "$TMP/.claude/skills/$name" "$DEST/$name"
done

cp "$TMP/skills-lock.json" "$LOCK"
echo "✓ ${#names[@]} skills sincronizadas. Revise o diff antes de commitar."
