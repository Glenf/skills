# Judgment

The cases behind the rules in `SKILL.md` that need a worked reading.

## Drift, in detail

Beck names three states: work, right, fast. The fourth is code that *was* right
for an intent that has since moved. It still runs and still passes its old
tests; it is wrong against the design's current direction.

That is **drifted** code. It is distinct from *broken*, *messy*, or *slow*, and
it has its own recovery loop: simplify, harden, clean.

- Applying build-up to drifted code adds structure to a shape that should
  shrink.
- Applying teardown to green-field code deletes things before they have earned
  a place.
- Calling ordinary breakage "drift" licenses a redesign the evidence does not
  support. Fix the contract failure first.

## Premises

A premise is worth attacking because the alternative is a third variant of the
same wrong thing. If the evidence is inconclusive, the next move is a
discriminating check, not another fix.

Keep the check proportional: a targeted source trace or reproduction is usually
enough. Build a repeatable measurement only when the phenomenon varies over
time or across actors.

## Root causes

The guard trap is subtle because each guard looks local and cheap. A null check,
a retry around the symptom, a default on error: the failure still happens, now
somewhere quieter.

Stop when the cause is corrected and the relevant paths are covered. Do not
keep asking "why" past evidence, and do not widen into unrelated cleanup.

## Refused by default

- **Premature abstraction.** Two similar things is a coincidence; three is a
  pattern. Abstracting at two locks the wrong axis.
- **Test-pinning behaviour the design has moved past.** Delete the test with
  the path; otherwise it defends the bug.
- **Speculative configurability.** A flag multiplies call sites and test
  matrices. Add it when a concrete second consumer exists.
- **Hypothetical-future code.** The imagined caller's needs are unknown; the
  imagined code locks in guesses.
- **Defensive programming.** Validating internal invariants at every call site
  hides the real boundaries. Validate at boundaries; rely on types inside.
- **Speculation as answer.** If a yes/no can be settled by reading the call
  site, settle it.
- **SOLID as doctrine.** The intuitions are OO-shaped and do not transfer
  cleanly to procedural or data-flow code. Apply locally where an OO model fits.

## Docs and code

Code is the truth about **behaviour**. Docs are the truth about **intent**.

- Code answers: what does the system do right now?
- Docs answer: why did we build it this way, what did we refuse, what is the
  design's named direction?

In code: behaviour, tests, type-enforced invariants, and comments only where the
why is non-obvious. Long rationale, decision history, and architectural
overviews belong in docs.

In docs: intent, decisions, mental models, lineage, ubiquitous language,
explicit refusals, open questions. A description of current behaviour drifts
the moment the code moves; reference the code by file or symbol instead.

Living docs update in the same change that moves the design. Frozen docs —
ADRs, RFCs, findings — are superseded, never rewritten.

## Lineage

- **Kent Beck** — work / right / fast; tests as design; the simplest thing that
  could work.
- **John Ousterhout** — deep modules; complexity as compounding cost; read the
  code, not the comments.
- **Martin Fowler** — behaviour-preserving change; the Rule of Three;
  abstraction earned by removing duplication.
- **Sandi Metz** — duplication is cheaper than the wrong abstraction.
- **Hyrum's law** — every observable behaviour of an API will be depended on by
  somebody.
- **Yaron Minsky** — make illegal states unrepresentable.
- **Unix kernel culture** — the code is the specification.
- **The ub-mode school** — attack the premise, build the lever, reproduce
  before you fix, idempotent and single-writer by default, do not silence the
  compiler.
