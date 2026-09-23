---
name: architect
description: Design before code. Use for /architect, "design this", or any change that crosses a function boundary, where jumping to code would lock in the wrong shape. Sketches usage, types, and module structure, compares candidates, then implements against the sketch.
---

# Architect

Sketch the caller's usage, then types, signatures, and module boundaries with `not implemented` bodies. Compare at least two candidates, synthesize one, implement against it. If implementation proves the sketch wrong, throw it out and redesign.

Open a todo list with one entry per phase before starting: Ground, Sketch, Agree, Implement, Scrap.

## Phase A. Ground

Run the `how` skill over every system the new code touches. Naming a file is not grounding. Produce the traced model. If the design moves ownership or layering, also learn why the current shape exists (the `why` skill when installed, otherwise `git log -p` and the linked PRs) so the rationale becomes a constraint, not a guess. Skip only for genuinely greenfield work.

## Phase B. Sketch

Run the `arena` skill with the design task and the Phase A artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`, with the caller's usage written before the types.

Design it twice. Require at least two structurally distinct candidates before synthesis, even when the first looks sufficient (`exhaust-the-design-space`). Whole-shape alternatives, not point fixes inside one shape.

Screen every candidate against `references/design-red-flags.md`: shallow modules, information leakage, temporal decomposition, pass-through methods. Compare the survivors on interface depth. Prefer the design that hides more complexity behind a smaller surface.

Arena returns one synthesized package. Its pick and grafts fill the rationale's "Synthesis decision" section.

## Phase C. Agree (opt-in)

Default: proceed to implementation. Pause for sign-off only when asked ("with checkpoint", "show me before implementing"). Human pushback on the shape is Phase A evidence: re-ground and re-run Phase B. For adversarial pressure before implementing, run `interrogate` on the sketch.

## Phase D. Implement against the sketch

Replace `not implemented` bodies with code. The sketch is the contract in the delegate's brief (SHAPE and USAGE fields). A deviation is signal: ask whether the sketch was wrong, a requirement was missed, or the implementation is overreaching. Surface it, do not absorb it.

## Phase E. Scrap when the architecture is wrong

Scrap on a pattern, not one instance: the same workaround shape repeating, unrelated edge cases each needing a branch, types needing escape hatches (`any`, casts, optional fields always set), a "we need a lock" reflex where the sketch said state was not shared, callers needing the abstraction's internal rules. Then re-run `how` over what was built, redesign as if the new constraints were day-one (`redesign-from-first-principles`), subtract first, and return to Phase B.

**Reply:** the usage sketch, the type sketch or module map, the rationale per the template, the synthesis decision, and the first implementation step.
