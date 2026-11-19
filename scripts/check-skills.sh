#!/usr/bin/env bash
# Check the skills in this repo against the mechanical rules in AGENTS.md.
#
#   scripts/check-skills.sh             check every tracked skill
#
# One line per finding: `ERROR <skill>: <what>`. Exits 1 on any error.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-}" in
  -h|--help) sed -n '2,6p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) echo "unknown flag: $1" >&2; exit 2 ;;
esac

errors=0
error() { echo "ERROR $1: $2"; errors=$((errors + 1)); }

# The `name:` value from the frontmatter, with surrounding quotes removed.
frontmatter_name() {
  awk '
    NR == 1 && /^---[[:space:]]*$/ { infm = 1; next }
    infm && /^---[[:space:]]*$/ { exit }
    infm && /^name:[[:space:]]*/ {
      sub(/^name:[[:space:]]*/, ""); sub(/[[:space:]]+$/, "")
      gsub(/^["\047]|["\047]$/, ""); print; exit
    }
  ' "$1"
}

check_name_matches_dir() {
  local file="$1" dir name
  dir="$(basename "$(dirname "$file")")"
  name="$(frontmatter_name "$REPO/$file")"
  [ "$name" = "$dir" ] ||
    error "$dir" "name: is '${name:-missing}' in $file; it must match the directory"
}

# Tracked files only, so untracked clutter never fails the check.
while IFS= read -r file; do
  check_name_matches_dir "$file"
done < <(git -C "$REPO" ls-files ':(glob)skills/*/SKILL.md')

[ "$errors" -eq 0 ] || exit 1
