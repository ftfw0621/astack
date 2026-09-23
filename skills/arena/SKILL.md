---
name: arena
description: N parallel attempts at the same artifact, then pick a base and graft the best parts of the others into it. Use for /arena, design bakeoffs, or when one attempt at a non-trivial artifact would lock in the wrong shape.
---

# Arena

Fan out N candidates at the same task. Read every candidate end to end. Pick the strongest as the base. Graft the best ideas from the others into it. Verify the result.

Open a todo list with one entry per phase: Frame, Fan out, Cross-judge, Pick, Graft, Verify.

## A. Frame

1. State the artifact each candidate produces.
2. Derive the rubric: what success looks like for this task, as three to six gradeable criteria. Candidates see only the task.
3. Pick the runners. Default three: one on the judgment role, one on the code role, one on the parent model. Spawn more when the arena covers several design directions. Same model N times when the work is generation-bound rather than judgment-sensitive.
4. Assign output paths. Each candidate gets `isolation: "worktree"`, or its own directory under the scratchpad when it writes no code (`separate-before-serializing-shared-state`).

## B. Fan out

Spawn all N with the Agent tool in one message, `run_in_background: true`, each with the task, the shared grounding path, its own output path, and the instruction to return the artifact plus a short rationale naming the alternatives it rejected. A candidate that fails proceeds as N-1, noted in the synthesis record.

## C. Cross-judge

After all candidates finish, spawn one read-only judge on a model different from the parent's. It sees the rubric and the candidates by path label, scores each criterion, and recommends a base with rationale.

## D. Pick a base

Read every candidate end to end. Score each against the rubric criterion by criterion, not on feel. Compare with the cross-judge. Agreement confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous, so read both rationales before deciding. Pick the base a future maintainer extends most easily; prefer the smaller API when tied (`laziness-protocol`). Record the pick and the reason.

## E. Graft

Walk each losing candidate once and port what is worth porting, usually one or two things. Fold each graft in by hand so the result stays under one mental model. Record grafts, sources, rejections. When candidates converge on one shape, ship the consensus and skip grafting. When they wildly diverge, the frame was under-specified: reframe and re-run rather than averaging.

## F. Verify

The synthesized artifact meets the same bar as any other output (`prove-it-works`). A problem the arena missed means either the frame was wrong (re-run) or a candidate caught it and you missed the graft (back to E).

**Reply:** one synthesized artifact and a synthesis note naming the base, the grafts with sources, the rejections, dropouts, and the verification result.
