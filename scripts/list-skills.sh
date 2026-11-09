#!/usr/bin/env bash
# List the skills in this repo with their descriptions and link status.
#
#   scripts/list-skills.sh              one skill per line, wrapped description
#   scripts/list-skills.sh --names      names only, one per line (for piping)
#   scripts/list-skills.sh --md         markdown rows for the README table
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS=("$HOME/.claude/skills" "$HOME/.agents/skills")

# Bold only when writing to a terminal, so piped output stays clean.
if [ -t 1 ]; then bold=$'\033[1m'; reset=$'\033[0m'; else bold=''; reset=''; fi

mode=full
case "${1:-}" in
  --names) mode=names ;;
  --md)    mode=md ;;
  -h|--help) sed -n '2,6p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) echo "unknown flag: $1" >&2; exit 2 ;;
esac

# Pull `description` out of the frontmatter. Handles an inline value, a quoted
# one, and a folded/literal block (`>-`, `|`) spread over several lines.
description() {
  awk '
    NR == 1 && /^---[[:space:]]*$/ { infm = 1; next }
    infm && /^---[[:space:]]*$/ { exit }
    infm && /^description:[[:space:]]*/ {
      sub(/^description:[[:space:]]*/, "")
      sub(/^[>|][-+]?[[:space:]]*$/, "")
      desc = $0; grabbing = 1; next
    }
    grabbing {
      if ($0 ~ /^[[:space:]]*$/) { next }
      if (/^[[:space:]]/) { line = $0; sub(/^[[:space:]]+/, "", line); desc = desc " " line; next }
      grabbing = 0
    }
    END {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
      q = sprintf("%c", 39)
      if (substr(desc, 1, 1) == "\"" || substr(desc, 1, 1) == q) desc = substr(desc, 2)
      if (substr(desc, length(desc), 1) == "\"" || substr(desc, length(desc), 1) == q) desc = substr(desc, 1, length(desc) - 1)
      print desc
    }
  ' "$1"
}

links() {
  local name="$1" out=()
  for target_dir in "${TARGETS[@]}"; do
    local link="$target_dir/$name"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$REPO/skills/$name" ]; then
      out+=("$(basename "$(dirname "$target_dir")")")
    fi
  done
  [ ${#out[@]} -eq 0 ] && { echo "not linked"; return; }
  printf '%s' "linked: ${out[*]}"
}

count=0
[ "$mode" = md ] && printf '| Skill | What it does |\n| ----- | ------------ |\n'

for dir in "$REPO"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  count=$((count + 1))

  case "$mode" in
    names) echo "$name" ;;
    md)    printf '| [%s](skills/%s) | %s |\n' "$name" "$name" \
             "$(description "$dir/SKILL.md" | sed -E 's/([.!?])[[:space:]]+[[:upper:]].*/\1/')" ;;
    full)
      files=$(find "$dir" -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
      [ "$files" -eq 1 ] && unit=file || unit=files
      printf '%s%s%s  (%s %s, %s)\n' "$bold" "$name" "$reset" "$files" "$unit" "$(links "$name")"
      description "$dir/SKILL.md" | fold -s -w 76 | sed 's/^/  /'
      echo
      ;;
  esac
done

[ "$mode" = full ] && echo "$count skill(s) in $REPO/skills"
exit 0
