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
One step of the cycle, run by one skill: frame, prototype, plan, spec and
tasks, implement, simplify, review, PR/MR, retrospective.
_Avoid_: Phase, step

**Gate**:
The check that ends a stage or beat. The work moves on only when it passes.
_Avoid_: Exit criteria, definition of done, checkpoint

**Beat**:
One of the three parts of implementation in `glen-mode`: make it work, make it
right, follow the practice.
_Avoid_: Phase, pass

**Slice**:
A thin end-to-end path through the system that delivers one behaviour. The
first slice is the tracer bullet.
_Avoid_: Layer, chunk

**Task**:
One slice written down in the project's tracker, with its own acceptance check.
_Avoid_: Ticket, story, issue

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

**Blast radius**:
Everything a change can affect: callers, public surface, stored data, formats,
tests.
_Avoid_: Impact, scope

**Lesson**:
A finding from the retrospective that changes how the next change is done. It
has a home: a skill, `AGENTS.md`, an ADR, or the glossary.
_Avoid_: Learning, takeaway

## Review

**Fixed point**:
The commit, branch, or tag a review compares the change against.
_Avoid_: Base, target

**Lens**:
One independent view of a review — correctness, standards, or spec — run as
its own sub-agent.
_Avoid_: Reviewer, perspective, pass

**Finding**:
One problem a review or check reports, written as one line: location, label,
problem, fix.
_Avoid_: Issue, comment, remark

## Code design

**Seam**:
A place where behaviour is observable without reaching inside the code. Tests
attach there.
_Avoid_: Boundary, hook

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

**Verdict**:
The decision `wet-or-dry` gives each copy and abstraction: leave, reuse,
extract, inline, or delete.
_Avoid_: Recommendation, suggestion

**View**:
One picture of the work that makes one point — a call tree, a `diff` of a
shape, a sequence diagram — built from what was read, with its sources cited.
_Avoid_: Diagram, visual, chart

**Hot spot**:
A file or area that the git history shows changes often.
_Avoid_: Churn area, problem area
