### Feature

**You own the design. Plan, review, verify.** Delegate implementation. Stay in the lead.

1. Run `how` over the affected subsystem. Produce the traced model, not a file list.
2. Name the data shape and its organizing structure per `model-the-domain`: a state machine over scattered booleans, a table or registry over branching, a typed model over repeated shape assumptions. Write it down before any logic.
3. Write the caller's usage: two or three call sites as the consumer will write them. If the change crosses a function boundary, run `architect` (which runs `arena`) and take its synthesized sketch as the contract.
4. Write the throughput checkpoint as four todo items. A dimension that does not apply keeps its item with `n/a: <reason>`.
   - Blocking first steps: gates that run before any fan-out.
   - Independent workstreams: disjoint files or layers that parallelize.
   - Shared mutable state: split the target by default (`separate-before-serializing-shared-state`).
   - Smallest safe decomposition: if one worker is best, say why.
5. Fill `references/brief-template.md` for each workstream. TESTS names the behavior tests to write first. Delegate on the `code` role in its own worktree. A workstream whose code is itself the hard part (cross-cutting design, gnarly concurrency, a subtle algorithm) goes to the `hardest` role instead. When the implementation admits several valid shapes (error handling, abstraction layer, test structure), delegate via `arena` instead so the alternatives surface and a cross-judge guards the pick.
6. Review every delegate diff yourself on the judgment role. Check the tests with the `test-quality` skill and `scripts/test-smells.sh`. Run `scripts/code-smells.sh`. Reject deviations from SHAPE or USAGE unless the delegate proved the sketch wrong, in which case redesign, do not patch.
7. Verify on the matching surface with the ACCEPTANCE commands. "Inconclusive" or wrong-surface is not a pass. Flag it.
8. Rebase into small ordered commits, each green (`sequence-verifiable-units`). Stack follow-ups rather than growing the branch.
9. If the design was contested, run `interrogate` before shipping.
10. Run **Opening a PR**.

**Reply:** what you built and for whom, the shape you chose and why, the throughput checkpoint, verification output, open decisions. A table for design alternatives.
