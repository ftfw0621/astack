---
name: formal-verification
description: Decide whether code needs formal verification and do it when it does. Use for "should we formally verify this", concurrency or distributed protocols, state machines with money or compliance invariants, or when asked for TLA+ or Lean.
---

# Formal verification

Tests sample the space. A model checker or a proof covers it. That coverage is expensive, so the first job is deciding whether the code earns it. The second job is making the spec or proof mean what the code does, because a proof about a model that drifted from the code proves nothing.

## 1. Triage

Fill `references/triage.md` for the code in question. It scores the cost of a wrong answer, the size of the input or interleaving space, and whether a test can cover that space. The outcome is one of:

- **Tests suffice.** Behavior tests plus property-based tests where the space is large. Stop here and say why.
- **TLA+.** Concurrency, distribution, retries, crashes, locks, idempotency, ordering, at-most-once or exactly-once, state machines whose safety or liveness invariant the business depends on. Model checking finds the interleaving a test never runs.
- **Lean.** A pure function or algorithm whose property must hold for every input: encoders and decoders that must round-trip, checksum and address-format validators, arithmetic with rounding or overflow, ordering and merge functions, access-control decision functions. A theorem replaces an infinite test.
- **Both.** A protocol whose steps call a pure function with its own property.

Write the decision as a short record in the PR or the design doc: the code, the properties, the outcome, the reason. Every property is a sentence a reviewer can disagree with ("no migration DDL commits twice", "decode(encode(x)) = x").

## 2. Doctor

Check the toolchain before promising anything. TLA+: `java -version` (11 or newer) and `tla2tools.jar` (download from the tlaplus releases page into `~/.local/share/tla/` if absent, and record the version). Lean: `elan`, `lean`, `lake` (install with the elan installer if absent). If a tool cannot be installed, deliver the triage record and the property-based tests, and say plainly that the formal step is blocked. Never fake a run.

## 3. TLA+ path

Follow `references/tla-template.md`.

1. Write the spec from the code's state, not from its prose. Variables mirror the real state (rows, locks, per-actor phase). Each action mirrors one code step and the header carries a code-mapping table: action name to file and function.
2. State the modelling assumptions in the header. Each is a platform or design guarantee the spec relies on, not something it proves (a transaction commits atomically, a session lock dies with its session).
3. State the invariants (safety) and properties (liveness) in the language of the triage record.
4. Add bug switches: one CONSTANT per debated design element (`UseLock`, `RecheckUnderLock`). The real protocol sets them all TRUE.
5. Write one config for the real protocol at a small scale, one at a larger scale, and one negative config per bug switch that flips it and names the invariant that must fail. A negative config that passes means the invariant does not capture the bug or the model does not exercise it. Fix the model before trusting the positive run (the distinguishing-mutant rule).
6. Run TLC on every config: `java -cp tla2tools.jar tlc2.TLC -workers auto -config <cfg> <spec>.tla`. Positive configs complete with no errors. Negative configs produce a counterexample trace. Paste state counts and the trace head.
7. Land the spec, configs, and a README with the exact commands and the run results under `docs/design/<area>/tla/` or the repo's formal directory.

## 4. Lean path

Follow `references/lean-template.md`.

1. Create or reuse a `lake` project under `formal/lean/` (or the repo's formal directory) with Mathlib when the property needs it.
2. Transliterate the function into Lean 4 as faithfully as the language allows, and keep a conformance table: Lean definition to source file and function. Where the host language has behavior Lean lacks (integer overflow, floating point), model it explicitly or state the abstraction in the table.
3. State each property from the triage record as a theorem. Prove it. No `sorry`. Run `lake build` and `#print axioms <theorem>` and paste both. Only standard axioms (`propext`, `Classical.choice`, `Quot.sound`) are acceptable without discussion.
4. Close the gap between the Lean definition and the real code with a differential test in the host language: a property-based test that runs the real implementation on generated inputs and asserts the same property the theorem states. The proof covers the model. The test ties the model to the code.
5. Land the project, the conformance table, and a README with the build command and the axiom output.

## 5. Keep it honest

- A spec or proof that no longer matches the code is worse than none. The conformance table is the contract. Update it in the same PR that changes the mapped code, and rerun the checks.
- Bound the model deliberately. State why the chosen constants (3 replicas, 2 versions, 1 restart) exercise the interesting interleavings.
- Never cite a proof for a property the triage record did not name.

**Reply:** the triage record with the outcome and reason. For TLA+: the properties, the bug switches, and per config the state count and result, with the negative-config traces. For Lean: the theorems, the `lake build` and `#print axioms` output, and the differential test. For blocked runs: what is missing and what shipped instead.
