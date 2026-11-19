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
  local dir="$1" file="skills/$1/SKILL.md" name
  name="$(frontmatter_name "$REPO/$file")"
  [ "$name" = "$dir" ] ||
    error "$dir" "name: is '${name:-missing}' in $file; it must match the directory"
}

check_root_entries() {
  local dir="$1" entry
  while IFS= read -r entry; do
    case "$entry" in
      SKILL.md|references|scripts|assets|agents) ;;
      *) error "$dir" "skills/$dir/$entry is not allowed at the skill root; move it into references/, scripts/, assets/, or agents/" ;;
    esac
  done < <(git -C "$REPO" ls-files "skills/$dir/" | sed "s#^skills/$dir/##; s#/.*##" | sort -u)
}

# Installs land elsewhere, so skill text must not point at absolute paths.
check_absolute_paths() {
  local dir="$1" hit
  while IFS= read -r hit; do
    error "$dir" "absolute path at $hit; use a relative path"
  done < <(git -C "$REPO" grep -n -E '/Users/|~/|\]\(/' -- "skills/$dir/*.md" | cut -d: -f1,2)
}

# Tracked files only, so untracked clutter never fails the check.
tracked_skills() {
  git -C "$REPO" ls-files ':(glob)skills/*/SKILL.md' | cut -d/ -f2 | sort -u
}

# Every skill has one README row and every row has a skill; the row text is free.
check_readme_rows() {
  local rows skills name
  rows="$(grep -oE '^\|[[:space:]]*\[[^]]+\]\(skills/[^/)]+\)' "$REPO/README.md" |
    sed -E 's#.*\(skills/##; s#\)$##' | sort -u)"
  skills="$(tracked_skills)"
  while IFS= read -r name; do
    error "$name" "no row in README.md"
  done < <(comm -13 <(echo "$rows") <(echo "$skills") | sed '/^$/d')
  while IFS= read -r name; do
    error "$name" "README.md has a row, but skills/$name/SKILL.md is not tracked"
  done < <(comm -23 <(echo "$rows") <(echo "$skills") | sed '/^$/d')
}

# A mode change outside scripts is almost always an accident.
check_executables() {
  local path subject
  while IFS= read -r path; do
    case "$path" in scripts/*|*/scripts/*|.githooks/*) continue ;; esac
    case "$path" in skills/*/*) subject="$(cut -d/ -f2 <<<"$path")" ;; *) subject=repo ;; esac
    error "$subject" "$path is executable; only files under scripts/ or .githooks/ may be"
  done < <(git -C "$REPO" ls-files -s | awk '$1 == "100755" { sub(/^[^\t]*\t/, ""); print }')
}

while IFS= read -r dir; do
  check_name_matches_dir "$dir"
  check_root_entries "$dir"
  check_absolute_paths "$dir"
done < <(tracked_skills)
check_readme_rows
check_executables

[ "$errors" -eq 0 ] || exit 1
