---
name: code-review
description: >
  Review a change on three independent lenses — correctness, standards, spec —
  run as parallel sub-agents, then report findings with severity, confidence,
  and file:line evidence. Use before shipping a branch or PR, or when implement
  or glen-mode asks for a review. Not for reviewing documents, investigating a
  bug, or applying fixes.
argument-hint: "[fixed-point] [spec path]"
---

# Code review

Review the change, not the author's taste. A finding earns its place by naming
a consequence: broken behaviour, a violated rule, or a requirement the change
missed.

Three lenses run independently because each catches what the others miss. A
change can satisfy the spec and still be wrong (Correctness). It can be correct
and break the repo's conventions (Standards). It can follow every convention
and implement the wrong thing (Spec). Keep the reports separate; do not rerank
across lenses.

## Process

### 1. Pin the fixed point

The fixed point is what the user names: a commit, branch, tag, or ref. If they
name nothing, ask. Do not guess a base.

```bash
git rev-parse <fixed-point>
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

Three-dot diff, so the comparison is against the merge-base. Stop here if the
ref does not resolve or the diff is empty.

### 2. Find the spec

In order:

1. Issue references in the commit messages (`#123`, `Closes #45`, `!67`).
2. A path the user passed.
3. A spec under `docs/`, `specs/`, or other project defined path.
4. Ask. If the user says there is no spec, skip the Spec lens and record it in
   Coverage.

### 3. Find the standards

Search the repo for what documents how code is written: `CODING_STANDARDS.md`,
`CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, style guides, and ADRs that bind
the changed area. Record the paths; every reviewer gets them.

On top of the repo's rules, the Standards lens carries the Fowler smell
baseline in [`references/lenses.md`](references/lenses.md). Repo rules
override it, and every smell is a judgement call, not a violation.

### 4. Write the intent

Three lines, from the commits and the spec: what the change is meant to make
true, and what it deliberately does not touch. Every reviewer receives it. It
stops a reviewer from inventing a requirement the change never had.

### 5. Dispatch the reviewers that have inputs

Issue the selected sub-agent calls together, in the foreground. Fresh context
for each; none inherits this conversation. A lens without its input is not
dispatched: an agent asked to review against a spec that does not exist can
only report that it has nothing to do.

| Lens | Runs when | Skip when |
|---|---|---|
| Correctness | always, once the diff is pinned | never |
| Standards | always; documented rules when present, smell baseline otherwise | never |
| Spec | a spec exists after step 2 | no spec was provided or found |

Name every skipped lens in Coverage and say why. Skipping is a coverage fact,
not a silent omission.

The full briefs are in [`references/lenses.md`](references/lenses.md); paste
the relevant one into each call along with the diff command, commit list,
intent, standards paths, and spec where applicable.

- **Correctness** — bugs, regressions, edge cases, error paths, state, and the
  conditional risks the diff actually touches: security, performance,
  data/migration, tests, API contract, concurrency. Runs always.
- **Standards** — documented rules first, then the smell baseline. Cite the
  rule or name the smell.
- **Spec** — missing or partial requirements, scope creep, and requirements
  that look implemented but are wrong. Quote the spec line.

No lens does another's job: Correctness does not grade style, Standards does
not re-litigate the spec, Spec does not review code quality.

### 6. Aggregate

Read [`references/report.md`](references/report.md) for the finding schema.

For each lens, independently:

1. Open the cited file and line. Drop any finding the diff does not support.
2. Deduplicate findings that describe the same defect.
3. Assign severity and confidence. Keep the evidence quote.
4. Keep low-confidence findings only when the consequence is material; mark
   them Advisory.

Do not merge findings across lenses. The same line can be a Correctness finding
and a Standards finding; report both, under their own headings.

### 7. Report

Use the template in [`references/report.md`](references/report.md). The report
ends with:

- **Coverage** — fixed point, commits, spec source, standards files, which risk
  checks ran, and what was not checked.
- **Summary** — counts per lens, and the worst finding in each lens. No single
  winner across lenses.

Report only. Do not apply fixes, commit, push, switch branches, or open issues.
If the caller wants fixes, they ask in a separate turn.

## Finding rules

- **An adequate change has no findings.** Do not manufacture one to look
  thorough.
- **Cite evidence.** A finding without a file, line, and quoted hunk is an
  opinion. Drop it.
- **Skip what tooling enforces.** A linter or type checker already reports it;
  the review adds nothing.
- **Name the consequence.** "This could fail" is not a finding. Say what
  breaks, for whom, and when.
- **Severity is urgency, not confidence.** A certain P3 is still a P3.
- **Do not report a rewrite as a finding.** If the only fix is "restructure
  this", say what the structure buys; label it P3/Advisory.

## Severity

| Level | Meaning |
|---|---|
| **P0** | Critical: data loss, security breach, broken build, or failure on the primary path. |
| **P1** | Must fix before merge: a real defect on a normal path, or a violated documented rule with material consequence. |
| **P2** | Should fix: a defect on an edge path, a missing test for a named rule, a standards breach without immediate consequence. |
| **P3** | Discretion: naming, small duplication, a clarity improvement. |

Confidence: **high** (traced or reproduced), **medium** (strong inference from
the diff and callers), **low** (suspicion; report only with material
consequence, as Advisory).

## Non-goals

Applying fixes; committing or pushing; reviewing documents, plans, or prose;
investigating a bug you cannot see in the diff; rewriting the change to your
taste.

## Sources

Matt Pocock's `code-review` for the two-axis split and the smell baseline;
Every's `ce-code-review` for the correctness lens, diff-aware risk selection,
severity, confidence gating, and evidence anchoring. Deliberately omitted from
CE: persona catalog, cross-model peer, apply modes, JSON handoff, depth gates.
