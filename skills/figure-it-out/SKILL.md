---
name: figure-it-out
description: Design an auditable playbook when no bundled one fits: a large migration, an ambitious multi-part change, or work a human reviews after stepping away. Use for /figure-it-out, "figure it out", or a task no astack playbook matches.
---

# Figure it out

When the task matches no playbook, design one. The deliverable before any code is the workflow itself: phases that scale rigor to the task, a hypothesis loop, and a decision trail a human can audit after stepping away.

Open a todo list whose first item is to read the `principles` skill index, then the phases below.

## A. Frame

Ground first, then commit. Do not start the run until you can state:

- The definition of done as a falsifiable predicate (`prove-it-works`).
- Scope, quantified: rough units and effort, plus the blockers grounding surfaced.
- The rigor level, biased high. One-way doors and high blast radius get more. Reversible low-stakes steps get less. Rigor is gates and artifacts, not effort.

Present the framing and tradeoffs before committing to a long run. Reversible work proceeds (`never-block-on-the-human`), but a multi-hour run earns one checkpoint.

## B. Design the workflow

Decompose into atomic, independently landable units. Sequence riskiest unknown first. Scaffold and verification before features (`foundational-thinking`).

- Build the verification harness before the work, with the baseline captured from the pre-change state, so every check reads as old value versus new value.
- For one-way-door design decisions, run `architect` (which runs `arena`). Skip it for mechanical work whose shape is already concrete.
- Decide what fans out. Parallelize only across seams, each worker in its own worktree (`separate-before-serializing-shared-state`). Do not over-fan.
- Write the phase list down. That list is what the human reviews.

Add the designed steps to the todo list and run each under the Phase C loop, logging a Phase D row as each lands.

## C. Run the loop

Each unit is an experiment: state the hypothesis, make the smallest change, measure against the predicate on the real artifact, keep it if it advanced, revert it if it did not (`sequence-verifiable-units`).

- Verify by inspecting the artifact, never a self-report. When something passes too easily, suspect the observation method.
- Pair delegated work with a judge and audit the delegates' artifacts yourself. If a worker games the gate, reset and harden the brief. If the gate is wrong, fix the gate in its own change.
- A verdict is VERIFIED, NOT VERIFIED, or INCONCLUSIVE. Inconclusive is not a pass.

## D. Keep the audit trail

Log the run via `show-me-your-work`. Work this ambitious usually commits the trail so the reviewer reads it with the PR.

## E. Verify and hand back

Check the whole against the Phase A predicate on the real product, not only the harness. Encode any recurring correction as a gate, lint, or script (`encode-lessons-in-structure`).

**Reply:** the playbook you designed, the rigor level and why, the decision-trail path, what is verified against the predicate, what is still open.
