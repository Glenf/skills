# Plan: skill architecture

Status: approved, not started.

This plan supersedes the stage table and build order in
[development-cycle.md](development-cycle.md). Its goal, sizing rules, and
project-pattern lookup still hold.

## Goal

`glen-mode` becomes the approach, not the work. It reads a request, sizes it,
recommends a path, and names the next standalone stage skill. Every stage skill
works alone.

Build up before rewrite. New skills duplicate `glen-mode` where they need its
rules. The existing skill keeps working until the last step, when the
duplication is removed and it becomes the map.

## Decisions

- No prefix except `glen-mode`. The third-party `implement` and `triage` from
  `mattpocock/skills` are uninstalled at a later stage, so these names win.
- Duplication is accepted until the final rewrite.
- Main-path skills are model-invoked; off-path skills are user-invoked.
- A stage ends at its gate and reports its artifact. It does not invoke the
  next stage; `glen-mode` or the user starts it. The flow's arrows are order,
  not automatic calls.
- Triage is a recurring intake gate, not only the first step.
- `design` writes the spec; `spec-and-tasks` writes the tasks.
- **Handover** is the end-of-change report. **Handoff** is a mid-change
  session or agent transfer. This plan uses handover only.
- The finish skill is `prove-and-hand-over`. Bare `handover` is too common a
  name to install globally.
- Intent comes from the record, not from reading code backward. `why`
  is the off-path skill for it.

## Target skills

| Skill | Owns | Does not | Status | Invocation |
|---|---|---|---|---|
| `glen-mode` | The approach: direction, sizing, stage graph, gates, precedence, routing. | Any stage's rules. | rewrite last | model |
| `north-star`, `find-the-core` | Frame: one-sentence goal, the brief. | Design, slicing, code. | exist | model |
| `triage` | Intake for any work item: classify, validate, route, name the next action. | Do the work, estimate, re-interview. | new | model |
| `architecture` | Long-lived structure: module boundaries, dependency direction, ADRs, hot spots, expand–contract. | The shape of one change. | new, off-path | user |
| `design` | One change: facts, judgment questions, two shapes, decisions, acceptance criteria, seams. Writes the spec. | Slice into tasks, write code. | new | model |
| `spec-and-tasks` | Vertical slices, proof per slice, blockers, tasks in the tracker. | Change the design, write code. | new | model |
| `implement` | Build-up and teardown; beats 1–3; checklist; tests, signals, judgment. Calls `wet-or-dry`. | Re-decide the design. | new | model |
| `bug-diagnose` | Reproduce, trace to the cause, name the fix boundary and the acceptance check. | Fix the bug. | new | model |
| `why` | Answer why something is the way it is from the record: commits, PR/MR discussions, issues, ADRs, release notes. Cite authors, mark inferences, name what the record does not answer. | Infer intent from the code, or propose a change. | new, off-path | user |
| `wet-or-dry` | Simplify: duplication and abstraction verdicts. | Bug hunts, style, whole-repo audits. | exist | model |
| `code-review` | Three independent lenses, plus a security lens when the diff touches a trust boundary; findings with severity, confidence, evidence. | Apply fixes. | exist; add security lens | model |
| `prove-and-hand-over` | Prove the outcome, run the review, operate, report, write the PR/MR body. | Implement. | new | model |
| `prototype` | Settle an empirical fork with throwaway code. | Production code. | new, off-path | user |
| `hillclimb` | Sustained improvement of one metric against a target: baseline, frozen bench, one change per measurement, keep or revert, decision log. | A one-off fix, or stacking untested changes. | new, off-path | user |
| `retro` | Turn each lesson into its cheapest enforcing home: a test, lint rule, or type first; then a skill or `AGENTS.md`; then an ADR, glossary entry, or doc. Prune stale lessons. Review skill text when the lesson is about a skill. | Fix the change. | new | user |

## Flow

```
any work item
     │
   triage
     ├── question ───────────────→ answer / show-me
     ├── mechanical ─────────────→ implement → prove-and-hand-over
     ├── bug ────────────────────→ bug-diagnose → implement
     │                             → prove-and-hand-over
     ├── feature / refactor ─────→ design → spec-and-tasks → implement
     │                             → prove-and-hand-over
     ├── metric target ──────────→ hillclimb → prove-and-hand-over
     └── structural ─────────────→ architecture → design → ...
```

- `find-the-core` runs before `design` when the goal is unclear.
- `prototype` runs when an empirical question blocks design.
- `hillclimb` runs when the goal is a measurable target, not a one-off fix.
- `why` runs when design, diagnosis, or architecture needs intent the
  code cannot show.
- `wet-or-dry` is called by `implement`.
- `code-review` is called by `prove-and-hand-over`, and also runs alone.

The arrows show order, not automatic invocation. Each stage reports and stops.
`spec-and-tasks` in particular never starts `implement` or `triage`.

## Triage

Triage is the intake gate for any work item, from any source. It runs at the
start of a change and whenever new work arrives.

| Source | What triage decides |
|---|---|
| User request | Kind, size, path, next action. |
| Tracker issue | Duplicate? Actionable? Needs frame, design, or diagnosis? |
| Spec task | Blockers done? Still valid? Is this the next frontier task? |
| Review finding | Fix now, defer, or declare. |
| Retro lesson | Which home: skill, `AGENTS.md`, ADR, glossary. |
| Bug report | Reproduce first? Severity? Route to `bug-diagnose`. |
| Performance goal | Is there a metric, target, baseline, and bench? Route to `hillclimb`. |
| PR comment | Change request, question, or noise? |

It answers:

- What is this: question, mechanical change, bug, feature, refactor, metric
  campaign, or structural work?
- Is it still valid, or already done or duplicated?
- Is it actionable now, or blocked on a decision, fact, or another task?
- How big is it, and what is the blast radius?
- Which path does it take, and which stages are skipped?
- What is missing, and who owns that?
- What is the single next action?

The verdict is one of: **do now**, **defer**, **reject**, **duplicate**, or
**needs framing/info**.

Triage picks the next ready task from the frontier. It does not rank priority
across unrelated work; priority stays with the user or the project's tracker.

Generated work must be triage-ready:

- A task from `spec-and-tasks` carries its behaviour, acceptance check, proof,
  seam, blockers, and status.
- A finding from `code-review` carries severity, confidence, `file:line`, and
  whether it must be fixed or can be declared.
- A lesson from `retro` names its proposed home.
- An external ticket carries enough context to classify without a new
  interview.

## Design

`design` settles the shape of one change before slicing or code.

1. Read the goal sentence, the brief, the code, the glossary, ADRs, and any
   research notes.
2. Find the facts. Ask neutral questions, answer them with `file:line`
   evidence, and state gaps. Do not propose solutions while gathering facts.
3. Split the open forks. An empirical fork goes to `prototype`. A judgment
   call goes to the user, with options and a recommendation.
4. Sketch two different shapes: types, signatures, and module boundaries.
   Pick the one where each piece of state has one owner, each task has one way
   to do it, and callers need to know least. Record the rejected shape and
   why.
5. Confirm the shape before writing. Write the design down for review: the
   chosen shape, what the change includes and leaves alone, the decisions and
   risks that could move it, and the acceptance criteria. The design note stays
   `Status: draft` until the human confirms it. No spec, task, tracker, or code
   writes before that confirmation.
6. Write the spec at `Status: draft`:
   - current state and desired end state;
   - decisions, with the rejected options;
   - acceptance criteria, each observable from outside the code and false
     before the change;
   - seams, with what each catches and misses;
   - what is not being done;
   - open risks;
   - research notes as an appendix.

The spec becomes `Status: approved` only when the human approves it; tasks are
cut only from an approved spec. The shape confirmation in step 5 is the
decision gate. Spec approval is a light check that the record matches it, not
a second full stop.

## Spec and tasks

`spec-and-tasks` turns an approved spec into work.

- Cut vertical slices. The first is the tracer bullet: the smallest
  end-to-end path on real data.
- Each slice names the behaviour it delivers, its boundaries, the files it
  touches, the key signatures or types, its acceptance check, its proof, its
  seam, and its blockers.
- A slice ends green and fits one fresh context.
- Order the slices so the sequence proves itself: failing test first,
  subtraction before reshape, baseline before treatment.
- A wide refactor is the exception to vertical slicing: expand, migrate in
  batches, then contract.
- Before writing any task body, write the breakdown down for review as titles,
  one-line descriptions, and boundaries, with blockers. The human confirms the
  shape. No full task body, tracker, or code writes before that confirmation.
- One task per slice in the project's tracker, in dependency order.

## Implementation

`implement` carries the current `glen-mode` discipline for now, including its
references. It classifies build-up versus teardown, runs the three beats, and
keeps the checklist. It calls `wet-or-dry` for simplification.

It does not re-decide the design. A design that fails in code goes back to
`design`.

## Bug diagnosis

`bug-diagnose` runs before a fix.

1. Reproduce the defect on the real surface; capture the failing evidence.
2. State expected versus actual.
3. Trace backward to the first incorrect assumption or violated invariant.
4. Check sibling callers that share the cause.
5. Name the cause in one sentence and the boundary of the fix.
6. Say whether this is ordinary breakage or drift.
7. Produce the acceptance check the fix must satisfy.

It does not fix. Cannot reproduce means saying so, not guessing.

## Why, from the record

`why` answers why the target is the way it is. It answers from the
record, not the code.

### Metadata

```yaml
---
name: why
description: >
  Use for "why does X work this way", "why we picked Y", design rationale,
  regressions, postmortems, or data-backed thresholds. Returns a cited read
  of decisions and tradeoffs. Not for how the code works today; read the code
  for that.
disable-model-invocation: true
---
```

1. Name the target: the file, module, behaviour, or decision in question.
2. Read the record: the commits that introduced it and every later change,
   their PR/MR discussions, issues, ADRs, release notes, and docs. Follow the
   trail backward and forward. If the trail is thin, say which sources are
   missing.
3. Cite what the authors wrote: commit SHAs, PR/MR numbers, quoted decisions.
4. Mark your own inferences as inferences. Never present a reconstruction as
   what the authors meant.
5. Say what the record does not answer. A gap is a finding, not permission to
   reverse-engineer intent from the code.

Code is the authority for what exists. The record is the authority for why.
When they disagree, say so; the disagreement is usually the useful part.

The skill feeds `design`, `bug-diagnose`, and `architecture`. It does not
propose a change.

## Hillclimb

`hillclimb` is a sustained campaign for one measurable target. A one-off fix
belongs in `implement`; this is the loop. The metric and the experiment's
integrity are the skill's responsibility. Code changes can be delegated, but
the diff is reviewed and the measurement is not.

1. Ground the workload first. Trace the target, name the dimensions that can
   move the result (data size, history, state, concurrency), and choose a case
   that reproduces the complaint. No reproducing case means fixing the
   reproduction, not hillclimbing.
2. Fix one metric, the direction that counts as better, and a stop predicate.
   Pair a target with a floor on attempts so a lucky early win cannot end the
   run. Use the user's numbers; otherwise agree them.
3. Build the bench and prove it is sensitive. Run contrasting
   workloads: the target case must reproduce the symptom, and easier cases
   must separate as expected. Freeze the bench. It prints the metric, its
   error count, and the work done; it samples enough to clear the noise (the
   median of N runs, not one run). Record the baseline and a green regression
   gate before any change.
4. Keep a decision log: one row per attempt with hypothesis, change, before,
   after, delta, gate result, verdict, and note. Read it before each attempt.
   Keep it out of the tree.
5. Loop one hypothesis at a time. Name the mechanism it changes, not "try
   memoising". Change, measure, run the gate. Keep only a win past noise with
   the gate green; otherwise revert the change in full and log it.
6. Commit each accepted win on its own, staging only the files changed.
7. Push past the first plateau. On a stall, pivot category, combine
   near-misses, reread the source, or try a structural change. Correctness and
   simplicity outrank the number. Revert a win that breaks behaviour; keep a
   simplification that holds the number.
8. Stop when the predicate is met, or when the remaining ideas are marginal
   and not worth their cost. Never relax the predicate. Surface a stall
   instead of spinning.

Accepted commits go to `prove-and-hand-over`. The reply reports the metric and
target, baseline to final with the delta, kept and reverted counts, each
accepted fix on one line, the decision log path, and the best idea left.

## Handover

`prove-and-hand-over` ends the change.

- Prove each acceptance criterion with a direct check on the real surface,
  not only a passing test.
- Run `code-review`; every P0/P1 finding is fixed or declared.
- Keep the log, commit in small ordered commits, reclaim the worktree.
- Produce the handover report from `handover.md`.
- Write the PR/MR body: why, what, how it was proved, what is not proved,
  and a `show-me` change outline.

## Artifacts

- The **spec** is written by `design`, in the project's spec location.
- The **tasks** are written by `spec-and-tasks`, in the project's tracker.
- Where those live is found in this order, first hit wins:
  1. `AGENTS.md`, `CLAUDE.md`, or `CONTRIBUTING.md`.
  2. Existing artifacts: `docs/specs/`, `docs/plans/`, ADR folders, PR/MR
     templates.
  3. The git remote host: GitHub uses `gh`, GitLab uses `glab`.
  4. Ask the user. Do not invent a location.

## Build order

Leaves first, root last. Each step ships and is used on a real change before
the next starts.

1. `design` — produces a spec for a real change.
2. `spec-and-tasks` — consumes that spec and publishes tasks.
3. `implement` — duplicates the current beats and is used on a real task.
4. `triage` — routes a request, a tracker issue, a spec task, and a review
   finding.
5. `bug-diagnose` — reproduces a real bug and names its cause.
6. `prove-and-hand-over` — proves a real change and produces the report.
7. `retro` — turns lessons from that finished change into enforcement.
   Early, so every later step compounds.
8. `why` — reads the record for a real decision and names its gaps.
9. `architecture` — used on a structural question.
10. `prototype` — settles one empirical fork.
11. `hillclimb` — runs a real metric campaign against a target.
12. Rewrite `glen-mode` as the map; link the stages; delete the duplicated
    content.

## What stays untouched

Until their step, `glen-mode` and its references keep working exactly as they
do today. `north-star`, `find-the-core`, `wet-or-dry`, `code-review`,
`show-me`, `ste-report`, `wait-what`, and `start-with-why` are not edited by
this plan.

New skills are not linked from `glen-mode` until they are proven. Duplication
is deliberate and temporary.

## Risks

- **Two sources of truth during build-up.** `glen-mode` and `implement` both
  describe the beats. Mitigation: the new skills are tested directly and are
  not linked until their step.
- **Triage becomes a second discovery pass.** Mitigation: triage-ready inputs
  and a firm rule that triage routes, it does not investigate.
- **Design and spec-and-tasks blur.** Mitigation: design owns behaviour and
  shape; spec-and-tasks owns order and proof.
- **Context cost.** Mitigation: off-path skills are user-invoked.
- **The record is thin.** `why` must name the gap, not reconstruct
  intent from the code. A disagreement between record and code is reported,
  not resolved silently.
- **The metric is gamed.** A hillclimb win counts only on the real surface,
  past noise, with the regression gate green. Code inspection is not a win.
- **The hillclimb never ends.** The stop predicate includes a floor on
  attempts; a stall is surfaced, and the predicate is never relaxed to meet
  it.

## Open

- Does triage ever rank priority across unrelated work? Default: no.
- Does `design` grow its own research reference, or call a future research
  skill? Default: it carries the method for now.
- The `architecture` versus `design` boundary needs one worked example before
  step 9.
- No skill writes or checks skill text, in the style of `writing-for-agents`.
  The `AGENTS.md` rules have no check, and cross-skill drift (terms, hand-offs,
  examples) is found only by a manual review. Shape not decided: write, check,
  or both; which rules go to a script.
