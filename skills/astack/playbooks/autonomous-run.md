### Autonomous run

**You own the exit condition. Define done, then drive to it without stopping.**

1. State the exit condition as a checkable predicate before the first iteration: tests green, repro fixed, all N PRs merged, diff zero. A duration is not a predicate.
2. Pick the wake mechanism. An event to watch (CI, a merge, a ref advancing) gets a `Monitor` or watcher that wakes you on the event, with a long `ScheduleWakeup` heartbeat as fallback. No event gets a fixed heartbeat sized to when the result is worth re-checking. Never a sleep loop.
3. Each iteration makes the smallest change the evidence justifies, verifies it against the predicate, commits if it advanced, and reverts what did not help (`sequence-verifiable-units`).
4. Mid-run discoveries are yours: broken skills, related bugs, flaky verifiers, tooling failures. Fix them in their own PR and return to the predicate. Surface only irreversible actions, product calls, or a real dead end.
5. Log one row per iteration via the `show-me-your-work` skill.
6. Stop when the predicate is met. A plateau is not a stop. Never relax the predicate to declare victory.

**Reply:** the exit condition, iterations run, what landed, what was discarded, the final predicate state, the decision-log path.
