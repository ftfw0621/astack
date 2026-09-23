---
name: code-quality
description: The strict maintainability standard for any diff: abstraction quality, spaghetti growth, file size, boundary and type cleanliness. Use for a code quality audit, as the review lens inside interrogate, or as the self-check before opening a PR.
---

# Code quality

The standard every diff is judged by, and the lens every reviewer applies. Be ambitious about structure. Do not stop at local cleanup. Look for the "code judo" move: a restructuring that preserves behavior while whole branches, helpers, modes, or layers disappear.

Two halves. `scripts/code-smells.sh --base <base>` flags what a script can see. The catalog below is what it cannot.

## Core prompt

> Perform a deep code quality audit of the changes. Rethink how to structure the change to meaningfully improve quality without changing behavior. Improve abstractions and modularity, reduce spaghetti, improve succinctness and legibility. If there is a clear path to a dramatically simpler implementation that involves restructuring, go for it. Measure twice, cut once.

## Rules

0. **Simplify structurally.** Assume a reframing exists that makes branches, helpers, or layers vanish. Prefer deleting complexity over rearranging it.
1. **No file crosses 1000 lines in a diff** without a strong reason. Decompose first.
2. **No spaghetti growth.** A new ad-hoc conditional, scattered special case, or one-off branch in an unrelated flow is a design problem, not a nit. Push it into a helper, a state machine, a table, or a module.
3. **Clean the design, do not accept working code.** Prefer simplifications that remove moving pieces over refactors that spread the same complexity around.
4. **Direct, boring code over hacky or magical code.** Flag generic mechanisms hiding simple data-shape assumptions, thin abstractions, identity wrappers, pass-through helpers.
5. **Type and boundary cleanliness.** Question needless optionality, `any`, `unknown`, `interface{}`, casts, and silent fallbacks that paper over an unclear invariant. Validate once at the boundary, trust inside (`boundary-discipline`).
6. **Logic in its canonical layer.** Feature logic leaking into shared paths, implementation details leaking through APIs, a bespoke helper next to an existing canonical one, code in the wrong package.
7. **Orchestration and atomicity.** Independent work serialized for no reason, or related updates that can leave state half-applied, when a cleaner structure is obvious.

## Smell catalog

Design (from `architect`'s red flags and `minimize-reader-load`):

- Shallow module: a wide interface hiding little. Callers coordinate several methods for one operation.
- Information leakage: one internal decision (a representation, a policy, a wire format) known in more than one place.
- Temporal decomposition: modules by execution order (load, validate, transform, save) instead of by the knowledge they own.
- Pass-through method: forwards the same arguments to another method of the same shape.
- Layers a reader must trace, or hidden state a reader must hold. The test: can a new reader answer "where does X come from" and "what can change X" in 30 seconds?

Code:

- A boolean that must stay in sync with another boolean. A second optional field that is only meaningful with the first.
- An if/else chain that grew by one more branch instead of becoming a table or a variant.
- A retry, guard, or null check added without a reproduced failure.
- A comment explaining a workaround instead of a fix (`fix-root-causes`).
- Duplicated validation of data already validated at the boundary.
- A compatibility shim or dual path kept for internal callers (`migrate-callers-then-delete-legacy-apis`).
- Configuration or parameters for cases that do not exist yet. Dead code, unused imports, vestigial parameters.
- A cast, `as`, `interface{}`, or `# type: ignore` away from a boundary.
- Sequential awaits on independent work.

Fowler (Refactoring ch. 3):

- Mysterious name: a name that does not say what it holds or does. No honest name means the design is murky.
- Feature envy: a method reading another object's data more than its own. Move it there.
- Shotgun surgery: one logical change scattered across many files. Gather it.
- Divergent change: one module edited for unrelated reasons. Split it.
- Message chain: a caller walking `a.b().c().d()`. Hide the walk behind one method.
- Refused bequest: an implementer ignoring most of what it inherits. Compose instead.

## Remedies, in preference order

Delete a layer rather than polish it. Reframe the state model so conditionals disappear. Move the ownership boundary so the feature is a natural extension of an existing abstraction. Turn special cases into a simpler default with fewer exceptions. Replace a condition chain with a typed model or a dispatch table. Extract a pure function. Split the large file. Reuse the canonical helper. Make the type boundary explicit so control flow simplifies. Parallelize independent work when that also simplifies the orchestration.

Do not be satisfied with "maybe rename this" when the issue is structural. Do not be satisfied with a cleaner version of the same messy idea when a much simpler idea is plausible.

## Output order

1. Structural regressions. 2. Missed dramatic simplifications. 3. Spaghetti and branching growth. 4. Boundary, abstraction, and type-contract problems. 5. File size and decomposition. 6. Modularity. 7. Legibility.

Few high-conviction findings over many cosmetic ones. Be direct and demanding, not rude.

## Approval bar

Behavior being correct is not enough. Presumptive blockers unless the author justifies them: incidental complexity kept when a code-judo move would delete it; a file pushed past 1000 lines; ad-hoc branching that tangles an existing flow; feature checks scattered across shared code; an unnecessary abstraction, wrapper, or cast-heavy contract; a duplicated helper or logic in the wrong layer.

**Reply:** findings in the output order above, each with file and symbol, the rule or smell it violates, and the remedy. Then the approval verdict against the bar.
