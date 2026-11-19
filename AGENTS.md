# Conventions for this repo

This repo publishes agent skills for the Skills CLI (`npx skills`), plus the
tooling and docs that maintain them (`scripts/`, `.githooks/`, `docs/`). It
contains nothing else — no application code, no client material.

## Rules

- **Flat layout.** `skills/<name>/SKILL.md`. No category directories.
- **Directory name == `name:` in frontmatter.** The CLI installs by name, so a
  mismatch breaks `add` and `update`.
- **Names are global.** Installs land flat in `~/.agents/skills/<name>/` next to
  everyone else's skills. Pick a name unlikely to collide; avoid bare words like
  `research`, `review`, `plan`.
- **Harness built-in skills do not count.** Skills that ship inside a harness
  (Claude Code, Codex, OpenCode, or any other) are not used, so choose names
  and `description:` triggers here as if they did not exist — the same name as
  a built-in is fine.
- **Only `SKILL.md` at a skill's root.** Everything else goes in `references/`,
  `scripts/`, `assets/`, or `agents/` (harness metadata, such as Codex's
  `agents/openai.yaml`).
- **Mind the context.** The measure is context, not lines. The `SKILL.md` body
  loads when the skill triggers: past about 2,500 tokens, move detail into
  `references/` and link to it. The `description:` loads in every session for
  every installed skill: keep it under about 80 words. Both are guidance, not
  hard limits — a longer skill is fine when justified, and
  `scripts/check-skills.sh` warns, never blocks. Never duplicate a reference's
  content in `SKILL.md`.
- **Relative paths only.** Write `references/foo.md`, never an absolute path —
  the install location differs from the repo location.
- **`description:` is the trigger.** Write it as the conditions under which the
  skill should fire, in the words a user would actually use. It is the only part
  of the skill the agent sees before deciding to load it.
- **Use the glossary.** Skills use the terms in `GLOSSARY.md`. When a skill
  introduces or sharpens a term, update the glossary in the same change.
- **Specs and tasks have a home.** Specs go in `docs/plans/`, tasks in
  `docs/tasks/`, one file per task. `design` and `spec-and-tasks` look here
  first.
- **No confidential content.** This repo is public. No client names, no internal
  company material, no credentials, no personal data.

## Frontmatter

Required:

```yaml
---
name: my-skill
description: Use when <situation>. Covers <scope>. Not for <exclusion>.
---
```

Optional, when they earn their place: `argument-hint`, `user-invocable`,
`disable-model-invocation`, `allowed-tools`, `license`, `version`.

## Adding a skill

1. `mkdir -p skills/<name>` and write `SKILL.md`.
2. Add one row for the skill to the table in `README.md`. Every skill needs
   exactly one row; the row text is free — write it yourself or let an agent
   write it. `scripts/list-skills.sh --md` prints a starting point.
3. Run `scripts/link-skills.sh` to symlink it into `~/.claude/skills/` and
   `~/.agents/skills/`, so edits here are live in both at once.

`scripts/check-skills.sh` checks the mechanical rules in this file: errors
block, warnings (context size, description length, installed-skill clashes)
never do. A tracked pre-commit hook runs it; enable it once per clone with
`git config core.hooksPath .githooks`.
