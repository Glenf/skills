# Verdicts

One item, one verdict. The verdict says whether the item is taken now, and the
path says by which stage. Both are needed: "do now" without a path is a mood.

## The five

| Verdict | Means | Must name |
|---|---|---|
| do now | Valid, unblocked, ready to take | One next action, and the input the first stage needs |
| defer | Valid, but blocked, waiting, or not now | The trigger that would make it ready, and its owner |
| reject | Invalid, out of scope, already done, or not worth doing | The evidence, not a preference |
| duplicate | A canonical item already covers it | The canonical item, and a recommendation to close |
| needs framing/info | A goal, decision, or fact is missing | One question, and its owner |

"Do now" means ready to take, not taken. Triage does not start it.

A verdict is not a label on the tracker. It is the close of this triage pass. It
changes when the evidence does: a defer becomes do now when its trigger closes.

## Validation

Check validity before anything else. An invalid item needs no path.

| State | Evidence |
|---|---|
| Valid | The behaviour is absent or wrong today, and the item still applies |
| Done | A commit, release, or proof on the real surface shows the behaviour is true |
| Duplicate | A canonical item covers the same behaviour, cause, or decision |
| Superseded | A later decision, spec, or design replaced this item |
| Invalid | The premise is false, the reported behaviour cannot occur, or the scope is gone |

Similar words are not a duplicate. Two items are one when they would be closed
by the same change: same behaviour, same cause, or same decision. If two might
be one, report both and say which looks canonical; do not merge them.

For done, name the artefact: the commit, the release, the test on the real
surface, or the code path that already holds. "I think this was fixed" is not
evidence.

Recommend the close, and stop there. Triage does not close, merge, label, or
comment unless the user explicitly asks.

## Actionability

What stops an item: four kinds, each with an owner.

| Kind | Example | Trigger that clears it |
|---|---|---|
| Decision | The user has not chosen between two shapes | The choice is made |
| Fact | Nobody has checked whether the API returns the field | The fact is gathered |
| Task | Another task creates the table this reads | That task is done |
| External wait | A credential, a deployment, a release | The wait clears |

A blocker is a task whose output this item needs. "It comes first" is not a
blocker; "it creates the table this reads" is.

A wait from outside the work is not a blocker, but it still keeps the item
blocked. Name it and its owner.

A spec task is actionable only when its status is `ready` and every blocker is
done. A blocked task is deferred, never picked. Optimism is not a status.

## Frontier

The **frontier** is the tasks whose blockers are all done and whose status is
`ready`. It moves as tasks close.

- Compute it from the tracker at the moment of triage, not from memory.
- Report the whole frontier when the item is a spec task and several are ready.
- When a task closes, say which tasks it unblocked.
- An item off the frontier is deferred. The trigger is the open blocker closing.

## No rank

Triage picks a next action; it does not rank work.

- Within the frontier, use the tracker's order. With no order, use the priority
  the user named. With neither, report the frontier and ask.
- Across unrelated work, never invent a ranking. Priority stays with the user or
  the tracker.
- Do not reorder a backlog, merge a queue, or turn a size class into an order.
- A small item does not outrank a large one, and a blocker does not outrank an
  unrelated item.

## Needs framing/info

This verdict means one thing is missing and someone must supply it. Name the
first missing item, the one whose answer changes the verdict, and its owner.

| Missing | Question | Owner |
|---|---|---|
| Goal | What should become true that is not true now? | Requester |
| Decision | Which of these two shapes do you want? | User |
| Fact | Does the endpoint return the field today? | Whoever can read the code or call it |
| Acceptance | How will we see this is done? | `design`, not the reporter |
| Home for a lesson | Which skill, ADR, or doc should change? | `retro` |

Ask one question. A list of questions is a requirements interview, and that
belongs to `north-star`, `find-the-core`, or `design`. If more than one thing is
missing, name the first and let the answer reveal the next.

Do not fill the gap yourself: a goal or acceptance criterion invented during
triage is a design decision in disguise.

## Evidence over taste

Every verdict names what settled it:

- reject: the scope line, the false premise, the release that already shipped it;
- duplicate: the canonical reference and the shared behaviour;
- defer: the blocker and the trigger;
- needs framing/info: the missing item and its owner.

"I do not like it" is not a verdict. "Out of scope" needs the scope it is out of.

## Anti-patterns

| Pattern | Why it fails | Instead |
|---|---|---|
| Second discovery pass | Reproducing, diagnosing, or reviewing here duplicates the next stage and delays the verdict | Read only to classify |
| Estimate in disguise | "About a day", or "small" with no evidence | A size class and a blast radius |
| Requirements interview | Three questions turn a gate into a discovery session | One question, one owner |
| Invented priority | Ranking unrelated work overrides the user and the tracker | Report the frontier and ask |
| Starting the work | Answering, designing, or coding in triage | Name the stage and stop |
| Tracker action | Closing or merging without being asked destroys the user's record | Recommend |
| Filling the gap | Writing the missing goal or check decides what design owns | Name the gap |
| Skipping by size | A small change that crosses a boundary still needs design | Route by kind and blast radius |
| Duplicate by keyword | Similar titles hide different causes | Compare behaviour, cause, or decision |
| Verdict without a path | "Do now" with no stage leaves the user where they started | Name the path and the next action |

## Worked records

```
Verdict: defer
Item: Add a retry to the webhook sender
Source: tracker issue HOOK-31
Kind: feature
Size: one module
Blast radius: the webhook sender, its queue consumer, delivery tests
Validity: valid; no duplicate found by "retry" or "webhook delivery"
Blocked by / missing: needs a decision on duplicate delivery; owner is the user
Path: design → spec-and-tasks → implement → prove-and-hand-over
Next action: leave blocked until the duplicate-delivery decision is made
```

```
Verdict: reject
Item: Move every test to the new assertion library
Source: review finding
Kind: refactor
Size: repo-wide
Blast radius: every test file; no product surface
Validity: out of scope for the reviewed change, and not required by any spec
Blocked by / missing: none
Path: none (skipped: design, spec-and-tasks, implement)
Next action: record as found-not-fixed; no change in this review
```
