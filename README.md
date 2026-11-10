# skills

Agent skills by [@Glenf](https://github.com/Glenf). Installable with the
[Skills CLI](https://skills.sh).

```bash
npx skills add Glenf/skills            # pick interactively
npx skills add Glenf/skills/<name>     # install one
npx skills update                      # update everything installed
```

## Skills

| Skill | What it does |
| ----- | ------------ |
| [code-review](skills/code-review) | Review a code change on three independent lenses — correctness, standards, spec — run as parallel sub-agents, reporting findings with severity, confidence, and file:line evidence. |
| [find-the-core](skills/find-the-core) | Drill into the core of a task before executing it, using Simon Sinek's Golden Circle (Why → How → What) fused with the journalist's 5 W's (Who / What / When / Where / Why). |
| [glen-mode](skills/glen-mode) | Engineering discipline for a code change from first read to handover: make it work, make it right, follow the practice. |
| [north-star](skills/north-star) | Distill a pile of wants into one north star sentence, with the Five W's beneath it. |
| [ste-report](skills/ste-report) | Write findings and reports as one line per finding — location, label, problem, fix — in plain language (ISO 24495-1) and ASD-STE100 Simplified Technical English. |
| [wait-what](skills/wait-what) | That last message did not land: re-pitch it in plain language. |

## Layout

Flat: one directory per skill under `skills/`, each with a `SKILL.md`.

```
skills/<name>/
├── SKILL.md          # the skill: frontmatter + instructions
├── references/       # detail the agent reads only when it needs to
├── scripts/          # executables the skill runs
└── assets/           # templates, fixtures, boilerplate
```

## Local development

```bash
scripts/list-skills.sh            # what's in here, and where it's linked
scripts/list-skills.sh --names    # names only, for piping
scripts/list-skills.sh --md       # regenerate the table above

scripts/link-skills.sh            # link every skill into both agent dirs
scripts/link-skills.sh north-star # link one
scripts/link-skills.sh --dry-run  # show what would change
scripts/link-skills.sh --unlink   # remove links pointing into this repo
```

`link-skills.sh` symlinks into `~/.claude/skills` (Claude Code) and
`~/.agents/skills` (Skills CLI, Codex and other Agent Skills harnesses), so a
`git pull` is all it takes to update what's installed. It never overwrites a
real directory, and needs `--force` to replace a symlink pointing elsewhere —
that is usually a skill installed under the same name.

## Contributing to my own repo

Conventions live in [CLAUDE.md](CLAUDE.md).

## License

MIT — see [LICENSE](LICENSE).
