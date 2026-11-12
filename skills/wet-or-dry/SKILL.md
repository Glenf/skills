---
name: wet-or-dry
description: >
  Use when the user asks for DRY/WET, Rule of Three, or a simplify pass on a
  change. Covers duplication and over-abstraction in a diff. Not for bug hunts,
  style, or whole-repo audits.
argument-hint: "[fixed-point | path] [fix]"
---

# wet-or-dry

Duplication is a question, not a command. Every copy and every abstraction in
the change gets a verdict with its evidence: **leave**, **reuse**, **extract**,
**inline**, or **delete**. Fewer lines is not the goal; the goal is one home
for each piece of knowledge, and no home that holds nothing.

## 1. Pin the scope

First hit wins:

1. A ref or path the user named. Never widen it.
2. The branch against its base: `git diff <base>...HEAD`.
3. Staged and unstaged changes: `git diff HEAD`.
4. Files edited earlier in this conversation.

Keep human-written code and its tests. Drop prose, config, data, generated and
vendored files, lockfiles, and mechanical churn. Nothing left? Say "nothing to
check" and stop.

Read `GLOSSARY.md` and any ADR that binds the changed area. Deliberate
duplication or separation an ADR names is settled; do not re-litigate it.

## 2. Find the candidates

Read every changed hunk in its file. Collect two lists:

- **Copies** — blocks in the diff that repeat each other, and blocks that
  repeat code already in the repo, the standard library, or a dependency the
  project already uses. Search the repo for the concept by name and by shape,
  not only for identical text. On a large diff, hand that search to an
  `Explore` sub-agent and keep only its `file:line` list.
- **Abstractions** — every function, type, module, parameter, or flag the
  diff adds or widens. Count its present callers.

Done when every changed hunk is accounted for in a list or judged clean.

## 3. Judge each copy

Ask in order; the first decisive answer is the verdict.

1. **Is there already a home?** An existing helper, stdlib call, or platform
   guarantee does the job → **reuse**. No count needed: the home already exists.
2. **Same knowledge?** Would every copy change for the same reason, at the same
   time? If they only look alike → **leave**.
3. **Across a boundary?** Copies in different modules or packages usually stay
   apart; extracting them couples what the boundary separated → **leave**,
   unless the knowledge is a shared contract (a format, a protocol, a rule
   the business owns).
4. **Third occurrence?** Three copies of the same knowledge → **extract**. Two
   → **leave**, and note it so the third is recognised.

## 4. Judge each abstraction

Apply the **deletion test**: inline it in your head. Does complexity
concentrate at the callers (keep), or only move there (inline)?

- **No present caller** → **delete**. Speculative config, unused parameters,
  hooks for an imagined second consumer.
- **One caller, shallow** — the interface is nearly as large as the body, or it
  only forwards → **inline**.
- **Grows a flag or parameter per caller** — the copies were not the same
  knowledge → **inline**, and let each caller keep its own version. The wrong
  abstraction costs more than the duplication it removed.
- **Deep** — a narrow interface over real behaviour, with tests through that
  interface → **leave**, even with one caller.

Order findings by how often their files change
(`git log --oneline -- <path> | wc -l`), most first. Knowledge that changes
often pays most for one home.

## 5. Report

One line per finding, in the `ste-report` format, the verdict as the label:

```
`src/price.ts:40-52` · extract — The VAT rule is now in three places (`cart.ts:88`, `invoice.ts:31`). Move it to `vatFor()` in `price.ts`.
`src/sync/retry.ts:1-30` · inline — `withRetry()` has one caller and only forwards its arguments. Inline it into `pull()`.
`src/api/date.ts:12` · reuse — `formatIso()` reimplements `Date.prototype.toISOString`. Call the built-in.
```

Under the findings, list the **leave** verdicts as one line each with the
deciding reason (looks alike, crosses a boundary, second occurrence). The
reader needs to see that a copy was judged, not missed.

End with a one-line balance: where the change sits — too WET, too DRY, or
neither — and the evidence for it.

Report only, unless the user said `fix` or the caller is glen-mode.

## 6. Apply (only when asked)

- Re-read each finding against the current code; skip any whose code changed.
- Each fix keeps outputs, errors, side effects, and ordering. If you cannot
  show that, skip it and say so.
- Edits stay inside the scope from step 1, plus the import lines they need.
- Run typecheck, lint, and the tests that cover the blast radius. The same
  unmodified tests must pass. A test you had to change means behaviour
  changed: revert that fix.
- Never weaken or delete a test to make a check pass. If the project has no
  tests, lint, or typecheck, say so.

Close with applied, skipped and why, and the check results.
