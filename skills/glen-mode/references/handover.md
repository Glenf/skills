# Handover format

Every change ends with a report. It makes the change reviewable by someone who
did not watch it being made, and it names gaps while they can still be acted
on.

## Template

```markdown
## Change: <one line>

<One paragraph. What the system does differently, and why. Consequence, not
mechanics.>

**Direction:** build-up (new behaviour) | teardown (drifted code)

### Log

| # | Action | Reason |
|---|--------|--------|
| 1 | Read `x`, its callers and the tests around it | Establish the blast radius before editing |
| 2 | Deleted the retry path in `y` | No caller reaches it; the failure it covered is now impossible by type |
| 3 | Rejected: extending `z` with a mode flag | A flag would put two shapes in one type; two callers, so a separate function is cheaper |

### Proven

- **Criterion:** `<the requested outcome, in observable terms>`.
- **Check:** `<the direct check run>`.
- **Result:** `<what it showed>`. `<Anything still unverified, and why>`.

### Seams

- `<public interface>` — catches `<behaviour>`; misses `<what it cannot see>`.

### Tested

- `test_x` — asserts that a malformed record is rejected at the boundary with
  the field named.

### Not tested, and why

- Concurrent cancellation under load: no harness in this repository, and the
  honest test would need a controllable clock. One line at the code site;
  ticket filed.

### Departures from repository practice

- Skipped the changelog entry: the repository has no changelog; release notes
  live in the ticket.

### Blast radius, re-checked

- Callers: three updated, one unchanged and verified against the new behaviour.
- Observable: error message text changed for the `E_INVALID` case, which a log
  scrape may match.

### Commits

- `a1b2c3` — why / what / how proved. Declared red: next commit adds the
  caller.

### Found, not fixed

- `p/q.rs:112` swallows a parse error. Recorded as a ticket, untouched here.
```

## Rules

- **Direction is stated.** Build-up or teardown. A change that cannot say which
  it is has not decided.
- **The outcome is proven, not assumed.** Name the direct check and what it
  showed. A passing test is evidence for what it checks, not automatically
  proof of the requested outcome.
- **Chronological.** The log is what happened, in order, including the reads
  that changed your mind and the options you rejected.
- **Every action has a reason.** An action without a reason is a decision
  nobody made. "Because the pattern was there" is not a reason; name the
  pattern.
- **Save the rejected branches.** The option you did not take, with the reason,
  is the part a reviewer cannot reconstruct.
- **Not tested is never empty by omission.** If everything is tested, say so.
  If something is not, name it and say why. An honest gap is a known risk; a
  silent one is a surprise.
- **Departures are declared where they happen**, not summarised away.
  Following repository practice against a default in `SKILL.md` is allowed; not
  saying so is not.
- **A red commit is named as red**, with the commit that makes it green. A red
  handover is a failed change.
- **No coverage percentage as evidence.** The lists are the evidence. A number
  describes the suite, not this change.
- **Short.** One line per action. The report is read, not archived.

## When the change stops

A blocked or refused task produces the same report, ending here instead:

### Blocked

- **Asked:** what the task requires.
- **Why it stops:** the ambiguity, the impossibility, or the scope discovered.
- **What was tried:** reads, probes, prototypes — only what was actually done.
- **Options:** each with its cost, for the person who decides.

The working tree is left as it was found, or clearly marked as unfinished. A
workaround nobody asked for is not a deliverable.

## When the premise breaks

After two fixes fail the same gate, the report says so instead of offering a
third fix:

### Premise

- **The premise, in one sentence:** what both attempts assumed.
- **Who holds the imbalance:** the actors and what each is carrying.
- **Why both attempts failed:** the same reason, stated once.
- **Proposal:** the assignment to remove, and what would replace it.

## Where the report goes

- **Not committed by default.** It is a message about the change, not part of
  it.
- **The change description and the ticket** carry the three lists: tested, not
  tested and why, departures.
- **Where the repository requires an AI usage record**, the log goes there too,
  in that repository's format. Repository practice wins on where the record
  lives.
- **If the change touches behaviour an operator or integrator must know about**,
  the substance also goes to the documentation kept for them.
