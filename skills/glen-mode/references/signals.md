# Signals

Metrics are notes, not gates. The repository owns the tool, the thresholds, and
the exponents; this file says what the numbers can and cannot tell you.

## CRAP

CRAP = CC² × (1 − coverage)³ + CC, where CC is the function's cyclomatic
complexity and coverage is its line or branch coverage. Branching is squared,
the absence of tests is cubed, and complexity is added back as a floor.

| Score | Reading |
|---|---|
| 1–5 | Low risk. Nothing to do. |
| 5–30 | Worth a look. Either the branches or the tests are missing. |
| 30+ | Complex and under-tested. Read the function before adding to it. |

- **The floor is CC.** At full coverage the score is exactly CC, so a threshold
  is also a ceiling on complexity: no function above it can pass, however well
  tested.
- **At low coverage the cubic term dominates.** CC 6 untested scores 42; CC 12
  untested scores 156. A CC 5 function with no tests already scores 30 while
  being only modestly branched.
- **Coverage needed falls fast as branches go.**

  | CC | Coverage for ≤ 5 | Coverage for ≤ 10 | Untested |
  |---|---|---|---|
  | 2 | 9 % | none needed | 6 |
  | 3 | 39 % | 8 % | 12 |
  | 4 | 60 % | 28 % | 20 |
  | 5 | 100 % | 42 % | 30 |
  | 6 | impossible | 52 % | 42 |
  | 8 | impossible | 69 % | 72 |
  | 10 | impossible | 100 % | 110 |
  | 11+ | impossible | impossible | 132 |

Two calibrations:

- **10** is the default for code an agent wrote or is about to change. A
  function up to CC 10 can be carried by tests; CC 11 is a split.
- **5** is the target where a person maintains the function by reading it.
  Testing stops being an escape route at CC 6 — CC 5 needs every line covered,
  and CC 6 cannot pass at all. The rule becomes design, not diligence.

Read a high score on a function you touched as a prompt to read it and ask
which invariant each branch defends. Branching that defends no invariant is the
defect; delete it and the score falls with it. Where the branches are real and
the score is coverage-driven, write the honest test or declare the gap. Never
raise coverage with a test that calls the function and asserts nothing.

## Duplication

A reported duplicate is a question, not a command.

- Is this the third occurrence? Two is a coincidence; three is a pattern.
- Do the copies change for the same reason? Two identical blocks that will
  diverge next month are not duplicated knowledge.
- Does the boundary matter? Duplication across a module or package boundary is
  usually the accident of similarity; extracting it creates the coupling the
  boundary existed to prevent.

Ignore the finding when the answer is "they only look alike".

## Mutation

Mutation testing is the closest mechanical analogue of "a test that fails
without the change": a surviving mutant is a line of code no test would miss.

- Kill the survivors in changed code; that is worth the effort.
- Chasing a global mutation score is not.
- Delete dead code rather than writing a test to cover it.

## Coverage

Coverage percentage describes the suite, not the change. It is never a
substitute for the three lists in the handover (tested, not tested and why,
departures), and never a reason to write a test that asserts implementation.

It feeds CRAP, which is a reason to read a function — not a reason to raise the
number.
