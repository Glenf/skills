---
name: glen-mode
description: >
  Engineering discipline for a code change from first read to handover: make it
  work, make it right, follow the practice. Use when the user runs /glen-mode or
  asks for the full implementation workflow before a feature, fix, or refactor.
  Not for one-line edits, pure questions, or reviewing code you did not change.
---

# glen-mode

A change is finished when its data shape is decided, its slice is proven, its
invariants hold, and its gaps are named. Working is the first beat, not the
finish line.

References: [`tests.md`](references/tests.md) for test method,
[`judgment.md`](references/judgment.md) for drift, premises, root causes,
refusals, docs vs code, and lineage, [`handover.md`](references/handover.md)
for the report.

## Classify first

Pick the loop before the first edit.

- **Build-up** — new behaviour. Make it work, make it right, make it fast.
- **Teardown** — drifted code: code that was right for an intent that has since
  moved. Simplify, harden, clean.

Code that is failing its current contract is ordinary breakage. Fix the failure;
call it drift only when you can point to the intent that moved. If the
classification is unclear, state what changed — the requirement, the
implementation, or only your understanding — and settle that first.

The loops run opposite: build-up adds structure to a shape that should shrink;
teardown deletes before things have earned a place.

## The three beats

1. **Make it work** — read, frame, shape the data, slice, prove.
2. **Make it right** — fix the cause, simplify, harden, cover, review,
   refactor.
3. **Follow the practice** — prove the outcome, log, commit, hand over.

Each beat ends on a check you can pass. A slice does not enter the next beat
until the current one holds.

## Beat 1 — Make it work

**Gate:** the smallest end-to-end path works, and a test disagrees with the
code when the change is reverted.

### Read the source

- Read the code and its callers before the first edit. The source is the
  evidence; names and comments are claims.
- Establish the blast radius: callers, public surface, stored data, formats,
  tests that will break.
- When a claim rests on "the system does X", name the observation that would
  settle it, then trace the executing path and check the authoritative artifact.

### Frame the work

- Stop and report when the intent is unclear, the task is impossible as asked,
  or the work is larger than scoped.
- Keep the change inside its scope. A discovery that would widen it is a
  separate decision.
- **Attack the premise.** Two fixes failing the same gate means the shared
  premise is the defect. Write it as one checkable sentence, name the
  observation that would distinguish it from the alternatives, and act only
  once evidence supports it.

### Shape the data

- Decide types, fields, and legal states before any logic.
- Make illegal states unrepresentable: a type that cannot hold the bad value
  beats a check that rejects it.
- Parse outside data once, at the boundary; inside, the type is the argument.
- Add no cast, ignore, suppression, or widened escape hatch to get past a check.

### Slice vertically

- First slice is a tracer bullet: the smallest end-to-end path, wired to real
  data. Widen it after: cases, edges, stubs replaced.
- One decision in one place; one change does one thing. Record unrelated finds
  instead of fixing them here.
- Build the smallest edit that solves the current slice.

### Agree the seams and prove the slice

- Name the public boundaries under test and agree them before writing tests. A
  **seam** is where behaviour is observable without reaching inside.
- For each: what it catches, what it misses.
- **Gate:** every behaviour change has a test that fails when the change is
  reverted.
- Red-first where the contract is knowable; test-after only against a settled
  interface. The method, anti-patterns, and gaps: [`tests.md`](references/tests.md).

## Beat 2 — Make it right

**Gate:** every rule and error path in the slice is covered, the cause is fixed,
and the diff is as small as the intent allows.

### Fix the cause

- Reproduce first.
- Trace backward to the first incorrect assumption or violated invariant.
- Check sibling callers sharing the cause; fix the smallest responsible layer.
- A guard that hides the crash is not a fix. If the cause is out of scope,
  record it.
- Cannot reproduce? Say so; no guess wrapped in a fallback.

### Simplify

- Default move is remove. Delete paths that earn no keep.
- Establish that each removal is unused or superseded; record a capability
  intentionally dropped.
- Abstract at the third occurrence, and only when the copies change for the
  same reason.
- No abstraction without a present caller. If the code is already clear and
  local, leave it.

### Harden

- Validate at trust boundaries; trust the interior.
- Enforce each invariant where the value is created.
- Fail loudly: what was expected, what arrived, where.
- **Refuse plausible wrong results.** A missing or malformed fact returns a
  clear error, never a silent default or success-shaped substitute.
- Derive a fact from its authoritative source rather than storing two values
  that can disagree.
- Repeated operations end in the same state.
- Two writers would matter? Keep separate state; if sharing is required, allow
  one writer and enforce it in the structure.
- Anything observable is a contract.

### Cover the slice

- Every rule, branch, and error path the slice introduces is in the suite.
- Tests derive from the new intent. A test that defends replaced behaviour is
  deleted with the path.
- Hard to test? The design is wrong; fix the design.

### Review for structure

- Read the diff against its contract. Find preserved complexity, growing flags,
  empty indirection, weakened boundaries, logic in the wrong owner, avoidable
  duplication.
- For each finding: cite the evidence, name the smallest structural move.
- Separate contract violations from taste. No concrete problem? Say so.

### Refactor without changing behaviour

- Pin observable behaviour, move one step at a time, prove the same unmodified
  tests pass.
- A test that had to change means behaviour changed by intent. Say which you
  are doing.

### Make it fast, last

- Measure, change one thing, measure again. No optimisation without a
  measurement, or outside scope.

## Beat 3 — Follow the practice

**Gate:** the requested outcome is proven by direct evidence, the log is
complete, and the handover names every gap.

### Prove the outcome

- Restate the acceptance criterion in observable terms.
- Run the cheapest direct check at the right boundary: the feature, the value,
  persisted state, the diff.
- Report what was checked and what it showed; name what remains unverified.
- A passing test proves what it checks, not the requested outcome.

### Operate

- Keep the log as you go: action, reason, rejected options.
- Guard the context: push bulk reading out, bring back the summary.
- Commit small and ordered; each says why, what changed, how it was proved. A
  declared red intermediate commit is allowed; a red handover is not.
- Produce the report in [`handover.md`](references/handover.md): proven, tested,
  not tested and why, departures, blast radius.

## Precedence

Repository practice — style, commands, branching, architecture — wins on those
things; say so in the handover. It never wins on data shape, tests, error
handling, or honesty about gaps.

Not this skill: language and formatting style; build and test commands;
branching and review procedure; security and compliance; coverage thresholds;
project architecture.

## Checklist before handover

Run against the diff, not from memory.

1. Direction stated: build-up or teardown, with the evidence for it.
2. Every changed line read in its file and at its callers; blast radius named;
   nothing outside the task changed; unrelated finds recorded.
3. Data shape decided before logic; no suppression added.
4. Seams agreed before tests; every behaviour change has a test that disagrees
   when reverted; expected values independent; no valid test weakened.
5. Removed what earns no keep; no abstraction without a present caller.
6. The cause was fixed, not the symptom guarded; sibling callers checked.
7. Every rule and error path in the slice is covered, or its gap is named.
8. Preserved behaviour was pinned before structure moved; replaced behaviour's
   tests were rewritten.
9. Invariants enforced where values are created; bad results refused instead of
   defaulted; repeated operations idempotent; shared state has one writer.
10. Performance changes name their measurement; the requested outcome was proven
    by direct evidence.
11. Worktree clean; commits ordered and each says why, what, how proved.
