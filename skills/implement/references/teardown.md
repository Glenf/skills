# Teardown

Recovery of drifted code: simplify, harden, clean. Use it when the code was right
for an intent that has since moved. It still runs and still passes its old tests;
it is wrong against the current direction.

The opposite loop is [`build-up.md`](build-up.md). Applying teardown to
green-field code deletes things before they have earned a place.

## Drift, with evidence

Separate three cases before the first edit:

- **Broken**: it fails its current contract. Fix the failure; that is not
  teardown.
- **Messy or slow**: it works and the intent holds. Clean or measure where the
  task says so, not as a teardown.
- **Drifted**: it works, and an intent has moved. Name the intent, where it is
  recorded (the spec, an ADR, a commit), and what the old code still assumes.

Only the third is teardown. Calling breakage "drift" licenses a redesign the
evidence does not support. Detail: [`judgment.md`](judgment.md).

## Pin the behaviour that must stay

Before deleting anything, write down the observable behaviour the task says must
survive, and where each piece is observed.

- The pin is behaviour through a public seam, not the current structure.
- If a test already pins it, keep the test unmodified. That is the proof the
  teardown changed no behaviour.
- A test that has to change means behaviour changed by intent. Say which you are
  doing, or stop and check the task's boundaries.

## Delete before you move

1. Delete the code the new intent replaces, once you can show it is unused or
   superseded.
2. Record a capability dropped on purpose. Silence about a lost capability is a
   gap, not a simplification.
3. Move one step at a time. After each step, run the tests that cover the blast
   radius. The same unmodified tests must pass.
4. Do not combine a delete with a reshape. Subtraction before reshape: the shape
   is easier to see with the dead weight gone.

**Gate:** the pinned behaviour still holds, proven by the same unmodified tests,
and each step left the suite green.

## Harden

- Enforce each remaining invariant where the value is created.
- Remove a guard that only hid a failure the teardown has now removed.
- Fail loudly: say what was expected, what arrived, and where.
- Refuse plausible wrong results rather than defaulting.
- Keep one writer for any shared state. The teardown is the moment to collapse a
  second writer, not to add one.

## Clean

Names, comments, and docs come last, after the shape has settled.

- Rename what the new intent renamed. A stale name is drift in the smallest form.
- Delete comments that explain code that no longer exists.
- Docs move in the same change that moves the design. Frozen documents such as
  ADRs are superseded, never rewritten.
- Leave the code you touched better; do not widen into code the task did not
  name.

## Cover the recovery

- The tests that pin preserved behaviour stay unmodified.
- Tests that defended replaced behaviour are deleted with the path. Keeping them
  defends the old intent.
- A new seam created by the teardown gets a test that fails when the recovery is
  reverted.
- Gaps are named, not left silent. Method: [`tests.md`](tests.md).

## Signals

After the teardown, reread the diff for structure: preserved complexity, empty
indirection, a boundary that is still weak, logic still in the wrong owner. A
high CRAP score in the touched code is a prompt to read the function, not to add
tests to a path that should have gone. [`signals.md`](signals.md).

## Prove the task

Run the task's proof at the surface it names, then report what was checked and
what it showed. A teardown proof usually shows the same observable result with
less code, one owner for the knowledge, and no capability lost except the ones
recorded. The change-level proof and the handover belong to the next stage.
