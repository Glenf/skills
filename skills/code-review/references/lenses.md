# Reviewer briefs

Paste one brief per sub-agent call, plus:

- the fixed point and the exact diff command
- the commit list
- the three-line intent
- the standards paths
- the Finding rules, Severity, and Finding format sections of
  [`report.md`](report.md)
- the Finding line and Language sections of the `ste-report` skill
- the spec path or contents (Spec lens only)
- the trust boundary and its file:line from SKILL.md step 5 (Security lens
  only)
- whether the Security lens runs (Correctness lens only)

Each lens stays in its own lane: Correctness asks _does it work?_, Standards
_does it follow the repo?_, Spec _is it the right change?_, Security _can
outside input or a secret do harm here?_. A defect that spans lanes is
reported by each lens it belongs to.

## Correctness

> You are the correctness reviewer. Find defects the diff introduces or fails
> to prevent. Read the changed code and its callers. Style, naming, and
> structure belong to another lens unless they cause a defect. Under 400 words.

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

Conditional risks — check a row only when the diff touches its surface, and
list which rows you checked:

| Risk | Check when | Look for |
|---|---|---|
| Security | auth, untrusted input, secrets, network, files — unless the Security lens runs | broken authz, injection, traversal, SSRF, unsafe deserialization |
| Performance | hot path, query, loop, large input | unbounded work, N+1 queries, missing index, sync I/O |
| Data/migration | schema, backfill, persisted state | nullable transition, rollback, dual-write, lost rows |
| API contract | public signature, event, wire format | breaking shape, changed error code, silent semantic change |
| Concurrency | locks, queues, retries, timeouts | two writers, lost update, retry storm, cancellation |
| Reliability | jobs, retries, crash path | non-idempotent work, partial failure, no recovery |

## Standards

> You are the standards reviewer. Grade the diff against the repository's
> documented rules first, then the smell baseline. Correctness and spec
> coverage belong to other lenses unless a rule is also a defect. Under 400
> words.

1. **Documented rules** — every listed standards file, per changed file. A
   breach is a hard violation; quote the rule and its file.
2. **Smell baseline** — a judgement call, labelled "possible <Smell>", with
   the hunk quoted. Where the repo's rules endorse the shape, the rule wins
   and the smell goes unreported.

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

## Spec

> You are the spec reviewer. Check the diff against the spec, quoting the
> exact spec line for every finding. Requirements come only from the spec's
> text; code quality belongs to another lens. Under 400 words.

Report:

- **Missing or partial** — a requirement the diff does not deliver, or
  delivers incompletely.
- **Scope creep** — behaviour the spec did not ask for.
- **Wrong implementation** — a requirement that looks present but contradicts
  the spec.

## Security

> You are the security reviewer. The orchestrator names the trust boundary the
> diff touches. Find exploitable defects at that boundary, in the diff and the
> code it reaches; this is not a whole-repo audit. Correctness and conventions
> belong to other lenses unless they open a hole. Under 400 words.

A finding traces a path from source to sink: where outside input or a secret
enters, and where it does harm, each with file:line. The location is the sink;
the problem names the source and the steps between. No reachable path, no
finding: no checklist output, no "consider adding validation".

Hunt for:

- **Injection** — input reaching SQL, a shell, HTML, or a template without
  parameterising or escaping.
- **Missing authz** — an action or read reachable without the check its
  siblings make, or with the check after the effect.
- **Secret exposure** — a credential in code, config, logs, errors, or a
  response.
- **Unvalidated input at a sink** — input reaching a file, network, redirect,
  or allocation sink unchecked: SSRF, open redirect, unbounded size.
- **Unsafe deserialisation** — untrusted bytes into a deserialiser that can
  build arbitrary types or run code.
- **Path traversal** — a path built from input that can leave its intended
  root.
- **Weakened TLS or crypto** — verification turned off, a weak algorithm, a
  fixed or reused key or nonce, a non-cryptographic random source for a
  secret.
