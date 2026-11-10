# Findings and report

The finding rules, severity, and finding format are pasted into every
reviewer call. Validation and the template are for assembling the report,
written with the `ste-report` skill.

## Finding rules

- **An adequate change has no findings.** "No findings" is a full result.
- **Evidence:** file, line, and quoted hunk, or it is an opinion; drop it.
- **Consequence:** what breaks, for whom, and when. "This could fail" is not
  one.
- **Tooling's job stays with tooling.** Skip what a linter or type checker
  reports.
- **A restructure earns P3/Advisory**, stating what the new structure buys.

## Severity and confidence

Severity is urgency, independent of confidence: a certain P3 is still a P3.

| Level | Meaning |
|---|---|
| **P0** | Data loss, security breach, broken build, or failure on the primary path. |
| **P1** | Must fix before merge: a real defect on a normal path, or a documented rule broken with material consequence. |
| **P2** | Should fix: a defect on an edge path, a missing test for a named rule, a standards breach without immediate consequence. |
| **P3** | Discretion: naming, small duplication, clarity. |

Confidence: **high** (traced or reproduced), **medium** (strong inference from
the diff and callers), **low** (suspicion; kept only with material
consequence, labelled advisory).

## Finding format

Write each finding as an `ste-report` finding line. The label is
`P<0-3> · <confidence>`, plus `· advisory` for a low-confidence finding. Put
the quoted hunk (1-4 lines) under the line as a `>` quote:

```markdown
`src/user.ts:42` · P1 · high — `user` is null when `.find()` gets no match, so `.email` throws. Add a guard before `.email`.
> const email = user.email;
```

In the final report, keep the hunk for P0/P1 findings only.

## Validate

Per lens, on its own findings only:

1. **Open the cite.** Read the file at that line and its surrounding path.
   Drop what the diff does not support; name the drop in Coverage.
2. **Check the consequence.** If you cannot say what breaks and for whom,
   downgrade to advisory or drop it.
3. **Collapse exact repeats.** Keep the first, with its severity.

Everything else stays as the lens returned it: its order, its severities. Two
lenses flagging one line is two findings; agreement promotes nothing.

## Template

```markdown
## Review: <branch> vs <fixed point>

<2-3 line intent.>

### Coverage

- **Commits:** <n>: <oneline list>
- **Spec:** <path, or "skipped: none provided">
- **Standards:** <paths, or "none documented; smell baseline only">
- **Risk checks:** <selected>; not selected: <the rest>
- **Dropped:** <findings dropped in validation, and why>
- **Not checked:** <anything the review could not establish>

### Correctness

<findings, or "No findings.">

### Standards

<findings, or "No findings.">

### Spec

<findings, or "Skipped: no spec provided.">

## Summary

- **Correctness:** <n> findings; worst: <P0-P3> <one line>; blocking: <P0/P1, or "none">
- **Standards:** <n> findings; worst: <P0-P3> <one line>; blocking: <P0/P1, or "none">
- **Spec:** <n> findings; worst: <P0-P3> <one line>; blocking: <P0/P1, or "none"> — or "skipped (no spec)"
```

P0/P1 findings should be actionable from the report alone, without opening the
diff.
