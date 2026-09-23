---
name: principles
description: The 23 engineering principles behind astack, indexed by when each applies. Use when a step cites a principle by name, or when choosing how much to build, where validation lives, or what counts as proof.
---

# Principles

One file per principle under `references/`. Read the file in full before applying or citing a principle. A citation with no decision behind it is name-dropping.

**Core.** How much to build and when to rethink.

- `laziness-protocol`. Refactoring, sizing a diff, or tempted to add a layer. Bias to deletion and the smallest change.
- `foundational-thinking`. Before writing logic. Core types and data structures first, scaffold before features.
- `redesign-from-first-principles`. Integrating a new requirement. Redesign as if it had been there from day one.
- `attack-the-premise`. Two or more fixes sharing one premise failed the same gate. Census the actors, then question the premise.
- `subtract-before-you-add`. Sequencing an addition or rewrite. Remove dead weight first.
- `minimize-reader-load`. Code that is hard to trace. Count layers and hidden state; collapse one-caller wrappers.
- `outcome-oriented-execution`. Planned migrations. Converge on the target, no throwaway compatibility states.
- `experience-first`. Product or scope tradeoffs. The consumer's result over implementation convenience.
- `exhaust-the-design-space`. A novel decision with no precedent. Two or three competing sketches before committing.
- `build-the-lever`. Any non-trivial work. Build the script that does or proves it. No script in the diff means you did not apply this.

**Architecture.** Where state, validation, and compatibility live.

- `model-the-domain`. Stateful logic or branching repeated across files. A structure instead of scattered conditionals.
- `boundary-discipline`. Validation and error handling. Guards at boundaries, trust internal types, pure business logic.
- `type-system-discipline`. Designing types in any typed language. Illegal states unrepresentable, brand primitives, parse at boundaries.
- `make-operations-idempotent`. Commands and loops that run amid retries. Same end state regardless of prior partial runs.
- `migrate-callers-then-delete-legacy-apis`. A new internal API while old callers exist. Migrate and delete in one wave.
- `separate-before-serializing-shared-state`. Concurrent actors might write the same thing. Eliminate the sharing first.

**Verification.** What counts as proof.

- `prove-it-works`. Before declaring done. The real artifact, not a proxy or a self-report.
- `fix-root-causes`. Debugging. Reproduce, ask why until the cause, no guards that silence symptoms.
- `sequence-verifiable-units`. Multi-step work and commit order. Each unit ends in a check before the next.
- `test-behavior-not-implementation`. Writing or keeping a test. Would it pass if every import returned nothing? Then rewrite or delete it.

**Delegation.**

- `guard-the-context-window`. Large outputs or fan-out. Bulk to subagents, summaries in the main thread.
- `never-block-on-the-human`. Tempted to ask about reversible work. Proceed, present, let the human course-correct.

**Meta.**

- `encode-lessons-in-structure`. Writing the same instruction twice. A lint, check, or script instead of more text.
