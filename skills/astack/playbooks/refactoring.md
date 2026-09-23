### Refactoring

**You own the contract. The structure changes. The behavior does not.** Distinct from Feature, which adds behavior, and Bug fix, which corrects it. If the cleanup reveals a missing feature or a real bug, split it out and ship the structural change first against the pinned contract.

1. Pin the behavior contract first. Run `how` over the area, then write a characterization test, snapshot, or equivalence harness that captures current behavior before any structure moves. Type check and lint are not a pin.
2. Name the structure the code is missing per `model-the-domain`. Boring code stays when the shape is already clear and local. The reshape must delete branches or invalid states, not add indirection.
3. Name the target shape: module layout, types, call graph as if built today (`redesign-from-first-principles`). Run `architect` when the target crosses a function boundary.
4. Subtract before you add. Delete dead code, collapse one-caller wrappers, drop redundant validators, remove orphan references, then introduce the new shape. The smallest change that reaches the target ships (`laziness-protocol`).
5. Move in small behavior-preserving steps, each keeping the pin green. Migrate every caller and delete the old API in the same wave (`migrate-callers-then-delete-legacy-apis`). No compatibility shims. Spot-check every rename against strings, prose, and back-references. Delegate mechanical edits via `references/brief-template.md`. Review the diff yourself.
6. Prove behavior is unchanged on the real artifact: an old-versus-new output diff, a replayed baseline, or a smoke run. Run `scripts/code-smells.sh`. Do not trust a delegate's "looks good".
7. Confirm the change is worth keeping. The success measure is reduced reader load (`minimize-reader-load`). If the diff does not lower reader load somewhere, revert it.
8. Rebase into ordered commits: subtraction, then reshape, then follow-on cleanup. Run **Opening a PR**.

**Reply:** the structure that changed, the pin you held it against, the equivalence proof, the reader-load delta, what shipped and what you reverted. No new behavior.
