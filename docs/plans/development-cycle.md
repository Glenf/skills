# Plan: the development cycle

Status: draft, not started.

## Goal

One cycle for a code change, from first idea to lessons learned, built from
skills in this repo. `glen-mode` becomes the entry point: it names the stages,
the gate that ends each one, and the skill that runs it. Each stage skill also
works on its own when invoked directly.

All new stage skills are written from scratch. Installed third-party skills
are not a source.

## Stages

| # | Stage | Skill | Gate (done when) | Hands on |
|---|---|---|---|---|
| 0 | Frame | `find-the-core`, `north-star` (exist) | The goal fits in one sentence, and the user confirms it. | Goal sentence |
| 1 | Prototype | new | The one question the prototype was built for has an answer. The prototype code is discarded or parked outside product code. | Answer and evidence |
| 2 | Plan | new | Every decision the change needs is made, or named as open with an owner. Risks and what is out of scope are written down. | Decision list |
| 3 | Spec and tasks | new | The spec has acceptance criteria someone can observe. Each task is a vertical slice with its own acceptance check and test seam. | Spec and task list in the project's tracker |
| 4 | Implement | `glen-mode` content today | Beats 1–2 gates hold for the task. | Diff |
| 5 | Simplify | `wet-or-dry` (exists) | Every copy and abstraction in the diff has a verdict. | Simplified diff |
| 6 | Review | `code-review` (exists) | Every P0/P1 finding is fixed or declared. | Review report |
| 7 | PR/MR | new | The body says why, what, how it was proved, and what is not proved, with a `show-me` change outline. It follows the project's template. | Open PR/MR |
| 8 | Retrospective | new | Each lesson has a home: a skill, `AGENTS.md`, an ADR, or the glossary. Lessons without a home are dropped. | Edits to those homes |

Stages 4–6 repeat for each task. Stage 7 opens once per branch, or once per
task when the project merges tasks one by one.

### Off the main path

| Stage | Skill | When |
|---|---|---|
| Architecture | new | Not for every change. Triggered by a retro lesson, by repeated review findings in one area, or by the user. Works on hot spots in the git history. |
| Show | `show-me` (exists) | Any stage, whenever a person needs to see the work: the PR/MR change outline, an architecture candidate, a data flow, a design. |
| Code design | new | Shared vocabulary for module design: module, interface, depth, seam, deletion test. Planning, implementation, `wet-or-dry`, and architecture all use it. |

## Sizing: not every change runs every stage

The entry step picks the path before any work starts:

- **One-line or mechanical change** — implement, then the PR.
- **Bug fix** — implement (fix the cause), review, then the PR.
- **Feature or refactor** — the full cycle. Prototype only when an open
  question blocks the plan.

The user can name a stage to start from ("we have a spec, implement task 3").

## Following project patterns

Specs, tasks, and PRs go where the project already keeps them. One shared
reference finds that place, and stages 3, 7, and 8 use it. Lookup order, first
hit wins:

1. What `AGENTS.md`, `CLAUDE.md`, or `CONTRIBUTING.md` says.
2. Existing artifacts, such as `docs/specs/`, `docs/plans/`, ADR folders,
   `.github/pull_request_template.md`, and `.gitlab/merge_request_templates/`.
3. The git remote host: GitHub uses `gh`, GitLab uses `glab`.
4. If nothing matches, ask the user. Do not invent a location.

## Changes to glen-mode

- `SKILL.md` becomes the cycle map: the sizing step, the stage table with its
  gates, hand-offs, and precedence. It stays short and loads on every trigger.
- The current implementation discipline (the three beats, the checklist, the
  references) moves to stage 4. See open question 1 for where.
- The "Review before handover" step and `handover.md` connect to stages 6 and 7
  instead of ending the skill.

## Build order

1. The cycle map in `glen-mode`, with the sizing step and the project-patterns
   lookup. Existing stages get linked; missing ones are marked as not yet
   available.
2. Spec and tasks, because they feed stage 4 directly.
3. PR/MR, using the `handover.md` content.
4. Retrospective.
5. Plan, then prototype.
6. Code design, then architecture, because architecture uses the design
   vocabulary.

Each step ships on its own and is used for real before the next one starts.

## Open questions

1. **Where does the implementation discipline go?** Either a new stage skill
   (model-invoked, so it also runs alone) or `glen-mode/references/implement.md`
   (runs only through the cycle).
2. **Names.** Stage skills share a global namespace with other Skills CLI
   installs. Use a common prefix (for example `glen-spec` or `glen-retro`), or
   pick a distinct name for each?
3. **Invocation.** A stage that `glen-mode` must reach needs a `description`,
   which costs context on every turn. Seven new descriptions add up. Should some
   stages be user-invoked only, with `glen-mode` reading their file directly?
4. **Where do code-design and project-patterns live?** Several skills need
   them. Each could be a model-invoked reference skill, or a file in one skill
   that the others point to.
5. **Retro scope.** Is the retrospective per change or per session, and does it
   edit skills in this repo directly or only propose the edits?
