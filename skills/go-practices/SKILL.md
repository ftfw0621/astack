---
name: go-practices
description: Go best practices grounding the type-system, boundary, and test principles in Go syntax. Use when reading or editing any .go file.
paths: ["**/*.go"]
---

# Go practices

Apply the `type-system-discipline` and `boundary-discipline` principles first.

| Rule | Summary |
|------|---------|
| Sum types | Variants that carry data are a sealed interface: an unexported marker method (`isShape()`) that only this package's types implement. Variants without data are a named type with `const` values. A tagged struct is fine only when every field is valid for every tag. Never a `Kind string` beside fields only some kinds use. |
| Exhaustive switches | A switch over a sum type or enum names every variant, and its `default` panics or returns an error. Enable the `exhaustive` linter for enums and `gochecksumtype` for sealed interfaces, both with `default-signifies-exhaustive: false`, so a new variant fails lint at every switch. |
| No `any` inside | `any` and `interface{}` appear only at a boundary (decoding, `fmt`, `slog`). Use generics for containers; `[T any]` as a constraint is fine. Leave `any` through a type switch or `v, ok := x.(T)`, never a bare `x.(T)`. |
| Parse at the boundary | JSON, proto, env, flags, and DB rows go through one `parseX(raw) (X, error)` that returns a domain type. Inside, trust it: no re-validation, no nil check the parse already ruled out, no wire, proto, or `sql.Null*` type past the edge. |
| Typed identifiers | `type OrderID string`, not bare `string`, wherever two values share a primitive but differ in meaning. Build it with `ParseOrderID(s string) (OrderID, error)` and convert with `OrderID(s)` nowhere else. |
| Valid by construction | Make the zero value work (`sync.Mutex`, `bytes.Buffer`, a nil slice) or unexport the fields and construct through `NewX(...) (X, error)`, which never returns an invalid `X`. Pick the shape that cannot hold the bad value: start plus duration, not two times that must stay ordered. |
| Wrapped errors | Wrap with `fmt.Errorf("load order %s: %w", id, err)`. Branch with `errors.Is` and `errors.As`, never `==` on a sentinel or a match on `err.Error()`. Export a sentinel or error type only when a caller branches on it. Return or handle each error once. Never `_ = err`. |
| Context first | `ctx context.Context` is the first parameter of anything that blocks, does I/O, or starts work. Never a struct field, never `nil`. `context.Background()` belongs in `main`; tests use `t.Context()`. |
| No package state | No mutable package-level `var` (clients, caches, registries, config) and no `init()` that does I/O, reads env, or registers globals. Build dependencies in `main` and pass them in. `const`, sentinel errors, and compiled regexps are fine. |
| Owned goroutines | The function that starts a goroutine owns it: it waits (`errgroup.WithContext` or `sync.WaitGroup`), collects the error, and gives it a way to stop (`ctx`). No bare `go f()` that outlives its caller. |
| Pure core, thin shell | Business rules are pure functions of domain values: no `ctx`, I/O, logger, or `time.Now()`; pass `now` in. Handlers and jobs only read, call the core, and write. |
| Consumer interfaces | The package that calls a dependency declares the interface, with only the methods it calls. Accept interfaces, return concrete structs. No interface beside its only implementation, no constructor that returns an interface. |
| Table tests with literal want | Cases in a `[]struct{...}` table, each with a literal `want`, run under `t.Run` and compared with `cmp.Diff(tc.want, got)` or `assert.Equal`. A test whose only assertions are `require.NoError` and `assert.NotNil` observes nothing (the `test-quality` skill). |
| Run, don't mock | Use the real thing: the real type, `httptest.NewServer`, `t.TempDir()`, a test database. When you must substitute, write a fake with behavior (an in-memory store) and assert on results and its state, never on recorded calls (`AssertExpectations`, `EXPECT()`). |
| Structured logging | Log through `log/slog` or the project logger, with key-value attributes and an ID to search by. No `fmt.Println`, `log.Printf`, or `println` in shipped code. |
| Generated code is derived | Files marked `// Code generated ... DO NOT EDIT.` (protoc, sqlc, mockgen) change only by editing the source and regenerating. Do not hand-write a struct that mirrors a generated type; parse the generated type into the domain type at the boundary. |

## Tells

- `any` or `interface{}` in a signature that does not decode or encode.
- `_ = err`, or a bare `x.(T)` with no `, ok` outside a type switch.
- A `switch` on a `string` field against string literals. That string should be a type.
- `go func` with no `ctx`, `errgroup`, or `WaitGroup` in the same function.
- `context.Context` as a struct field, or `context.Background()` outside `main`.
- `func init()`, or a package-level `var` assigned after startup.
- `time.Sleep` in a `_test.go` file. Wait on a channel or inject the clock.
- `TODO`, `FIXME`, or `fmt.Println` left in shipped code.

`scripts/code-smells.sh` flags `interface{}`, type assertions, `_ = err`, and `TODO`. `scripts/test-smells.sh` flags Go tests whose assertions are all weak.

Examples: `references/patterns.md`.
