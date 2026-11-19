# Build-up

Implementation of new behaviour: make it work, make it right, make it fast. Use
it when the task adds behaviour that did not exist, not when the code drifted.

The opposite loop is [`teardown.md`](teardown.md). Applying build-up to drifted
code adds structure to a shape that should shrink.

## Before the first edit

- Read the task whole, then the spec it closes. The task's boundaries are the
  scope; its likely files are orientation, and the code wins.
- Read the area's code and its callers. Names and comments are claims; the
  executing path is evidence.
- Establish the blast radius: callers, public surface, stored data, formats,
  tests that will break.
- Read the glossary and any ADR that binds the area. Use their names, not
  invented ones.
- Confirm the behaviour is not already true. If it is, say so and stop; the task
  is done or mis-cut.

## Beat 1: make it work

### Shape the data

Decide types, fields, and legal states before any logic.

- Make illegal states unrepresentable: a type that cannot hold the bad value
  beats a check that rejects it.
- Parse outside data once, at the boundary. Inside, the type is the argument.
- Add no cast, ignore, suppression, or widened escape hatch to get past a check.
- Name the owner of each piece of state. Two writers would matter? Keep separate
  state, or allow one writer and enforce it in the structure.

### Build the smallest slice

The first slice is the tracer bullet: the smallest end-to-end path, wired to real
data. It proves the wiring before the path is widened.

- One decision in one place; one change does one thing.
- Widen the slice after it works: cases, edges, stubs replaced.
- Build the smallest edit that solves the current slice, not the one the next
  task will need.
- Record unrelated finds instead of fixing them here.

### Build the lever

When a step is not obvious at a glance and will be run again, build the tool: a
migration, fixture, rename, extraction, or environment setup.

- Do one unit by hand first. The hand-done unit is the specification; the tool is
  wrong until it reproduces it.
- Three repetitions earn a tool; two are a note.
- Keep it in `scripts/`, `tools/`, or a temp directory, never in product code.

### Prove the slice at the seam

The seam is the task's named boundary: a place where behaviour is observable
without reaching inside. Test there.

**Gate:** every behaviour change has a test that fails when the change is
reverted.

- Red-first where the contract is knowable before the code exists: pure logic,
  decision rules, parsers of settled formats.
- Test-after only against a settled interface, and then prove it: revert the
  implementation, watch the test fail, restore it, watch it pass.
- Never write all tests first. Bulk tests verify imagined behaviour.
- Never weaken a valid test to make an implementation pass.
- Expected values come from an independent source: a known-good literal, a
  worked example, the spec. An assertion that recomputes the value the way the
  code does can never disagree with it.

Method and anti-patterns: [`tests.md`](tests.md).

## Beat 2: make it right

### Fix the cause

- Reproduce first.
- Trace backward to the first incorrect assumption or violated invariant.
- Check sibling callers that share the cause. Fix the smallest responsible layer.
- A guard that hides the failure is not a fix. If the cause is out of scope,
  record it.
- Cannot reproduce? Say so. No guess wrapped in a fallback.

### Simplify

- Default move is remove. Delete paths that earn no keep.
- Establish that each removal is unused or superseded, and record a capability
  dropped on purpose.
- Abstract at the third occurrence, and only when the copies change for the same
  reason.
- No abstraction without a present caller. If the code is already clear and
  local, leave it.
- Run the `wet-or-dry` skill on the settled diff. It gives each copy and
  abstraction a verdict with evidence.

### Harden

- Validate at trust boundaries; trust the interior.
- Enforce each invariant where the value is created.
- Fail loudly: say what was expected, what arrived, and where.
- Refuse plausible wrong results. A missing or malformed fact returns a clear
  error, never a silent default or a success-shaped substitute.
- Derive a fact from its authoritative source rather than storing two values that
  can disagree.
- Repeated operations end in the same state.
- Anything observable is a contract.

### Cover the slice

- Every rule, branch, and error path the slice introduces is in the suite.
- Tests derive from the new intent. A test that defends replaced behaviour is
  deleted with the path.
- Integration points run the real path, not a mock of it.
- Hard to test? The design is wrong. Return it to `design`, or name the gap.

### Self-review the diff

Read the diff against the task's contract.

- Preserved complexity, a growing flag, an empty indirection, a weakened
  boundary, logic in the wrong owner, avoidable duplication.
- Module depth: a narrow interface over rich internals, not a shallow wrapper.
- File size: about 1000 lines reads comfortably, 2000 is a split signal. Never
  grow a file already over 2000; new work goes in a sibling behind the same
  interface. Detail: [`judgment.md`](judgment.md).
- Cite the evidence and name the smallest move for each finding. No concrete
  problem? Say so.

### Clean

Names, comments, and docs are the last pass: earned, not decorative.

- A name carries what the type cannot.
- Readable code needs no comment to explain how it works. When it does, rename,
  extract, flatten, or tighten instead.
- A comment earns its line by saying why this way, or naming a constraint forced
  from outside the code, in one line where one will do. No ticket references,
  restatement, edit narration, or commented-out code.
- Docs describe intent and operation, not current behaviour.

### Make it fast, last

Measure, change one thing, measure again. No optimisation without a measurement,
and none outside the task. Metric campaigns belong to `hillclimb`, not here.

## Beat 3: follow the practice

Run the task's proof at the surface it names. Report what was checked and what it
showed, and name what remains unverified. A passing test proves what it checks,
not the task. The change-level proof and the handover belong to the next stage.
