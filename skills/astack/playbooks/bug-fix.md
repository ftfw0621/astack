### Bug fix

**You own this task. Plan, review, verify.** Delegate investigation and the edit. Stay in the lead.

Be scientific. Every shipped line traces to runtime evidence. A belt-and-suspenders change that "might help" is a hypothesis, not a fix, and does not ship. When evidence refutes a hypothesis, revert what it motivated.

1. Reproduce it yourself on the cheapest real surface: a failing test, a script against the real code, or the running service. Ask the user to reproduce only with a stated reason you cannot reach the surface, and only after driving it as far as it goes. Paste the failing output.
2. Binary-search the cause on the `hardest` role (yourself when you are the parent, otherwise a delegate on that role). List the candidate hypotheses, seeded by `how` over the affected subsystem. Each pass takes the split that cuts the most problem space, gets runtime evidence, and eliminates. When state is unclear, add instrumentation and read it. Do not guess. Confirm the surviving mechanism with runtime evidence before planning the fix.
3. Plan the fix. If it crosses a function boundary, run `architect` first. Only now, with the cause confirmed and the fix planned, fill `references/brief-template.md` and delegate the edit on the `code` role. TESTS names the regression test from step 4. A fix that is itself subtle (concurrency, an algorithm) goes to the `hardest` role instead.
4. Write the failing test first per the `tdd` skill when a cheap local test path exists. Check it with the `test-quality` skill and `scripts/test-smells.sh`. When no cheap test exists, say why and name the closest executable check.
5. Review the delegate's diff yourself. Run `scripts/code-smells.sh` on it. Reject guards that silence the symptom instead of fixing the cause (`fix-root-causes`).
6. Verify on the same surface as step 1. The original repro now passes. "Inconclusive" or a different surface is not a pass.
7. Stage commits so the failing test lands before the fix (`sequence-verifiable-units`).
8. Run **Opening a PR**.

**Reply:** what was broken, the root cause with the evidence that proved it, the fix, how you verified. Paste failing-then-passing output verbatim.
