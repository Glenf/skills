# Skill rules check spec

Status: approved
Owner: the repo owner (approved 2026-11-19)
Goal: the mechanical rules in `AGENTS.md` are checked by a command and at
commit, not found by a manual review.

## Current state

`AGENTS.md` states the skill rules (`AGENTS.md:7-33`), and nothing checks
them. `scripts/` holds only `link-skills.sh` and `list-skills.sh`; there is no
hook and no CI (`.github/` absent, no active hook in `.git/hooks/`). A review
on 2026-11-19 found by hand: 42 files with an executable mode, and
`implement` and `triage` shadowed by installed third-party skills.

Today the repo passes every hard rule. Two soft limits are exceeded:
`glen-mode/SKILL.md` is about 3,000 estimated tokens (275 lines), and
`find-the-core`'s description is 130 words. Two README rows (`show-me`,
`wet-or-dry`) differ on purpose from `list-skills.sh --md`.

## Desired end state

One command reports every rule breach in the repo, one line per finding, and
exits non-zero only for hard rules. The same command runs on every commit once
the hook is enabled, and refuses the commit on a hard breach. Soft limits
warn and never block. `AGENTS.md` states the limits in context terms and says
how to enable the hook.

## Decisions

| Decision | Chosen | Rejected, and why |
|---|---|---|
| When the check runs | By hand, and from a tracked pre-commit hook | Hand only: most edits are by agents, and a check nobody runs is skipped. Inside `link-skills.sh`: linking is about one machine, the rules are about the repo. |
| Shape | One script, one function per rule | Rules as data with a generic runner: each rule needs its own logic, so the table would hold code; no second consumer. Partly taste. |
| Skill size | A warning, never a block | A hard limit: `~200` is guidance, and a skill may be longer if justified. A blocking hook that fails until the `glen-mode` rewrite teaches `--no-verify`. |
| Size measure | Context: `SKILL.md` body above about 2,500 estimated tokens (bytes ÷ 4); `description:` above 80 words | Lines: `north-star` is 83 lines and about 1,300 tokens, so lines misstate context. A description of 60 words: five skills warn on day one, and a warning that never clears is ignored. |
| README row | One row per skill, linking `skills/<name>`, and no orphan row; text is free | Text equal to `list-skills.sh --md`: rows are written by the user or an agent, and the generated first sentence of a trigger is a poor summary. |
| Clash with an installed skill | A warning, by reusing `link-skills.sh --dry-run` | An error: it depends on the machine, not the repo, so it would block a correct repo. A second clash check: `link-skills.sh` already detects it. |
| Files checked | Git-tracked files only | The working tree: untracked clutter such as `.DS_Store` would fail the check. |

## Acceptance criteria

1. On the repo at the commit that adds the check, it exits 0 and prints
   exactly two warnings: `glen-mode` body size and `find-the-core`
   description length. Proof: run it; read the output and the exit code.
2. Each hard rule, broken on purpose in a throwaway copy of the repo, makes
   the check exit 1 and name the file: a directory that differs from
   `name:`; a stray file at a skill's root; an absolute path in skill text; a
   skill with no README row; a README row with no skill; an executable file
   outside a `scripts/` directory. Proof: one broken copy per rule.
3. In a throwaway clone with the hook enabled, a commit with a hard breach is
   refused, and a commit with only warnings succeeds. Proof: two commits in
   the clone.
4. `AGENTS.md` states the size guideline in context terms, the README-row
   rule, the check's name, and the one-time command that enables the hook.
   It no longer says "Past ~200 lines". Proof: read `AGENTS.md`.

## Seams

| Seam | What it catches | What it misses |
|---|---|---|
| The script's output and exit code | Each rule's logic, levels, and messages | Whether the hook runs it at all |
| A commit in a clone with the hook enabled | Hook wiring and blocking behaviour | Rule cases not in the broken copies |
| `AGENTS.md` text | That the written rules match the checked ones | Whether agents read it |

## Not being done

- Shortening `glen-mode` or `find-the-core`'s description: they warn, and
  each is a separate decision.
- CI: there is none, and the hook covers the one user of this repo.
- Changing how `link-skills.sh` or `list-skills.sh` behave.
- Checking judgment rules: trigger quality, glossary use, drift between
  skills. That is the noted gap for a skill that writes and checks skill text.

## Open risks

- `core.hooksPath` is set per clone. A fresh clone runs no hook until the
  command in `AGENTS.md` is run.
- Bytes ÷ 4 is a rough token estimate. Acceptable for a warning, not for a
  limit.
- `--no-verify` bypasses the hook. The manual run and the warning-only soft
  limits keep the reason to bypass small.

## Research notes

- What do the existing scripts look like? Bash, `set -euo pipefail`, help from
  the header comment, exit 0, 1, or 2 (`scripts/list-skills.sh:7-22`,
  `scripts/link-skills.sh:10-28`). The check follows that style.
- Does a clash check exist? Yes: `link-skills.sh` refuses a link that points
  elsewhere or a real directory in the way (`scripts/link-skills.sh:76-83`),
  and `--dry-run` reports without changing anything. It exits 0 today.
- How is the README table made? `list-skills.sh --md` prints it
  (`scripts/list-skills.sh:63,72`). `diff` against `README.md` shows two rows
  that differ on purpose.
- Which files are executable? Only `scripts/link-skills.sh` and
  `scripts/list-skills.sh` (`find -perm +111`).
- Absolute paths in skill text: none (`grep` for `/Users/`, `~/`, `](/`).
- Sizes: `SKILL.md` bodies range from about 100 to 3,000 estimated tokens;
  descriptions from 11 to 130 words (measured on 2026-11-19).
- Gap: whether the hook should also run in a future CI. Owner: the user, if CI
  is ever added.
