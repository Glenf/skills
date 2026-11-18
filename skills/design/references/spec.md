# The spec

One file per change, in the project's spec location. The spec is the behaviour
contract: what becomes true, how a person can see it, and where the behaviour is
observable. It is not a plan, a task list, or a design document for the whole
system.

## Template

```markdown
# <Change> spec

Status: draft | approved
Owner: <who approves>
Goal: <the one sentence from north-star>

## Current state

<What happens today, and the evidence for it. `file:line` where the fact is in
code; the record where the fact is a decision.>

## Desired end state

<What happens after the change, from the outside. No implementation.>

## Decisions

| Decision | Chosen | Rejected, and why |
|---|---|---|
| <question the change had to answer> | <answer> | <option, and the evidence or judgment that ruled it out> |

## Acceptance criteria

1. <observable statement>. Proof: <the direct check on the real surface>.
2. ...

## Seams

| Seam | What it catches | What it misses |
|---|---|---|
| <place behaviour is observable> | <failures visible there> | <failures invisible there> |

## Not being done

- <thing a reader would reasonably expect, and why it is out of scope>

## Open risks

- <what could still be wrong, and how it would show>

## Research notes

<Questions asked, answers with sources, and gaps. See research.md.>
```

Every spec starts at `Status: draft`. Set `Status: approved` and fill `Owner`
only after the human confirms the shape and approves the spec. A draft is not a
task input.

## Worked example

A short one, for the shape of it, not the subject matter.

```markdown
# Import rejection spec

Status: draft
Goal: an operator can see why an import was rejected without reading logs.

## Current state

The importer logs a rejection and returns a bare failure to the caller
(`src/import/run.ts:44`). The operator console shows "import failed"
(`src/console/import.ts:19`). The 2023 ADR chose not to persist reasons
(`docs/adr/0007-import-audit.md`), so nothing in the record explains why.

## Desired end state

Every rejected import leaves one reason, readable by the operator for 30 days,
and the console shows that reason in place of the bare failure. Accepted
imports are unchanged.

## Decisions

| Decision | Chosen | Rejected, and why |
|---|---|---|
| Where the reason lives | A field on the import record | A separate audit log: one writer and one reader, and ADR 0007 forbids a second store. |
| Reason shape | A closed set of codes with a message | Free text: the console cannot translate it, and the tests cannot pin it. |

## Acceptance criteria

1. A rejected import shows its reason code and message in the console. Proof:
   run one import with a malformed row, read the console.
2. The reason is readable for 30 days and gone after 31. Proof: the retention
   job's output on a backdated record.
3. An accepted import is unchanged: same response, no reason field. Proof: the
   existing acceptance fixture, unmodified.

## Seams

| Seam | What it catches | What it misses |
|---|---|---|
| HTTP response of the import endpoint | Rejection with the right code | Whether the record is readable a day later |
| The import record read back | Retention and code persistence | Console rendering |
| Console HTML | Operator-visible text | Clients that call the API directly |

## Not being done

- Backfilling reasons for imports rejected before this change.
- Letting operators write their own rejection messages.

## Open risks

- The closed set may not cover a future validator. Adding a code is then a
  two-place change; the criterion stays the same.

## Research notes

- Who reads reasons today? Nobody in code (`rg "rejection" src/`); the support
  runbook asks operators to read logs. Record: `docs/runbooks/import.md`.
- Gap: no data on how often 30 days is too short. Judgment call left to the
  operator interview, 2026-03-04.
```

## Acceptance criteria

The hard part. A criterion is a claim a non-author can check without reading
the diff.

Good:

- "A failed login returns 401 and no session cookie." Observable, false today.
- "The nightly job leaves one archive per day and no partial file." Observable
  on disk, false today if the job writes partials.
- "The API rejects a duplicate email with the same error as a malformed one."
  Observable from outside, and a deliberate choice about disclosure.

Bad, and the repair:

| Bad criterion | Why | Repair |
|---|---|---|
| "Add a `reason` column to the import table." | An implementation step, not a behaviour. | "A rejected import's reason survives a restart." |
| "Imports work correctly." | Not checkable, not observable. | Name the case, the input, and the output. |
| "Improve rejection handling." | No before or after. | "A rejected import shows its reason in the console." |
| "Tests pass." | A passing test is one kind of proof, not the outcome. | Name the check on the real surface. |
| "No regressions." | Universal, therefore unprovable. | Name the behaviour that must be preserved, and its check. |

Each criterion is false before the change, except where the change is a
refactor. Then the criteria are a pair: the pinned behaviour that must stay
true, and the structural change that is false before. The proof shows both. A
criterion that is already true and is not paired with a structural change
describes a constraint, not a change; move it to "Not being done" or to a
seam.

Prefer a criterion a person can check by using the feature. A unit test is
proof only where the unit is the observable surface.

## Seams

A seam is where behaviour is observable without reaching inside. One seam per
row, with its blind spot. The table is how a later review checks that the tests
attach in the right places.

| Seam kind | Catches | Typically misses |
|---|---|---|
| Public API or endpoint | Contract, status, payload, auth | Internal ordering, persistence after restart |
| Saved data, read back | Durability, retention, shape | Rendering, derived values |
| CLI exit and output | Operator contract, exit codes | Library callers |
| Component or UI surface | What a person sees | API clients, background paths |
| Time or scheduling boundary | Order, idempotency, catch-up | Clock skew, timezone edges |

A seam with no blind spot is under-specified. Name one.

## What does not belong

- Implementation paths, class names, and code snippets, except decision-rich
  prototype output: a state machine, a schema, a type shape. A `file:line` cite
  in Current state or the appendix is evidence, not a path.
- Task lists, estimates, owners per slice, or tracker links. Those are
  `spec-and-tasks`.
- A restatement of the brief to fill space.
- A decision with no rejected option, unless the alternative was genuinely
  absent. Write "only option" and why.
