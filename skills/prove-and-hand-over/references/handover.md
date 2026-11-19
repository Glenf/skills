# Handover format

Every change ends with a handover. It makes the whole change reviewable by
someone who did not watch it being made, and it names gaps while they can still
be acted on. It covers the change, not one task: the task reports are its
evidence.

## Template

```markdown
## Change: <one line>

<One paragraph. What the system does differently, and why. Consequence, not
mechanics. Link the spec.>

**Direction:** build-up (new behaviour) | teardown (drifted code)
<If the tasks differ, one line per task instead:>
- Task 1 `<reference>`: build-up
- Task 2 `<reference>`: teardown — `<the intent that moved>`

### Proven

One block per acceptance criterion, in the spec's order.

- **Criterion 1:** `<the criterion, in observable terms>`.
- **Check:** `<the direct check run, on which surface>`.
- **Result:** `<what it showed>`. `<Anything still unverified, and why>`.

### Seams

- `<public interface>` — catches `<behaviour>`; misses `<what it cannot see>`.

### Tested

- `test_x` — asserts that a malformed record is rejected at the boundary with
  the field named.

### Not tested, and why

- Concurrent cancellation under load: no harness in this repository, and the
  honest test would need a controllable clock.

### Departures from repository practice

- Skipped the changelog entry: the repository has no changelog; release notes
  live in the ticket.

### Blast radius, re-checked

- Callers: three updated, one unchanged and verified against the new behaviour.
- Observable: error message text changed for the `E_INVALID` case, which a log
  scrape may match.

### Review

- **Correctness:** <n> findings; worst <P0–P3>.
- **Standards:** <n> findings; worst <P0–P3>.
- **Spec:** <n> findings; worst <P0–P3> — or "skipped (no spec)".
- **Security:** <n> findings; worst <P0–P3> — or "skipped (no trust boundary)".
- **Fixed:** `src/user.ts:42` · P1 — null `user` on no match; fixed in `d4e5f6`,
  re-proven by criterion 2.
- **Declared:** `<finding>` — accepted unfixed by `<the user>`, because
  `<reason>`.

**wet-or-dry:** <balance: too WET, too DRY, or neither, with the evidence>.
<Any extract, reuse, inline, or delete verdict left unapplied, and where it
went.>

### Commits

- `a1b2c3` — why / what / how proved.
- `d4e5f6` — fix for the P1 above; re-reviewed alone.

### Found, not fixed

- `p/q.rs:112` · P2 — swallows a parse error. Not in this change's scope.
```

## Rules

- **Direction is stated.** Build-up or teardown, per task when the tasks
  differ. A change that cannot say which it is has not decided.
- **Every criterion is proven or named.** Name the direct check and what it
  showed. A passing test is evidence for what it checks, not proof of the
  criterion. A criterion with no check is listed as unverified, with why.
- **Not tested is never empty by omission.** If everything is tested, say so.
  If something is not, name it and say why. An honest gap is a known risk; a
  silent one is a surprise.
- **Departures are declared where they happen**, not summarised away.
- **Every P0/P1 is accounted for**: fixed with its commit and re-proof, or
  declared with the user's acceptance. None is left out.
- **A red commit is named as red**, with the commit that makes it green. A red
  handover is a failed change.
- **No coverage percentage as evidence.** The lists are the evidence. A number
  describes the suite, not this change.
- **Short.** One line per item. The report is read, not archived.

## When the change stops

A blocked change produces the same report, ending here instead:

### Blocked

- **Asked:** what the change requires.
- **Why it stops:** the failed proof, the open decision, or the scope
  discovered.
- **What was tried:** checks, reviews, fixes routed — only what was actually
  done.
- **Options:** each with its cost, for the person who decides.

The working tree is left as it was found, or clearly marked as unfinished. A
workaround nobody asked for is not a deliverable.

## When the premise breaks

After two fixes fail the same check, the report says so instead of routing a
third fix:

### Premise

- **The premise, in one sentence:** what both attempts assumed.
- **Who holds the imbalance:** the actors and what each is carrying.
- **Why both attempts failed:** the same reason, stated once.
- **Proposal:** the assignment to remove, and what would replace it. A change
  of shape goes to `design`.

## Where the report goes

- **Not committed by default.** It is a message about the change, not part of
  it.
- **The PR/MR body and the ticket** carry the three lists: tested, not tested
  and why, departures. The user posts them.
- **Where the repository requires an AI usage record**, the handover goes there
  too, in that repository's format. Repository practice wins on where the
  record lives.
- **If the change touches behaviour an operator or integrator must know about**,
  the substance also goes to the documentation kept for them.
