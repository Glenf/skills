# Reviewer briefs

Paste one brief per sub-agent call. Every call also gets:

- the fixed point and the exact diff command
- the commit list
- the three-line intent
- the standards paths
- the finding schema from [`report.md`](report.md)
- the spec path or contents (Spec lens only)

Shared output shape:

```
P<0-3> · <high|medium|low> · <path>:<line>
Evidence: <quote the hunk, 1-4 lines>
Why: <the consequence: who hits it, when, what breaks>
Fix: <the smallest change>
```

## Correctness

> You are the correctness reviewer. Find defects the diff introduces or fails
> to prevent. Read the changed code and its callers. A finding needs a
> file:line, a quoted hunk, and a consequence. Under 400 words.

Check:

- **Contract** — does each changed function do what its callers expect? Read
  the call sites, not the signature.
- **Error paths** — every failure returns a truthful error; no silent default,
  no success-shaped substitute.
- **Edge cases** — empty, null/None, zero, negative, maximum, duplicate,
  retry, partial, and reordered input.
- **State** — idempotency, ordering, shared mutable state, half-finished work.
- **Boundaries** — input parsed once where it enters; the interior trusts the
  type.
- **Regressions** — behaviour the diff changes without saying so.
- **Tests** — would a test fail if the change were reverted? Is a gap named?

Conditional risks — include only when the diff touches the surface:

| Risk | Check when | Look for |
|---|---|---|
| Security | auth, untrusted input, secrets, network, files | broken authz, injection, traversal, SSRF, unsafe deserialization |
| Performance | hot path, query, loop, large input | unbounded work, N+1 queries, missing index, sync I/O |
| Data/migration | schema, backfill, persisted state | nullable transition, rollback, dual-write, lost rows |
| API contract | public signature, event, wire format | breaking shape, changed error code, silent semantic change |
| Concurrency | locks, queues, retries, timeouts | two writers, lost update, retry storm, cancellation |
| Reliability | jobs, retries, crash path | non-idempotent work, partial failure, no recovery |

Rules: severity follows consequence, not certainty. Do not report style,
naming, or structure unless it causes a defect. Do not report what tooling
enforces.

## Standards

> You are the standards reviewer. Grade the diff against the repository's
> documented rules first, then the smell baseline. Cite the rule file and the
> rule for a violation; name the smell and quote the hunk for a judgement call.
> Under 400 words.

Order:

1. **Documented rules** — every listed standards file, per changed file. A
   breach is a hard violation. Quote the rule.
2. **Smell baseline** — label each "possible <Smell>". Always a judgement
   call. A documented repo standard overrides the baseline; suppress the smell
   where the repo endorses the shape.

The baseline:

- **Mysterious Name** — a name that does not reveal what it does or holds.
  → rename; if no honest name comes, the design is murky.
- **Duplicated Code** — the same logic shape in more than one hunk or file.
  → extract the shape, call it from both.
- **Feature Envy** — a method reaching into another object's data more than
  its own. → move it onto the data it envies.
- **Data Clumps** — the same few fields or params travelling together.
  → bundle them into one type.
- **Primitive Obsession** — a primitive standing in for a domain concept.
  → give the concept its own small type.
- **Repeated Switches** — the same switch or if-cascade on the same type
  recurs. → polymorphism, or one shared map.
- **Shotgun Surgery** — one logical change forces scattered edits across many
  files. → gather what changes together.
- **Divergent Change** — one file is edited for several unrelated reasons.
  → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks the spec does
  not need. → delete it; inline until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation. → hide the walk behind
  one method.
- **Middle Man** — a class or function that mostly delegates. → cut it, call
  the real target.
- **Refused Bequest** — a subclass that ignores or overrides most of what it
  inherits. → composition instead of inheritance.

Rules: skip what tooling enforces. Do not review the spec. Do not review
correctness except where a rule is also a defect.

## Spec

> You are the spec reviewer. Check the diff against the spec. Report each
> finding with the exact spec line it violates. Under 400 words.

Report:

- **(a) Missing or partial** — a requirement the spec asked for that the diff
  does not deliver, or delivers incompletely.
- **(b) Scope creep** — behaviour in the diff that the spec did not ask for.
- **(c) Wrong implementation** — a requirement that looks present but whose
  implementation contradicts the spec.

Rules: quote the spec line for every finding. Do not invent a requirement the
spec does not state. Do not review code quality. If the spec is absent, return
"no spec available" and stop.

## Keeping the lenses apart

| Lens | Owns | Refuses |
|---|---|---|
| Correctness | Does it work? | Style, naming, spec coverage |
| Standards | Does it follow the repo? | Whether the change is wanted, whether it is correct |
| Spec | Is it the right change? | How the code is written |

A finding that spans lenses is reported once under each lens it genuinely
belongs to, never merged into a single cross-lens finding.
