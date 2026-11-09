#!/usr/bin/env bash
# Symlink skills from this repo into the local agent skill directories, so edits
# here are live in Claude Code and the Skills CLI without reinstalling.
#
#   scripts/link-skills.sh                  link every skill in skills/
#   scripts/link-skills.sh north-star       link only the named skills
#   scripts/link-skills.sh --unlink         remove links that point into this repo
#   scripts/link-skills.sh --dry-run        print what would happen, change nothing
#   scripts/link-skills.sh --force          replace links that point somewhere else
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS=("$HOME/.claude/skills" "$HOME/.agents/skills")

dry_run=0
unlink=0
force=0
names=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --unlink)  unlink=1 ;;
    --force)   force=1 ;;
    -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        echo "unknown flag: $arg" >&2; exit 2 ;;
    *)         names+=("$arg") ;;
  esac
done

if [ ${#names[@]} -eq 0 ]; then
  for dir in "$REPO"/skills/*/; do
    [ -f "$dir/SKILL.md" ] && names+=("$(basename "$dir")")
  done
fi
if [ ${#names[@]} -eq 0 ]; then
  echo "no skills found in $REPO/skills" >&2; exit 1
fi

run() { if [ "$dry_run" -eq 1 ]; then echo "  would: $*"; else "$@"; fi; }

status=0
for name in "${names[@]}"; do
  src="$REPO/skills/$name"
  if [ ! -f "$src/SKILL.md" ]; then
    echo "skip $name: no $src/SKILL.md" >&2; status=1; continue
  fi
  for target_dir in "${TARGETS[@]}"; do
    link="$target_dir/$name"

    if [ -L "$target_dir" ]; then
      resolved="$(cd "$target_dir" 2>/dev/null && pwd -P || true)"
      case "$resolved" in
        "$REPO"|"$REPO"/*)
          echo "REFUSE $target_dir: it is a symlink into this repo ($resolved)" >&2
          status=1; continue ;;
      esac
    fi

    if [ ! -d "$target_dir" ]; then
      echo "skip $link: $target_dir does not exist"; continue
    fi

    if [ -L "$link" ]; then
      current="$(readlink "$link")"
      if [ "$unlink" -eq 1 ]; then
        case "$current" in
          "$REPO"/skills/*) echo "unlink $link"; run rm "$link" ;;
          *) echo "keep $link: points outside this repo ($current)" ;;
        esac
      elif [ "$current" = "$src" ]; then
        echo "ok $link"
      elif [ "$force" -eq 1 ]; then
        echo "relink $link: was $current"
        run rm "$link"; run ln -s "$src" "$link"
      else
        # Probably an installed skill of the same name. Don't hijack it silently.
        echo "REFUSE $link: points at $current — pass --force to replace it" >&2
        status=1
      fi
    elif [ -e "$link" ]; then
      # A real directory or file: someone's installed copy. Never clobber it.
      echo "REFUSE $link: exists and is not a symlink — move or delete it first" >&2
      status=1
    elif [ "$unlink" -eq 1 ]; then
      echo "absent $link"
    else
      echo "link $link"
      run ln -s "$src" "$link"
    fi
  done
done
exit $status
