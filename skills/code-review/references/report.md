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

## Validate, do not merge

Per lens, in this order:

1. **Open the cite.** Read the file at that line and the surrounding path. Drop
   the finding if the diff does not support it, and name the drop in Coverage.
2. **Check the consequence.** If you cannot say what breaks and for whom,
   downgrade to Advisory or drop it.
3. **Collapse exact repeats within the lens.** Keep the first occurrence and
   its severity. Do not combine findings or choose between severities.
4. **Never merge across lenses.** The same line may be a Correctness finding
   and a Standards finding. They stay under their own headings, in the order
   their lens returned them, with their own severity. Agreement between lenses
   is not a promotion, and disagreement is not a conflict to resolve.

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

### Actionable, by lens

- **Correctness:** <P0/P1 findings, in lens order, or "nothing blocking">
- **Standards:** <P0/P1 findings, in lens order, or "nothing blocking">
- **Spec:** <P0/P1 findings, in lens order, or "nothing blocking">
```

Each lens keeps its own order. Do not build a single cross-lens list, and do
not put one lens's finding ahead of another's.

## Rules

- **Report only.** No fixes, commits, pushes, branch switches, or issue
  creation in this turn.
- **No findings is a valid result.** Say so per lens; do not pad.
- **Every finding has evidence.** Quote, cite, and name the consequence.
- **No cross-lens merge.** Findings stay under the lens that raised them, in
  that lens's order, with that lens's severity. The same defect reported by two
  lenses is two findings, not one.
- **Worst per lens, no cross-lens winner.** The axes are deliberately separate.
- **Coverage is honest.** Name the lenses that ran, the risk checks selected,
  the lenses skipped and why, and anything the review could not establish. A
  skipped lens is named, not silently omitted.
- **Keep it readable.** One finding per heading, no walls of prose. A reviewer
  should be able to act on the report without opening the diff for the P0/P1
  items.
