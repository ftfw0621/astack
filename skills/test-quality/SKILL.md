---
name: test-quality
description: The mechanical check for whether a test observes behavior. Use when writing, changing, reviewing, or keeping any test, and from the feature and bug-fix playbooks. Pairs with scripts/test-smells.sh.
---

# Test quality

A test calls the code the way its users do and asserts the result they observe against a literal expected value. Everything else is the `test-behavior-not-implementation` principle applied as a checklist.

## The one question

Would this test still pass if every function it imports returned nothing (`undefined`, `None`, the zero value)? If yes, it observes no behavior and cannot fail for a defect. Rewrite the assertion or delete the test.

## Five shapes that fail the question

| shape | looks like |
|---|---|
| Weak or no assertion | no assertion; only `toBeDefined`, `toBeTruthy`, `not.toThrow`, `toBeInstanceOf`, `toBeGreaterThan(0)`; only `assert x`, `assert x is not None`, `assertIsInstance`; only `require.NoError`, `assert.NotNil`, `assert.True` |
| Mock or absence only | only `toHaveBeenCalled`, `not.toHaveBeenCalled`, `assert_called_once`, `AssertExpectations`; only `toBeUndefined`, `toEqual([])`, `toHaveLength(0)`, `assert x == []`, `assert.Empty` |
| Self-referential | the expected value comes from the code under test: `expect(f(a)).toBe(f(a))`, `assert build(x) == build(x)`, `want := fn(in)` |
| Constant pin | the assertion restates a hand-maintained constant, config default, table row, or prompt string |
| Fixture asserts fixture | the assertion reads data the test built, or a value computed in setup, and the subject never runs in the body |

## The fix

Call the subject inside the test body with one concrete input and assert the literal output or the observable effect. For an absence, assert the presence on the other input in the same test. For a constant, test the mechanism that reads it with one input instead of restating the value. For a mock, assert the payload it received or the state after the call, not that it was called. When no such assertion exists, delete the test.

Keep: a relation across a table's rows (a key present in two tables), and compile-time type tests.

## The script

`scripts/test-smells.sh [--base <ref>] [files...]` scans Go, Python, and TypeScript test files and prints `file:line: <smell>` for tests with no assertion, tests whose assertions are all weak, and lines using weak matchers. It sees shapes 1 and 2 and part of 3. Shapes 4 and 5 need your eyes.

Run it on every test you write or change. Every line it prints is either fixed or justified in one sentence in the PR body. A test with no assertion is never justified.

## Placement and naming

Put the test where the repo already tests that code path. Name it after the behavior and the input ("returns the canonical slug for a mixed-case address"), not the function. One behavior per test. A table-driven test is one behavior with several inputs.

**Reply:** for each test touched, the behavior it asserts and the literal expected value, plus the script's output and what you did about each line.
