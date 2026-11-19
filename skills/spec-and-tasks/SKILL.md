---
name: spec-and-tasks
description: >
  Turn an approved spec into vertical slices and one tracker task per slice,
  each with boundaries, an acceptance check, a proof, a seam, and blockers. Use
  when design has approved a spec and the change needs ordering, when a change
  must be cut into slices before code, or when spec tasks need publishing to
  the tracker. Not for writing or revising the spec, estimating, or code.
argument-hint: "[spec path | change name]"
---

# spec-and-tasks

A spec says what becomes true. It does not say what to do first. The order is
the argument: each slice proves the one before it, and the tracker carries that
order as blockers. This stage turns an approved spec into that sequence of
tasks. It never reopens the spec, and it stops when the tasks are published.

References: [`slicing.md`](references/slicing.md) for vertical cuts, the tracer
bullet, sizing, ordering, and wide refactors; [`tasks.md`](references/tasks.md)
for the task template, blockers, the frontier, tracker lookup, and publication.

## 1. Confirm the input

Read the spec whole before cutting. It is usable when:

- its status says approved;
- it has acceptance criteria, each with a proof;
- it has seams, each with what it catches and misses.

Stop and say what is missing when the spec is absent, still a draft, or carries
an unresolved blocking question. Send it back to `design`. Do not fill a gap by
deciding it here: a decision made while slicing is a design decision in
disguise.

Read the code in the affected area too. The spec names behaviour; the code says
where the seams actually are. A slice that cannot be cut without changing the
design stops here and returns to `design`.

## 2. Find the tracker

Never invent a location. First hit wins:

1. `AGENTS.md`, `CLAUDE.md`, or `CONTRIBUTING.md`.
2. Existing tracker conventions: an issue template, a `docs/tasks/` folder,
   past issues that show the house shape.
3. The git remote host: GitHub uses `gh`, GitLab uses `glab`.
4. Ask the user.

Say where the tasks will go. A location the project states is used as is, in
one sentence before slicing. A location you had to ask for is confirmed before
publication.

## 3. Cut vertical slices

A slice is a thin end-to-end path that delivers one behaviour: input, path,
observable result. It is not a layer. "Add the schema", "write the endpoint",
"add tests" are three tasks that prove nothing alone.

- The first slice is the tracer bullet: the smallest end-to-end path on real
  data. It proves the wiring, not the feature.
- Each slice is demoable or verifiable on its own, and fits one fresh context.
- A slice whose title needs "and" is two slices.
- Keep the seam in the slice. A slice with no observable result is a layer
  wearing a path's clothes.
- A wide refactor is the exception: expand, migrate in batches, then contract.
  Do not force a tracer bullet onto it.

Detail and examples: [`slicing.md`](references/slicing.md).

## 4. Order the slices

The sequence must prove itself. Each slice ends green before the next starts.

- Failing test before the fix: the reproduction lands first, so the fix has
  something to turn green.
- Subtraction before the reshape: delete what the new shape replaces, then
  move what remains.
- Baseline before the treatment: measure the current state before a slice
  changes it.
- A blocker is a task whose output the next one needs, not a task that merely
  comes first in a list.

## 5. Confirm the shape

Before writing any task body, write the breakdown down for review: a numbered
list, one short block per slice:

- **Title**: one behaviour, no "and".
- **Description**: one sentence on what it delivers.
- **Boundaries**: what it includes and what it deliberately leaves to another
  slice.
- **Blocked by**: the task number, or "none".

Do not write the full task bodies, tracker entries, or code. Link the spec for
detail. Ask whether the shape, granularity, and blockers are right. Expect a
merge, a split, or a reorder; apply it and show the list again. Iterate until
the human confirms. No full task body, tracker, or code writes before that
confirmation.

## 6. Write one task per slice

Only after the shape is confirmed, write each task. Each task carries: the
behaviour it delivers; its boundaries, what it includes and what it leaves to
another slice; the acceptance criterion or criteria it closes; its acceptance
check, observable from outside; its proof on the real surface; its seam with
what it catches and misses; likely files as orientation only; its blockers or
"none"; anything outside the breakdown it is waiting on; and its status.

Status is `ready` when every blocker is done and nothing outside the breakdown
is still waiting, otherwise `blocked`. Files are orientation, never a contract:
a later read of the code wins.

Template and field standards: [`tasks.md`](references/tasks.md).

## Gate

- Every acceptance criterion in the spec is closed by at least one task. Name
  the criterion's number in the task, not a paraphrase.
- Every task has an observable check, a proof, a seam, and blockers. An
  external wait is named, and the task is blocked until it clears.
- Every task states its boundaries: what it includes and what it leaves to
  another slice.
- No task is a layer.
- No task hides a design decision. If one does, stop and return to `design`.
- The human confirmed the shape before any task was written.

## 7. Publish

One task per slice, in dependency order, blockers first.

- Use the tracker's native blocking links where it has them; otherwise write
  `Blocked by: <task>` in the body.
- Do not close, edit, or comment on the parent spec.
- Publishing twice must not create duplicates: look for the task before
  creating it.
- Record each created task's reference against its slice, for the report.

## 8. Stop and report

End the stage with the task list, its references, and the frontier: the tasks
whose status is `ready`. Report them to the user.

Do not invoke `implement` or `triage`, and do not start either. The next stage
runs only when the user or `glen-mode` asks for it.

## Boundaries

`spec-and-tasks` owns the order and the proof per slice of one change. It does
not own:

- **The spec, its criteria, or its seams**: `design` writes them. A gap goes
  back there.
- **The implementation**: build-up, teardown, beats, tests, and seam method
  belong to `implement` and `glen-mode`. This stage names the seam to test at;
  it does not say how to test it.
- **Estimation, priority, and ownership**: the user and the tracker hold them.
  Blockers order work; they do not rank it.
- **Long-lived structure**: `architecture`.
- **Code, review, or fixes**: never in this stage.
- **The next stage**: it reports the task list and the frontier. It does not
  invoke `implement`, `triage`, or any other skill.
