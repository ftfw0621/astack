---
name: typescript-practices
description: TypeScript best practices grounding the type-system, boundary, and test principles in TypeScript syntax. Use when reading or editing any .ts or .tsx file.
paths: ["**/*.ts", "**/*.tsx"]
---

# TypeScript practices

Apply the `type-system-discipline` and `boundary-discipline` principles first.

| Rule | Summary |
|------|---------|
| Discriminated unions | Model variants with a `kind` literal discriminant so impossible states can't be represented. No optional-field bags. |
| React state as a union | One `useState` over a `kind` union (`loading`, `error`, `ready`), not separate `loading`, `error`, and `data` hooks that can disagree. See `model-the-domain`. |
| Branded types | Brand primitives with `& { readonly __brand: "X" }` so they can't be mixed up. Validate once at the boundary. |
| Constructive modeling | Build the shape so the illegal value can't be constructed. `[T, ...T[]]` for non-empty, `[T, T][]` for even length, `start` plus `duration` for a range. Not a runtime guard, not a wish for refinement types. |
| Simplest total type | Keep `T[]` while every operation on it stays total. Strengthen to `NonEmpty<T>` only where the loose type forces `!`, a cast, or a "should never happen" throw. |
| No `enum` | Use an `as const` object or a literal union. `enum` emits runtime code, and a numeric one accepts any `number`. |
| `readonly` unless mutated | Mark array and object types the code never mutates: `readonly T[]`, `readonly` fields. `Readonly<T>` is shallow. |
| `unknown` over `any` | External data is `unknown`. |
| Schemas before guards | Before hand-writing a property-by-property type guard, use the repository's runtime schema library and infer the type from the schema, such as `z.infer`. |
| No `as` casts | Every `as` is a runtime crash waiting. Cast only after validation. |
| Narrowing hierarchy | Discriminant switch > `in` operator > `typeof`/`instanceof` > user-defined type guard > `as`. |
| Type guards | Must verify the claim. A lying guard is worse than `as` because the bug hides behind a name that says it's safe. Name them `isX` or `hasX`. |
| Exhaustiveness | Inline `const _exhaustive: never = x;` in default arms so the compiler errors when a new variant is added. |
| `satisfies` over `as` | Validates the value without widening literal types. |
| Boundary validation | Parse where data crosses in, into a named domain type. `Record<string, unknown>` (however spelled) stops at that parse. Trust types inside. See the `boundary-discipline` principle. |
| Schema-derived types | Reach for `Pick`/`Omit`/`Parameters`/`ReturnType`/`Awaited`/`typeof` before declaring a new interface. |
| Typed async errors | A failure is a `Result` union the caller must branch on, or a thrown domain error class. Never an empty `catch`, never a `catch` that returns a default. |
| Object args | Pass objects, not positional, so argument order is self-documenting. Skip on hot paths (per-frame render, tokenizers, parsers). |
| Real tests | Don't mock what you can run. Prefer the framework's real test primitives with leak/disposable checks, and verify UI in a running build. Mock only what you can't run locally. |
| Literal assertions | Assert a literal expected value. Never only `toBeDefined`, `toBeTruthy`, `not.toThrow`, or `toHaveBeenCalled`. See the `test-quality` skill. |
| Structured telemetry | Prefer structured logger diagnostics with enough context to debug from an id. No `console.log` in shipped code. |

## Tells

Grep a diff for these. Each one breaks a rule above.

- `as any` or `as unknown as X`. No `as` casts.
- `@ts-ignore`, or `@ts-expect-error` outside a `*.test-d.ts` file. No `as` casts.
- `: any` or `Record<string, any>` in a domain signature. `unknown` over `any`.
- `catch (e) {}`, or a `catch` that only logs and returns a default. Typed async errors.
- Two or more `useState<boolean>` or `useState(false)` that describe one fetch or one flow. React state as a union.
- `console.log` outside a script. Structured telemetry.
- An `enum` declaration. No `enum`.
- A test whose only matchers are `toBeDefined`, `toBeTruthy`, `not.toThrow`, or `toHaveBeenCalled()`. Literal assertions.

`scripts/code-smells.sh` flags the `any`, cast, `@ts-ignore`, empty `catch`, and `console.log` tells on a diff. `scripts/test-smells.sh` flags the weak matchers.

Examples: `references/patterns.md`.
