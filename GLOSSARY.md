# Glossary

The language of this repo: the skills, the development cycle they make up, and
the words the skills use when they judge a change.

## Skills

**Skill**:
A folder with a `SKILL.md` that an agent loads to do one kind of job.
_Avoid_: Prompt, command, plugin

**Harness**:
The program that runs the agent and loads skills: Claude Code, Codex, OpenCode.
_Avoid_: Tool, client, IDE

**Built-in skill**:
A skill that ships inside a harness. Not used where a skill from this repo
covers the same job.
_Avoid_: Bundled skill, native skill

**Trigger**:
The `description:` of a skill: the conditions under which the agent loads it.
_Avoid_: Summary, blurb

**Reference**:
A file in a skill's `references/` folder, read only when `SKILL.md` points to it.
_Avoid_: Appendix, doc

## The cycle

**Cycle**:
The full path of a code change, from framing the goal to the retrospective.
`glen-mode` is its entry point.
_Avoid_: Workflow, pipeline, process

**Stage**:
One step of the cycle, run by one skill: frame, triage, design, spec and tasks,
implement, bug diagnosis, simplify, review, handover, retrospective.
Architecture and prototype sit off the main path.
_Avoid_: Phase, step

**Triage**:
The recurring intake gate for any work item, from a request, tracker, review, or
retrospective: what it is, whether it is actionable, which stage runs next, and
one verdict with one next action. It runs at the start of a change and whenever
new work arrives.
_Avoid_: Intake, sorting, backlog grooming

**Design**:
The stage that settles the shape of one change: facts, decisions, acceptance
criteria, and seams. It writes the design down for review, then writes the spec;
both stay draft until approved.
_Avoid_: Planning, architecture

**Judgment call**:
An open fork that no fact and no experiment can settle: the user must choose.
Resolved by a judgment question, asked with the options, a recommendation, and
what would change the answer.
_Avoid_: Decision, open question

**Empirical fork**:
An open fork that a question to running code settles, not the user. Answered
by `prototype`.
_Avoid_: Spike, proof of concept

**Architecture**:
The stage that changes long-lived structure across the system: module
boundaries, dependency direction, ADRs.
_Avoid_: Design, big refactor

**Spec**:
The behaviour contract for a change: what becomes true, the acceptance
criteria, and the seams. Written by `design`.
_Avoid_: Requirements doc, PRD

**Acceptance criterion**:
A statement that can be observed from outside the code and is false before the
change. Each names its proof on the real surface.
_Avoid_: Done condition, success metric

**Proof**:
The direct check on the real surface that shows an acceptance criterion is
true. A passing test is one kind of proof, not the gate.
_Avoid_: Verification

**Record**:
The written trail of intent for a change: commits, PR/MR discussions, issues,
ADRs, and release notes. The authority for why; code is the authority for what.
_Avoid_: History, git log, archaeology

**Inference**:
A conclusion the record does not state, marked as yours. Never presented as
what the authors meant.
_Avoid_: Assumption, guess

**Bug diagnosis**:
The evidence-backed cause of a defect, with the boundary of the fix and the
acceptance check it must satisfy. Produced by `bug-diagnose`; the fix follows.
_Avoid_: Root cause analysis, postmortem

**Hillclimb**:
Sustained improvement of one metric against a target: one change, one
measurement, keep or revert. A one-off fix is not a hillclimb.
_Avoid_: Optimisation pass, tuning

**Baseline**:
The frozen measurement of the metric before the first change.
_Avoid_: Starting point, control

**Bench**:
The frozen, repeatable command that produces the metric under a fixed workload,
with its noise and work count visible.
_Avoid_: Harness, test, benchmark

**Stop predicate**:
The target plus a floor on attempts; the run ends only when both hold.
_Avoid_: Goal, threshold

**Gate**:
The check that ends a stage or beat. The work moves on only when it passes.
_Avoid_: Exit criteria, definition of done, checkpoint

**Beat**:
One of the three parts of implementation: make it work, make it right, follow
the practice.
_Avoid_: Phase, pass

**Slice**:
A thin end-to-end path through the system that delivers one behaviour. The
first slice is the tracer bullet.
_Avoid_: Layer, chunk

**Tracer bullet**:
The first slice: the smallest end-to-end path through the system, on real data.
It proves the wiring before the path is widened.
_Avoid_: Prototype, walking skeleton

**Task**:
One slice written down in the project's tracker, with its own acceptance check
and stated boundaries.
_Avoid_: Ticket, story, issue

**Blocker**:
A task whose output another task needs before it can start.
_Avoid_: Dependency, prerequisite

**Frontier**:
The tasks whose status is `ready`: every blocker done and nothing waited on.
Triage reports it; the user or the tracker picks from it.
_Avoid_: Backlog, queue

**Build-up**:
Implementation of new behaviour: make it work, make it right, make it fast.
_Avoid_: Greenfield

**Teardown**:
Recovery of drifted code: simplify, harden, clean.
_Avoid_: Cleanup, refactor

**Drift**:
Code that was right for an intent that has since moved. It still runs and
passes its old tests. Different from broken code.
_Avoid_: Tech debt, rot, legacy

**Handover**:
The report at the end of a change: what is proven, what is tested, what is not,
departures, blast radius.
_Avoid_: Summary, status update

**Handoff**:
A mid-change transfer of unfinished work to another agent or session, with the
context to resume. Different from a handover, which ends the change.
_Avoid_: Handover, session transfer

**Blast radius**:
Everything a change can affect: callers, public surface, stored data, formats,
tests.
_Avoid_: Impact, scope

**Lesson**:
A finding from the retrospective that changes how the next change is done. It
has a home: a skill, `AGENTS.md`, an ADR, or the glossary.
_Avoid_: Learning, takeaway

## Triage

**Work item**:
Anything triage receives, with its source: a request, tracker issue, spec task,
review finding, retro lesson, bug report, metric target, or PR comment.
_Avoid_: Ticket, issue, intake

**Mechanical change**:
A change with one obvious approach and a local blast radius, such as a rename, a
version bump, or a one-line fix. It skips design.
_Avoid_: Trivial change, small change

**Verdict**:
The decision a gate gives the thing in front of it. Triage gives do now, defer,
reject, duplicate, or needs framing/info; `wet-or-dry` gives leave, reuse,
extract, inline, or delete.
_Avoid_: Recommendation, suggestion

## Review

**Fixed point**:
The commit, branch, or tag a review compares the change against.
_Avoid_: Base, target

**Lens**:
One independent view of a review — correctness, standards, spec, or security
— run as its own sub-agent.
_Avoid_: Reviewer, perspective, pass

**Finding**:
One problem a review or check reports, written as one line: location, label,
problem, fix.
_Avoid_: Issue, comment, remark

## Code design

**Shape**:
The structure of one change before it is sliced: types, signatures, module
boundaries, and which owner holds each piece of state. Architecture is the
structure that outlives the change.
_Avoid_: Approach, solution, plan

**Seam**:
A place where behaviour is observable without reaching inside the code. Tests
attach there.
_Avoid_: Boundary (for a seam), hook

**Deep module**:
A module with a narrow interface over rich behaviour.
_Avoid_: Service, component

**Shallow module**:
A module whose interface is nearly as large as its implementation, such as a
wrapper that only forwards.
_Avoid_: Thin layer, helper

**Deletion test**:
The question asked of an abstraction: if it were inlined, would complexity
concentrate at the callers, or only move there?

**Copy**:
Code in a change that repeats other code, in the diff or elsewhere in the repo.
It is duplication only when both change for the same reason.
_Avoid_: Clone, duplicate

**View**:
One picture of the work that makes one point — a call tree, a `diff` of a
shape, a sequence diagram — built from what was read, with its sources cited.
_Avoid_: Diagram, visual, chart

**Hot spot**:
A file or area that the git history shows changes often.
_Avoid_: Churn area, problem area
