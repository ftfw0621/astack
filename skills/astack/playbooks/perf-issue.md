### Perf issue

**You own the measurement story. Plan, review, verify the numbers.** Tie every fix to a measurement. Do not read source instead of measuring.

1. Capture a baseline on the real surface: a profile, a trace, or a timed run of the exact scenario, with the command that produced it. Record the number and the artifact path.
2. Run `how` to ground hypotheses. Do not claim a ceiling without measuring it. Use the eight strategy families as hypothesis generators, never as a checklist. A family earns an attempt only when the trace shows the signal it names.
   - **Elimination.** The hot path may not need to exist: an unconsumed computation, an always-off gate, a redundant sync, a legacy path. The trace shows what is slow, never that it is deletable, so this needs `how`, not the profiler.
   - **Divide and conquer.** Cost scales with input. Chunk, shard, prune, or run independent pieces in parallel.
   - **Caching.** The same computation or fetch repeats on identical input. Name what invalidates it before claiming the win.
   - **Indirection.** An index instead of a scan, a queue off the interactive thread. Add the hop only when it removes more than it adds.
   - **Batching.** Many small operations each pay a fixed cost (RPC, query, syscall). Coalesce.
   - **Redundancy.** One slow instance dominates the wait. Hedge or replicate, only when the trace shows the wait dominates and there is headroom.
   - **Lazy evaluation.** Cost lands on results never used. Defer to first use.
   - **Scheduling.** The work must happen, but not now. Move it off the interactive moment and measure the interactive path, not total work.
3. Plan the fix from the trace. Cross a function boundary, run `architect` first. Delegate via `references/brief-template.md` with the baseline command in VERIFY. Review the diff. Capture a post-fix measurement with the same command (`sequence-verifiable-units`).
4. Compare the artifacts. Same scenario, same method, enough samples to clear noise. "Inconclusive" or a different scenario is not a pass.
5. Cite the measurement in the PR as `before → after` with its unit. Run **Opening a PR**.

For sustained improvement of one metric, use the Hillclimb playbook.

**Reply:** baseline number, post-fix number, delta, the command, artifact paths.
