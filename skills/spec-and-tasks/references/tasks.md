# Tasks

A task is one slice written down in the project's tracker. It must stand alone:
a person or agent who reads only the task can start it, and a reviewer who
reads only the task can check it.

## Where tasks live

Find the location before writing any task. First hit wins:

1. `AGENTS.md`, `CLAUDE.md`, or `CONTRIBUTING.md` names a tracker, a folder, or
   an issue template.
2. Existing conventions: a `docs/tasks/` or `docs/issues/` folder, an issue
   template under `.github/` or `.gitlab/`, recent issues that show the house
   shape.
3. The git remote host: `gh` for GitHub, `glab` for GitLab.
4. Ask the user.

Never invent a location. Two projects rarely want the same one: some keep tasks
as issues, some as files beside the spec, some in a tracker the CLI reaches.

Check the command before using it: `gh issue create --help`,
`glab issue create --help`. Do not guess flags.

```bash
gh issue create --title "<title>" --body-file <file>
glab issue create --title "<title>" --description-file <file>
```

## Template

```markdown
# <Slice title: one behaviour>

Delivers: <the observable behaviour, one sentence>
Boundaries: <what this slice includes, and what it leaves to another slice>
Closes: <spec criterion number(s)>
Status: ready | blocked
Blocked by: <task references, or "none">
Waiting on: <external decision, credential, deployment, or "none">

## Acceptance check

<What a person does, and what they see, from outside the code. One check.>

## Proof

<The command, fixture, live check, or metric with a threshold, and the surface
it runs on.>

## Seam

- Catches: <failures visible at this seam>
- Misses: <failures invisible at this seam>

## Likely files

- `<path>`: <why it is expected to change>

Orientation only. The code wins.

## Notes

<What the next reader needs: the pinned behaviour, the trap, the batch this
belongs to. No design decisions.>
```

## Field standards

| Field | Holds | Fails when |
|---|---|---|
| Title | One behaviour, no "and" | It names a layer, or two behaviours |
| Delivers | What becomes true, observable | It restates an implementation step |
| Boundaries | What the slice includes and leaves out | It repeats the check, or becomes a file list |
| Closes | The criterion number from the spec | It paraphrases, so the link is lost |
| Acceptance check | One action and one observable result | It needs a passing test to explain it |
| Proof | Command, fixture, live check, or metric with threshold | It says "tests pass" with no surface |
| Seam | Catches and misses, both named | It claims to catch everything |
| Likely files | Paths with a reason each | It reads as a contract, or lists the tree |
| Blocked by | Tasks from this breakdown, or "none" | It hides a wait in prose |
| Waiting on | An external decision, credential, deployment, or gate, or "none" | It is called a blocker, or hidden in Notes |
| Status | `ready` when all blockers are done and `Waiting on` is none, else `blocked` | It disagrees with what is closed |

A proof is on the real surface. A unit test counts where the unit is the
observable surface; otherwise name the endpoint, the stored record, the CLI
output, the rendered page, or the metric.

Likely files are orientation. Name the ones the spec's evidence points at, and
say the code wins. A path list that reads as a contract stops the implementer
from reading.

## Blockers

- A blocker is a task in this breakdown whose output the blocked task needs.
  "It comes first" is not a blocker; "it creates the table this reads" is.
- No cycles. A cycle means the slices depend on each other and must be
  re-cut, not published.
- A wait from outside the breakdown is not a blocker. Put it in `Waiting on`
  and keep the task `blocked` until it clears. If it will not clear during this
  work, leave the task out of the breakdown.
- Status follows blockers and waits, not optimism. A task with one open blocker
  or one open wait is `blocked`, even if it could start on a guess.

Blockers order the work. They do not rank it: priority stays with the user and
the tracker.

## The frontier

The **frontier** is the set of tasks whose blockers are all done. It changes as
tasks close.

- Compute it from the tracker, not from memory, at the end of this stage and
  again when asked.
- Report the whole frontier. Do not invoke `implement` or `triage`; the user or
  `glen-mode` starts the next stage. Do not pick one and call it next unless the
  user asked for a pick.
- Do not rank within the frontier. That is the user's or the tracker's job.
- A task that closes can unblock several. Say which ones it unblocked.

## Publication

1. Publish in dependency order, blockers first, so a reference always points at
   something that exists.
2. Create every task, then add the blocking links. Native links need both
   references, so the ordering above is what makes them possible.
3. Use the tracker's own blocking link where it has one: GitHub issue
   dependencies, GitLab's "is blocked by" link. Otherwise write
   `Blocked by: <ref>` in the body. Do not invent an API shape: check the CLI
   help first.
4. Do not close, edit, or comment on the parent spec. The spec records what
   becomes true; the tasks record the order. Linking the spec from a task is
   fine; changing the spec is not.
5. Publishing twice must not duplicate. Search for the title first, and update
   the existing task if it is the same slice.
6. Record each created reference against its slice, and report them in
   dependency order.

## Triage-ready checklist

Before the breakdown is published, every task passes all of these.

- [ ] Title is one behaviour, and needs no "and".
- [ ] Boundaries say what the slice includes and leaves out.
- [ ] The criterion number it closes exists in the approved spec.
- [ ] Acceptance check is observable from outside the code.
- [ ] Proof names the surface and the check, not "tests pass".
- [ ] Seam names what it catches and what it misses.
- [ ] Blockers are tasks in this breakdown, or "none".
- [ ] Waiting on is none, or named and the task is blocked.
- [ ] Status matches the blockers and waits.
- [ ] Likely files are orientation, not a contract.
- [ ] The body holds no design decision; none is needed to start.
- [ ] A reader with only the task and the code can begin.
