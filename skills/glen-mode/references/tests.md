# Tests

The method behind the Beat 1 gate: every behaviour change has a test that fails
when the change is reverted.

## A good test

- Verifies behaviour through a public interface, not implementation detail.
- Reads like a specification: "user can check out with a valid cart" names a
  capability and survives a refactor.
- Would fail if the behaviour were removed. That is the only reason it exists.

## Seams

A **seam** is the public boundary where behaviour is observable without
reaching inside.

Agree the seams before writing tests. For each:

```
Seam: <public interface>
Catches: <the behaviour this would defend>
Misses: <what this seam cannot see>
```

You cannot test everything. Agreeing the seams is how effort lands on the
critical path and complex logic instead of every edge case.

When the shape of the interface is itself in question, settle that first. A
test written against a bad interface certifies the bad interface.

## Red-first

Use red-first where the contract is knowable before the code exists: pure
logic, decision rules, resolution ladders, parsers of settled formats.

1. Write the failing test.
2. Run it. See it fail for the expected reason.
3. Make the smallest change that passes.
4. Repeat, one seam at a time.

Do not write all tests first. Bulk tests verify imagined behaviour and commit
to test structure before you understand the implementation.

Restructuring belongs to the *right* pass, after the slice's behaviour is
proven.

Never weaken a valid test just to make an implementation pass. If a test is
wrong, establish why and correct it explicitly.

If the interface is still being discovered, investigate or prototype until the
contract is settled, then write tests against that intent.

## Test-after, honestly

Test-after is acceptable only against a settled interface. Remove its risk:

1. Write the test against the public seam.
2. Revert the implementation change.
3. Run the test. It must fail.
4. Restore the change. It must pass.

If step 3 cannot fail, the test is evidence of nothing. Rewrite it or delete it.

## Anti-patterns

**Implementation-coupled.** Mocks internal collaborators, tests private
methods, or verifies through a side channel. The tell: it breaks when you
refactor without changing behaviour.

**Tautological.** The assertion recomputes the expected value the way the code
does:

```
expect(add(a, b)).toBe(a + b)
```

It passes by construction and can never disagree with the code. Expected values
come from an independent source: a known-good literal, a worked example, the
spec.

**Padding.** Would this test still pass if every function returned nothing? If
yes, it asserts nothing that matters.

**Horizontal slicing.** All tests first, then all code. Work in vertical slices:
one test, one implementation, repeat.

## Coverage of a slice

By the end of the *right* pass:

- Every rule, branch, and error path the slice introduces is encoded.
- Pure functions are covered branch by branch.
- Integration points run the real path, not a mock of it.
- If a module is hard to test, the design is wrong. Fix the design.

Coverage percentage describes the suite, not the slice. It is never evidence on
its own, and never a reason to write a test that asserts implementation.

## Mocking

Mock at the boundary you do not own: network, time, filesystem, third-party
services, randomness.

- Fake the boundary, then assert observable behaviour.
- Prefer a small in-memory fake over call expectations.
- Three mocks in one test means the seam is in the wrong place.
- Time and randomness get injected, not patched globally.

## Gaps

Write no test rather than a bad one, and never leave the gap silent.

Record what is not tested, why the honest test is impractical, what risk that
leaves, and where the mitigation lives. The gap belongs in one line at the code
site, in the handover, and in the ticket when one exists.
