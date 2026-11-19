#!/usr/bin/env bash
# Seam test for scripts/check-skills.sh: output and exit code on the real repo and on throwaway clones broken one rule at a time.
#
#   scripts/test-check-skills.sh            test against the repo containing this script
#   scripts/test-check-skills.sh <repo>     test against <repo>
set -uo pipefail

REPO="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SCRIPT="$REPO/scripts/check-skills.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
fails=0

expect() { # <label> <want-exit> <grep-pattern-or-empty> <dir>
  local label="$1" want="$2" pat="$3" dir="$4" out code
  out="$(bash "$dir/scripts/check-skills.sh" 2>&1)"; code=$?
  if [ "$code" -ne "$want" ]; then
    echo "FAIL $label: exit $code, want $want"; echo "$out" | sed 's/^/    /'; fails=$((fails+1)); return
  fi
  if [ -n "$pat" ] && ! grep -qE "$pat" <<<"$out"; then
    echo "FAIL $label: output lacks /$pat/"; echo "$out" | sed 's/^/    /'; fails=$((fails+1)); return
  fi
  echo "ok   $label"
}

clone() { # fresh clone of committed state, plus the working-copy script
  local d="$WORK/$1"
  git clone -q "$REPO" "$d"
  mkdir -p "$d/scripts"; cp "$SCRIPT" "$d/scripts/check-skills.sh" 2>/dev/null || true
  echo "$d"
}

# The real repo passes.
expect "repo passes" 0 "" "$REPO"
out="$(bash "$SCRIPT" 2>&1)"; grep -q '^ERROR' <<<"$out" && { echo "FAIL repo prints ERROR"; fails=$((fails+1)); }

# Directory renamed: name: no longer matches.
d="$(clone renamed)"; git -C "$d" mv skills/wait-what skills/wait-whut
expect "renamed dir" 1 '^ERROR wait-whut: .*skills/wait-whut/SKILL.md' "$d"

# name: edited to differ from the directory.
d="$(clone edited)"; sed -i '' 's/^name: wait-what$/name: wait-who/' "$d/skills/wait-what/SKILL.md"
expect "edited name" 1 '^ERROR wait-what: .*wait-who' "$d"

# name: missing.
d="$(clone missing)"; sed -i '' '/^name: wait-what$/d' "$d/skills/wait-what/SKILL.md"
expect "missing name" 1 '^ERROR wait-what: ' "$d"

# Quoted name: still matches.
d="$(clone quoted)"; sed -i '' 's/^name: wait-what$/name: "wait-what"/' "$d/skills/wait-what/SKILL.md"
expect "quoted name passes" 0 "" "$d"

# Untracked skill with a wrong name: ignored, because only tracked files count.
d="$(clone untracked)"; mkdir -p "$d/skills/stray"; printf -- '---\nname: other\n---\n' > "$d/skills/stray/SKILL.md"
expect "untracked skill ignored" 0 "" "$d"

# Stray file at a skill's root.
d="$(clone stray-file)"; echo x > "$d/skills/wait-what/notes.md"; git -C "$d" add skills/wait-what/notes.md
expect "stray root file" 1 '^ERROR wait-what: .*skills/wait-what/notes.md' "$d"

# Stray directory at a skill's root.
d="$(clone stray-dir)"; mkdir -p "$d/skills/wait-what/examples"; echo x > "$d/skills/wait-what/examples/a.md"; git -C "$d" add skills/wait-what/examples
expect "stray root dir" 1 '^ERROR wait-what: .*skills/wait-what/examples' "$d"

# Allowed directory at a skill's root.
d="$(clone allowed-dir)"; mkdir -p "$d/skills/wait-what/references"; echo x > "$d/skills/wait-what/references/a.md"; git -C "$d" add skills/wait-what/references
expect "references/ allowed" 0 "" "$d"

# Untracked stray file: ignored.
d="$(clone untracked-stray)"; echo x > "$d/skills/wait-what/notes.md"
expect "untracked stray ignored" 0 "" "$d"

# Absolute paths in skill text, one form per clone.
d="$(clone abs-users)"; echo 'See /Users/someone/x.md' >> "$d/skills/wait-what/SKILL.md"
expect "absolute /Users/ path" 1 '^ERROR wait-what: .*skills/wait-what/SKILL.md:[0-9]+' "$d"
d="$(clone abs-home)"; echo 'See ~/.claude/skills' >> "$d/skills/wait-what/SKILL.md"
expect "absolute ~/ path" 1 '^ERROR wait-what: .*skills/wait-what/SKILL.md:[0-9]+' "$d"
d="$(clone abs-link)"; echo 'See [x](/docs/x.md)' >> "$d/skills/wait-what/SKILL.md"
expect "absolute link" 1 '^ERROR wait-what: .*skills/wait-what/SKILL.md:[0-9]+' "$d"

# README row missing for a skill.
d="$(clone no-row)"; sed -i '' '/](skills\/wait-what)/d' "$d/README.md"
expect "missing README row" 1 '^ERROR wait-what: .*README' "$d"

# README row for a skill that does not exist.
d="$(clone orphan-row)"; echo '| [ghost](skills/ghost) | Nothing. |' >> "$d/README.md"
expect "orphan README row" 1 '^ERROR ghost: .*README' "$d"

# Executable file outside scripts/ or .githooks/.
d="$(clone exec-md)"; chmod +x "$d/skills/wait-what/SKILL.md"; git -C "$d" add skills/wait-what/SKILL.md
expect "executable SKILL.md" 1 '^ERROR wait-what: .*skills/wait-what/SKILL.md' "$d"
d="$(clone exec-root)"; chmod +x "$d/README.md"; git -C "$d" add README.md
expect "executable README.md" 1 '^ERROR repo: .*README.md' "$d"

# Executables where they belong.
d="$(clone exec-ok)"; mkdir -p "$d/skills/wait-what/scripts" "$d/.githooks"
printf '#!/bin/sh\n' > "$d/skills/wait-what/scripts/run.sh"; printf '#!/bin/sh\n' > "$d/.githooks/pre-commit"
chmod +x "$d/skills/wait-what/scripts/run.sh" "$d/.githooks/pre-commit"; git -C "$d" add skills/wait-what/scripts .githooks
expect "executables in scripts/ and .githooks/" 0 "" "$d"

# Warnings on the repo: exactly the two known ones.
out="$(bash "$SCRIPT" 2>&1)"
want=$'WARN find-the-core\nWARN glen-mode'
got="$(grep '^WARN' <<<"$out" | cut -d: -f1 | sort)"
if [ "$got" = "$want" ] && grep -q '^WARN glen-mode: .*token' <<<"$out" && grep -q '^WARN find-the-core: .*description' <<<"$out"; then
  echo "ok   repo warns on glen-mode body and find-the-core description only"
else
  echo "FAIL repo warnings"; echo "$out" | sed 's/^/    /'; fails=$((fails+1))
fi

# Long body: warns, exit unchanged.
d="$(clone big-body)"; head -c 12000 /dev/zero | tr '\0' 'x' >> "$d/skills/wait-what/SKILL.md"
expect "large body warns" 0 '^WARN wait-what: .*token' "$d"

# Long description: warns, exit unchanged.
d="$(clone long-desc)"; words="$(printf 'word %.0s' $(seq 90))"
sed -i '' "s/^description: .*/description: $words/" "$d/skills/wait-what/SKILL.md"
expect "long description warns" 0 '^WARN wait-what: .*description' "$d"

# Clash with an installed skill in a fake HOME: warns, exit unchanged.
d="$(clone clash)"; fake="$WORK/home"; mkdir -p "$fake/.claude/skills/wait-what"
HOME="$fake" expect "installed clash warns" 0 '^WARN wait-what: .*clash' "$d"

# Help and bad flag.
bash "$SCRIPT" --help | grep -q 'check-skills.sh' && echo "ok   --help" || { echo "FAIL --help"; fails=$((fails+1)); }
bash "$SCRIPT" --bogus >/dev/null 2>&1; [ $? -eq 2 ] && echo "ok   bad flag exits 2" || { echo "FAIL bad flag"; fails=$((fails+1)); }

echo "$fails failure(s)"; [ "$fails" -eq 0 ]
