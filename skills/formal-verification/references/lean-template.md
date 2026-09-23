# Lean template

The shape that keeps a proof tied to the code.

## Project

```bash
elan default stable
lake new <name> math      # with Mathlib; use `lake new <name>` without it
cd <name> && lake build
```

Keep the project under the repo's formal directory (for example `formal/lean/<name>/`). Commit `lakefile.lean`, `lean-toolchain`, `lake-manifest.json`, and the sources. Do not commit `.lake/`.

## Conformance table

At the top of the main file, one line per definition:

```lean
/-!
Conformance (source of truth is the code; this file models it):
  `slugify`      <- src/lib/slug.ts : slugify        (ASCII only; Unicode folding abstracted away)
  `checksum`     <- src/go/addr/checksum.go : Checksum
Abstractions: integers are unbounded here; the Go code uses int64 and the
  differential test covers the overflow boundary.
-/
```

## Definition and theorem

```lean
def slugify (s : String) : String := ...

/-- Property 1 from the triage record: slugify is idempotent. -/
theorem slugify_idempotent (s : String) : slugify (slugify s) = slugify s := by
  ...
```

No `sorry`. After the proof:

```lean
#print axioms slugify_idempotent
```

Acceptable output names only `propext`, `Classical.choice`, and `Quot.sound`. Anything else needs a written justification in the README.

## Differential test in the host language

The proof covers the Lean model. This test ties the model to the real code. Generate inputs, run the real implementation, assert the same property.

```go
func TestSlugifyIdempotent(t *testing.T) {
	rapid.Check(t, func(t *rapid.T) {
		s := rapid.String().Draw(t, "s")
		if got := Slugify(Slugify(s)); got != Slugify(s) {
			t.Fatalf("not idempotent for %q: %q", s, got)
		}
	})
}
```

```python
@given(st.text())
def test_slugify_idempotent(s: str) -> None:
    assert slugify(slugify(s)) == slugify(s)
```

Use the property-testing library the repo already has (rapid or gopter for Go, hypothesis for Python, fast-check for TypeScript). Add one only when none exists, and say so in the PR.

## README next to the project

The build command, the `#print axioms` output for every theorem, the conformance table, and the differential test's location.
