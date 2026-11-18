# Slicing a spec

A spec is written by end state. Work is done by path. Slicing is the bridge: cut
the end state into the smallest end-to-end paths that each add one behaviour and
end green.

## Vertical and horizontal

A **horizontal** cut follows a layer: schema, then API, then UI, then tests.
Nothing works until the last cut, so nothing is proven until the last cut, and
the last cut is where the surprises are.

A **vertical** cut follows one behaviour through every layer it needs. The first
cut is narrow and complete; later cuts widen it.

Take the import rejection spec. Its end state: a rejected import shows a reason
code and message in the console, readable for 30 days, accepted imports
unchanged.

Horizontal, and wrong:

| # | Task | Proves |
|---|---|---|
| 1 | Add a `reason` column to the import table | Nothing observable |
| 2 | Write the reason when a rejection happens | Nothing observable |
| 3 | Render the reason in the console | Everything, at the end |
| 4 | Add the retention job | Retention only |

Vertical, and right:

| # | Slice | Proves |
|---|---|---|
| 1 | Pin the accepted-import response with a real fixture | The behaviour the change must not move |
| 2 | One malformed row is rejected with a code and message, visible on the endpoint response | The narrowest end-to-end path, on real data |
| 3 | The console shows the code and message for that rejection | The operator surface |
| 4 | The reason is readable at day 30 and gone at day 31 | Retention, on a backdated record |

Each ends green. Each can be shown to someone.

## The tracer bullet

The first slice is the **tracer bullet**: the smallest end-to-end path on real
data. It exists to prove the wiring, not to deliver the feature.

- Real data, not a mock of the new behaviour. If the path needs a fixture, the
  fixture is part of the slice.
- One case. The happy path or the single failing case named in the spec, not
  the edges.
- The full path: input, the code that changes, the observable result.
- Everything it skips is named: other cases, other surfaces, the stubs left in
  place.

A tracer bullet that takes a week is not a tracer bullet. If the plumbing itself
is the work, say so and slice the plumbing as its own end-to-end path, for
example one record through the queue and back.

## Sizing

A slice fits when all of these hold:

- **One behaviour.** One sentence a person could demo.
- **One fresh context.** A reader can hold the spec, this task, and the code it
  touches in one sitting.
- **One seam.** The place it is observed is named, and the slice can be checked
  there without reaching inside.
- **One edge.** You can say what it includes and what it leaves to another
  slice.
- **Ends green.** Its check can pass when the slice is done, and there is no
  half-wired state left for the next slice to repair.

Signs it is too big:

- the title needs "and";
- it closes two acceptance criteria that describe different behaviour;
- its likely files span unrelated areas, or the whole tree;
- the check needs a script to set up more than one surface;
- you cannot say what it leaves out.

Signs it is too small:

- nothing observable changes;
- it cannot end green without the next slice;
- it is a step in a sequence no one could demo, such as "add the type" or
  "wire the module".

Small is not the goal; provable is. Two slices that each prove something beat
one that proves everything at the end.

## Ordering

Order for proof, not for convenience. Three motifs cover most specs.

| Motif | Rule | Use when |
|---|---|---|
| Failing test before the fix | Land the reproduction first, then turn it green | A bug or a regression, and the spec names the failing case |
| Subtraction before the reshape | Delete what the new shape replaces, then move what remains | A refactor or teardown, where dead weight would otherwise be carried through |
| Baseline before the treatment | Measure the current state before a slice changes it | A metric, a performance target, or a behaviour that must not move |

Order by blockers, not by size. If two slices do not block each other, prefer
the one that produces evidence the other will use.

Each slice ends green. A slice that ends red and is repaired by its successor is
one slice, cut in the wrong place.

## A wide refactor

A refactor that touches every caller cannot be a tracer bullet: there is no
small end-to-end path that proves the whole shape, and a fake one proves
nothing. Use expand, migrate, contract.

1. **Expand.** Add the new path beside the old one. Both work. Prove them
   equivalent on the same fixtures, or prove the new path on one real caller.
2. **Migrate in batches.** Move callers in batches, one batch per task. Batch by
   a boundary the code already has: one module, one endpoint family, one job.
   Each batch ends green with the suite unmodified except for the moved call.
3. **Contract.** Delete the old path once no caller remains. Prove the deletion
   by search and by the suite passing without it.

Each step is still a slice with an observable check. Expand and contract are
thin; the batches carry the width.

The expand step is the one case where a slice may deliver structure without a
user-visible behaviour. Its acceptance check is the equivalence proof, not a
feature. Say that in the task, so the next reader does not look for one.

## What is not a slice

| Cut | Why it fails | Repair |
|---|---|---|
| "Add the schema" | A layer: nothing observable | Find the one path that reads and writes it, and slice that |
| "Write the API" | A layer | Slice one endpoint behaviour end to end |
| "Add tests" | Proof is part of every slice, not a slice on its own | Attach the test to the slice it proves. A pinning test for existing behaviour is a valid first slice when the spec requires that behaviour to stay put. |
| "Refactor the module, then add the feature" | Horizontal, and it hides a dependency | Expand, migrate, contract, or prove the refactor on one caller |
| "Spike the new approach" | An empirical fork | `prototype`, before the spec is approved |
| "Handle all the edge cases" | A bucket, not a behaviour | One slice per case that matters, ordered by risk |
| "Make it fast" | No measurement named | A slice with a baseline, a change, and a threshold |
