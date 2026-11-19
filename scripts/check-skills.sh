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
warn() { echo "WARN $1: $2"; }

# A frontmatter value on one line: inline, quoted, or a folded/literal block.
frontmatter_field() {
  awk -v key="$2" '
    NR == 1 && /^---[[:space:]]*$/ { infm = 1; next }
    infm && /^---[[:space:]]*$/ { exit }
    infm && !grabbing && $0 ~ "^" key ":" {
      sub("^" key ":[[:space:]]*", ""); sub(/^[>|][-+]?[[:space:]]*$/, "")
      value = $0; grabbing = 1; next
    }
    grabbing && /^[[:space:]]*$/ { next }
    grabbing && /^[[:space:]]/ { line = $0; sub(/^[[:space:]]+/, "", line); value = value " " line; next }
    grabbing { exit }
    END {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      gsub(/^["\047]|["\047]$/, "", value)
      print value
    }
  ' "$1"
}

check_name_matches_dir() {
  local dir="$1" file="skills/$1/SKILL.md" name
  name="$(frontmatter_field "$REPO/$file" name)"
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

# Context, not lines: the body loads when the skill triggers. Warn only; a longer
# skill is fine when justified.
check_body_size() {
  local dir="$1" tokens
  tokens=$(( $(awk 'NR == 1 && /^---/ { fm = 1; next } fm && /^---/ { fm = 0; body = 1; next } body' \
    "$REPO/skills/$dir/SKILL.md" | wc -c) / 4 ))
  [ "$tokens" -le 2500 ] ||
    warn "$dir" "SKILL.md body is about $tokens tokens (guideline 2,500); move detail into references/ unless the length is justified"
}

# The description loads in every session, for every installed skill.
check_description_length() {
  local dir="$1" words
  words="$(frontmatter_field "$REPO/skills/$dir/SKILL.md" description | wc -w | tr -d ' ')"
  [ "$words" -le 80 ] ||
    warn "$dir" "description is $words words (guideline 80); it loads in every session"
}

# Installed skills are machine state, not repo state, so a clash only warns.
check_installed_clashes() {
  local line path
  while IFS= read -r line; do
    path="${line#REFUSE }"; path="${path%%:*}"
    warn "$(basename "$path")" "clash with an installed skill: ${line#REFUSE }"
  done < <("$REPO/scripts/link-skills.sh" --dry-run 2>&1 >/dev/null | grep '^REFUSE' || true)
}

while IFS= read -r dir; do
  check_name_matches_dir "$dir"
  check_root_entries "$dir"
  check_absolute_paths "$dir"
  check_body_size "$dir"
  check_description_length "$dir"
done < <(tracked_skills)
check_readme_rows
check_executables
check_installed_clashes

[ "$errors" -eq 0 ] || exit 1
