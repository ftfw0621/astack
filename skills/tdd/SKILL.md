---
name: tdd
description: Failing test first, then the fix or feature. Use when a change has a cheap local test path, when the user asks for TDD or a regression test, or from the bug-fix and feature playbooks.
---

# TDD

Make the intended behavior executable before changing production code. The goal is a focused test that fails before the change and passes after it, and that observes behavior rather than implementation. Read the `test-quality` skill for what a good test is.

Do not force a test when it would be impractical. If the only available test needs broad harness setup, brittle mocks, slow end-to-end infrastructure, production-only state, or large unrelated fixture churn, skip the new test and use the closest executable check instead, and say so.

## Workflow

1. **Understand the behavior.** Intended behavior, current behavior, affected path, smallest observable reproduction.
2. **Choose the narrowest executable check.** Prefer the unit, component, or integration test already used for that code path. Do not build a new harness just to satisfy the workflow.
3. **Write the failing test first.** The smallest test that would have caught the bug or that pins the new behavior. It calls the code the way a user does and asserts a literal expected value. Run `scripts/test-smells.sh` on it.
4. **Run it before the change.** It must fail for the intended reason. If it passes, or fails for an unrelated reason, fix the test or the reproduction before editing production code. Paste the failure.
5. **Make the change.** The smallest production change that satisfies the intended behavior and preserves nearby contracts.
6. **Rerun.** The test passes. The surrounding tests still pass. Paste the run.

## If a failing test is impractical

Before changing code, state why, then choose the closest executable regression check: a targeted script, a reproduction command, a snapshot comparison, a log assertion, a focused integration check. Prefer no new test over a bad test.

## Guardrails

- Never change a test to match a wrong implementation.
- Never weaken an existing assertion unless the expected behavior genuinely changed and the reason is stated.
- Keep the test focused on the behavior. No broad fixture churn.
- For a flaky bug, make the test deterministic where possible and name the signal being locked down.
- When the bug exposes a class of failures, land the focused test first, then consider sibling coverage.

**Reply:** the failing-before test and the failure it produced, the passing-after run, nearby validation performed, or why failing-before evidence could not be shown and the check used instead.
