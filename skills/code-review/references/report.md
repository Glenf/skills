# Report

Two formats: the per-finding schema the reviewers return, and the report you
assemble from their validated findings. Severity and confidence definitions
live in `SKILL.md`; do not restate them here.

## Finding schema

```markdown
### [P1 · high] <one-line finding>
`path/to/file.ts:42` · Correctness

> <quoted hunk, 1-4 lines>

**Why:** <consequence: who hits it, when, what breaks>
**Fix:** <the smallest change>
```

Advisory findings carry the label:

```markdown
### [P3 · low · advisory] <one-line finding>
```

A finding without a file, line, and quoted hunk is not a finding. Drop it.

## Validate and deduplicate

Per lens, in this order:

1. **Open the cite.** Read the file at that line and the surrounding path. Drop
   the finding if the diff does not support it.
2. **Check the consequence.** If you cannot say what breaks and for whom,
   downgrade to Advisory or drop it.
3. **Deduplicate.** Two findings describing the same defect become one; keep
   the stronger evidence and the higher severity.
4. **Do not merge across lenses.** The same line may be a Correctness finding
   and a Standards finding. They stay under their own headings. Agreement
   between lenses does not raise a severity.

## Report template

```markdown
## Review: <branch> vs <fixed point>

<2-3 line intent summary.>

### Coverage

- **Commits:** <n>: <oneline list>
- **Spec:** <path, or "skipped: none provided">
- **Standards:** <paths, or "no documented standards found">
- **Risk checks:** <selected>; not selected: <the rest>
- **Skipped:** <lens and why, or "none">
- **Not checked:** <anything the review could not establish>

### Correctness

<findings, or "No findings.">

### Standards

<findings, or "No findings.">

### Spec

<findings, or "Skipped: no spec provided.">

## Summary

- **Correctness:** <n> findings; worst: <P0-P3> <one line>
- **Standards:** <n> findings; worst: <P0-P3> <one line>
- **Spec:** <n> findings; worst: <P0-P3> <one line> — or "skipped (no spec)"

### Actionable

1. <P0/P1 finding, one line>
2. <P0/P1 finding, one line>
```

The Actionable list contains only P0 and P1 findings, in report order. If there
are none, write "Nothing blocking."

## Rules

- **Report only.** No fixes, commits, pushes, branch switches, or issue
  creation in this turn.
- **No findings is a valid result.** Say so per lens; do not pad.
- **Every finding has evidence.** Quote, cite, and name the consequence.
- **Worst per lens, no cross-lens winner.** The axes are deliberately separate.
- **Coverage is honest.** Name the lenses that ran, the risk checks selected,
  the lenses skipped and why, and anything the review could not establish. A
  skipped lens is named, not silently omitted.
- **Keep it readable.** One finding per heading, no walls of prose. A reviewer
  should be able to act on the report without opening the diff for the P0/P1
  items.
