# Routing

Triage ends with a path. The kind picks the stages; the source adds the checks
and supplies the evidence. The arrows are order, not invocation: naming a path
does not start it.

## Sources

| Source | Check before routing | Usual path |
|---|---|---|
| User request | Kind, size, whether it is already true | By kind |
| Tracker issue | Duplicate, still valid, enough context to classify | By kind |
| Spec task | Status `ready`, blockers done, on the frontier, still valid | `implement` |
| Review finding | Severity, confidence, `file:line`, fix or declare | `implement`, `bug-diagnose`, defer, or reject (declared) |
| Retro lesson | Proposed home named | `retro` |
| Bug report | Symptom, expected versus actual, whether it reproduces | `bug-diagnose` |
| Metric target | A named metric and a target, and the direction that is better | `hillclimb` |
| PR comment | Change request, question, or noise | By kind |

A source with enough context is classified without a new interview. A source
without it gets `needs framing/info`, naming the missing field and its owner.

## Kinds

| Kind | Recognise by | Path | Skipped |
|---|---|---|---|
| Question | Asks what, why, how, or whether; implies no change | answer, or `show-me` | design, tasks, code |
| Mechanical change | One obvious approach, local blast radius: rename, bump, one-line fix, config edit | `implement` → `prove-and-hand-over` | design, tasks |
| Bug | A behaviour contradicts its contract; expected and actual can be stated | `bug-diagnose` → `implement` → `prove-and-hand-over` | design, tasks |
| Feature | New behaviour, and either more than one shape or a boundary is crossed | `design` → `spec-and-tasks` → `implement` → `prove-and-hand-over` | none |
| Refactor | Same behaviour, new structure | `design` → `spec-and-tasks` → `implement` → `prove-and-hand-over` | none |
| Metric campaign | One metric, a target, and repeated changes rather than one fix | `hillclimb` → `prove-and-hand-over` | design, tasks |
| Structural work | Module boundaries, dependency direction, ADRs, or the repo's shape | `architecture` → `design` → ... → `prove-and-hand-over` | none |

A question is routed to an answer; triage does not answer it. A local refactor
is a mechanical change; a refactor that crosses a module or has more than one
plausible shape takes the design path. `prove-and-hand-over` runs `code-review`
inside it, so the review is not a separate stop.

A bug with an unknown cause never goes straight to `implement`. `bug-diagnose`
names the cause first.

## Modifiers

These change the first stage, not the kind.

| Modifier | Use when | Effect |
|---|---|---|
| `find-the-core` | The goal is unclear, or several wants are mixed together | Runs before `design` |
| `north-star` | Competing wants must become one goal | Replaces the frame, then `design` |
| `prototype` | An empirical fork blocks the shape | Runs before `design`, then design resumes |
| `why` | Intent lives only in the record | Runs before `design`, `bug-diagnose`, or `architecture` |
| `show-me` | The answer is a view: a call tree, a flow, a diff | Answers the question instead of prose |

`wet-or-dry` is called by `implement`. Triage never routes to it directly.

## Source rulings

**Spec task.** Actionable only when its status is `ready` and every blocker is
done. An item off the frontier is deferred; name the open blocker as the
trigger. A task marked `ready` whose blocker has reopened is not actionable,
whatever its status says.

**Review finding.** Fix now when it is P0/P1, inside the change, and the cause is
known. Diagnose when the cause is unknown. Defer a P2/P3 with the trigger that
would raise it. Declare when the user accepts the risk: record the verdict as
`reject` with the acceptance named, not a claim that the finding is false. A
finding without severity, confidence, or `file:line` goes back to `code-review`.

**Retro lesson.** Its home must be named: a skill, `AGENTS.md`, an ADR, or the
glossary. Route to `retro`, which edits the home. A lesson with no home is
`needs framing/info`, owner `retro`.

**PR comment.** A change request takes the path its size and kind imply. A
question takes answer or `show-me`. Noise is a preference already settled, a
resolved thread, or a demand outside the change; reject it with the evidence.

**Bug report.** Triage checks that the symptom and the expectation are stated.
Reproduction belongs to `bug-diagnose`, so a report that does not yet reproduce
is still routed there.

**Metric target.** Triage checks that a metric and a target exist, and that the
direction of "better" is stated. Baseline, harness, and stop predicate are
`hillclimb`'s first work, not a gate here.

## Entry requirements

Each stage needs its input before it can start. A missing item is the gap triage
names, and the verdict is `needs framing/info` unless the stage itself produces
it.

| Stage | Needs |
|---|---|
| `design` | A goal sentence, and the affected area read for blast radius |
| `spec-and-tasks` | An approved spec with acceptance criteria and seams |
| `implement` | A settled task: boundaries, acceptance check, proof, seam; `ready`; blockers done |
| `bug-diagnose` | A symptom, plus expected and actual behaviour |
| `architecture` | A structural question and the boundary it concerns |
| `hillclimb` | A metric and a target |

A mechanical change has no spec. The user's naming of it, with its boundaries
and check, is the contract.

## Split, do not bundle

Two kinds in one item are two items. Triage them separately: a bug report that
also asks for a redesign is a `bug-diagnose` and a `design`, not one path with
two starting points. Report both records, or the one the user asked about and a
line naming the other.

## Sizing by evidence

| Class | Evidence |
|---|---|
| One function | The diff sits inside one function or file; no caller changes |
| One module | One module or package, its tests, and its callers inside it |
| Cross-module | Several modules, or a public surface changes |
| Repo-wide | Every caller, a stored schema, a wire format, or the structure changes |
| Unknown | The read did not reach far enough; the first stage must read |

Size and blast radius are separate. A one-function change to a shared parser can
have a repo-wide blast radius, and a repo-wide rename can have no behavioural
blast radius at all.

## Examples

```
Verdict: do now
Item: Rejected imports show no reason code in the console
Source: ticket
Kind: bug
Size: one module
Blast radius: the import endpoint, the console view, the rejection tests
Validity: valid; no duplicate found by "reason code" or "rejected import"
Blocked by / missing: none
Path: bug-diagnose → implement → prove-and-hand-over (skipped: design, spec-and-tasks)
Next action: run bug-diagnose on the rejection path
```

```
Verdict: defer
Item: Rename the billing module to payments
Source: spec task PAY-14
Kind: refactor
Size: cross-module
Blast radius: every caller of the billing package, the public export, the docs
Validity: valid
Blocked by / missing: PAY-12 (move the invoice table) is open; owner is the tracker
Path: implement → prove-and-hand-over (already sliced; skipped: design, spec-and-tasks)
Next action: leave PAY-14 blocked; the trigger is PAY-12 closing
```

```
Verdict: needs framing/info
Item: Make the dashboard faster
Source: request
Kind: unknown
Size: unknown
Blast radius: unknown; the dashboard and whatever backs its numbers
Validity: valid as a complaint, not yet as work
Blocked by / missing: no metric or target; owner is the requester
Path: hillclimb → prove-and-hand-over, once a metric and target exist
Next action: ask which number on the dashboard is too slow, and what it should be
```

```
Verdict: duplicate
Item: Export fails on rows with a comma in the name
Source: PR comment
Kind: bug
Size: one function
Blast radius: the CSV writer and its tests
Validity: duplicate of BUG-88, which names the same quoting bug with a failing fixture
Blocked by / missing: none
Path: bug-diagnose → implement → prove-and-hand-over
Next action: recommend closing this comment against BUG-88
```
