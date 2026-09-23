### Hillclimb

**You own the metric and the experiment's integrity. Supervise and review. Delegate the attempts.** Sustained, iterative improvement of one measurable thing against a target. A one-off fix is Bug fix or Perf issue. This is the loop.

One change, one measurement, keep or revert. Never stack untested changes. Never claim a win from code inspection (`prove-it-works`).

1. Ground the workload with `how`. Name the realistic dimensions that move the result (data size, history, concurrency) and pick a case that reproduces the complaint. No reproducing case means fix the repro, not hillclimb. Then fix one metric, the direction that counts as better, and a stop predicate that pairs a target with a floor on attempts ("at least 50% better than baseline and at least 10 iterations"), so a lucky early win cannot end the run.
2. Build the measurement harness, prove its sensitivity on contrasting workloads, then freeze it (`build-the-lever`). One repeatable command emits the metric, sampled enough to clear noise (median of N). Record the baseline and a green run of the regression gate before any change.
3. Open the decision log via `show-me-your-work`: one row per attempt with hypothesis, change, before, after, delta, gate result, verdict.
4. Ground each hypothesis in a mechanism ("defer X off the boot path because it blocks first paint"), never "try memoizing something".
5. Loop, one hypothesis per iteration. Delegate the change via `references/brief-template.md` in its own worktree. Fan independent hypotheses to parallel delegates, each in its own worktree. Measure before and after with the frozen harness and run the gate. Accept only when the metric moves past noise and the gate stays green. Otherwise revert in full. One commit per accepted fix, staging only the files you changed. Log the row either way. If unattended, borrow the wake mechanism from the Autonomous run playbook, not its stop rule.
6. Push past the first plateau. On several rejects in a row, pivot category, combine near-misses, re-read the source, or try something more radical. Correctness and simplicity outrank the number. Revert a win that breaks behavior. Keep a simplification that holds the number.
7. Stop when the predicate is met or the remaining ideas are marginal. Never relax the predicate. Surface a stall instead of spinning.
8. Run **Opening a PR** with the accepted commits in the order they landed.

**Reply:** the metric and target, baseline to final with percent delta, iterations kept versus reverted, each accepted fix in one line, the decision-log path, and the best untried idea.
