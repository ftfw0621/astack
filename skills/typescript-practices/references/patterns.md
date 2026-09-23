# TypeScript patterns

Examples for each rule in `SKILL.md`, in table order. The principles behind them are language-agnostic. See the `type-system-discipline` and `boundary-discipline` principles.

## Discriminated unions

A literal discriminant lets only valid states exist, where a boolean plus optional fields lets contradictory ones compile.

```ts
// Don't
type DiffState = { loading: boolean; diff?: GitDiff; error?: string };

// Do
type DiffState =
  | { kind: "loading" }
  | { kind: "ready"; diff: GitDiff }
  | { kind: "error"; error: string };
```

A boolean with a companion field is the same bug in miniature. `{ completed: true }` with no `completedAt` compiles in the first shape and cannot be written in the second.

```ts
// Don't
type Task = { title: string; completed: boolean; completedAt?: Date };

// Do
type Task = { title: string; status: { kind: "open" } | { kind: "done"; at: Date } };
```

Pick one discriminant name (`kind`, `type`, `tag`) and stick to it.

## React state as a union

Separate `loading`, `error`, and `data` hooks can disagree, while one union state gives each render branch exactly the fields it needs.

```tsx
// Don't
function Orders() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [orders, setOrders] = useState<Order[]>([]);
  useEffect(() => {
    fetchOrders()
      .then(setOrders)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);
  if (loading) return <Spinner />;
  if (error) return <ErrorBanner error={error} />;
  return <OrderList orders={orders} />;
}
```

```tsx
// Do
type State<T> =
  | { kind: "loading" }
  | { kind: "error"; error: Error }
  | { kind: "ready"; data: T };

function Orders() {
  const [state, setState] = useState<State<Order[]>>({ kind: "loading" });
  useEffect(() => {
    fetchOrders().then(
      (data) => setState({ kind: "ready", data }),
      (reason: unknown) =>
        setState({ kind: "error", error: reason instanceof Error ? reason : new Error(String(reason)) }),
    );
  }, []);
  switch (state.kind) {
    case "loading":
      return <Spinner />;
    case "error":
      return <ErrorBanner error={state.error} />;
    case "ready":
      return <OrderList orders={state.data} />;
  }
}
```

The Don't admits combinations no fetch produces, such as `loading` beside an `error`, and the order of the `if` checks silently decides which one wins. The same shape fits a form (`editing`, `submitting`, `failed`, `saved`) or a wizard step. Use `useReducer` when transitions depend on the current state.

## Branded types

Two ids that are both `string` can be swapped silently, and a brand makes the swap a compile error while one parse function stays the only place the raw string is checked.

```ts
// Don't
function focusAgent(id: string): void {
  agents.get(id)?.focus();
}

focusAgent(session.id);
```

```ts
// Do
type AgentId = string & { readonly __brand: "AgentId" };

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function parseAgentId(input: string): AgentId {
  if (!UUID.test(input)) throw new Error(`invalid agent id: ${input}`);
  return input as AgentId;
}

function focusAgent(id: AgentId): void {
  agents.get(id)?.focus();
}
```

The Don't compiles with a session id. The `as` inside `parseAgentId` is the one earned cast: it runs after the check. Match the `readonly __brand: "X"` shape. Don't invent a new convention.

## Constructive modeling

A type built only from legal parts cannot hold the illegal value, so no caller repeats the runtime check.

```ts
type NonEmpty<T> = [T, ...T[]];

// Don't
function earliest(dates: Date[]): Date {
  if (dates.length === 0) throw new Error("no dates");
  return dates.reduce((a, b) => (b < a ? b : a));
}

// Do
function earliest(dates: NonEmpty<Date>): Date {
  return dates.reduce((a, b) => (b < a ? b : a));
}
```

Where a plain `T[]` arrives, narrow once with a guard. The fact then travels in the type.

```ts
// Do
const isNonEmpty = <T>(arr: T[]): arr is NonEmpty<T> => arr.length > 0;
```

An even-length list is a list of pairs, and a time range is a start plus a duration.

```ts
// Don't
type TimeRange = { start: Date; end: Date };

// Do
type Pairs<T> = [T, T][];
type TimeRange = { start: Date; durationMs: number };
```

The Don't range needs a comment saying `start <= end`, and nothing enforces it. Keep `durationMs` a plain number. Brand it (per Branded types) only if a raw number could be passed where a duration is expected, not by reflex. Pick the representation that makes the bad state unconstructable, then expose the reading you need on top (`pairs.flat()`, a `rangeEnd()` helper).

## Simplest total type

Strengthen a type only where the loose one forces a lie, because precision that no operation needs only adds conversions.

```ts
// Do
const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0);
```

`sum([])` is `0`, so `number[]` stays. The tells for a type that is too weak are `!`, `arr[0] as T`, and a "should never happen" throw.

```ts
// Don't
function newestSession(sessions: Session[]): Session {
  return sessions.at(0)!;
}

// Do
function newestSession(sessions: NonEmpty<Session>): Session {
  return sessions[0];
}
```

Weakening the result to `Session | undefined` is the other total signature.

## No `enum`

An `enum` emits runtime code that `erasableSyntaxOnly` and Node's type stripping reject, and a numeric `enum` accepts any `number`, while an `as const` object gives the same names with plain literal types.

```ts
// Don't
enum Status {
  Active = "active",
  Suspended = "suspended",
}

// Do
const Status = {
  Active: "active",
  Suspended: "suspended",
} as const;

type Status = (typeof Status)[keyof typeof Status];
```

`Object.values(Status)` is the runtime list. When nothing iterates or looks up the values at runtime, a literal union `type Status = "active" | "suspended"` is enough.

## `readonly` unless mutated

`readonly` turns an accidental mutation of the caller's data into a compile error and tells the reader the function only reads.

```ts
// Don't
function ranked(scores: number[]): number[] {
  return scores.sort((a, b) => b - a);
}

// Do
function ranked(scores: readonly number[]): number[] {
  return [...scores].sort((a, b) => b - a);
}
```

The Don't sorts the caller's array in place. With `readonly number[]`, `scores.sort` does not compile.

```ts
// Don't
type RetryPolicy = { attempts: number; backoffMs: number[] };

// Do
type RetryPolicy = { readonly attempts: number; readonly backoffMs: readonly number[] };
```

`Readonly<RetryPolicy>` would leave `backoffMs` mutable, because `Readonly<T>` is shallow.

## `unknown` over `any`

`any` switches the checker off for every use of the value, while `unknown` forces a narrow before any access.

```ts
// Don't
function messageText(event: any): string {
  return event.text;
}

// Do
function messageText(event: unknown): string {
  if (typeof event === "object" && event !== null && "text" in event && typeof event.text === "string") {
    return event.text;
  }
  throw new Error("expected a message event with a text field");
}
```

External sources include RPC payloads, `JSON.parse`, `postMessage`, IPC, file contents, environment variables, and database results. When the narrowing grows past one field, use a schema (next rule).

## Schemas before guards

One schema that both validates and produces the type cannot drift, while a hand-written interface plus a guard are two copies that can.

```ts
// Don't
interface User {
  id: string;
  role: "admin" | "member";
}

function isUser(x: unknown): x is User {
  return typeof x === "object" && x !== null && "id" in x && "role" in x;
}
```

```ts
// Do
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().min(1),
  role: z.enum(["admin", "member"]),
});

type User = z.infer<typeof UserSchema>;

function parseUser(input: unknown): User {
  return UserSchema.parse(input);
}
```

Use `safeParse` when failure is an expected branch. Use the equivalent inference helper when the repository uses another schema library. Do not add a new schema dependency for one guard. This rule prefers the schema system the codebase already trusts.

## No `as` casts

`as` asserts a fact the compiler could not check, so a wrong assertion surfaces later as a crash far from its cause.

```ts
// Don't
const user = (await res.json()) as User;

// Do
const user = UserSchema.parse(await res.json());
```

When refactoring an `as` out of existing code, identify why TypeScript can't infer:

- Missing discriminant: add one, switch to a discriminated union.
- Overly wide source type (for example `Record<string, unknown>`): narrow it.
- Untyped boundary: add a parse function or schema.
- Genuinely inexpressible: use a branded type or `satisfies`.

The one earned cast is inside a parse or brand function, after the check it relies on.

## Narrowing hierarchy

Each step down the list trusts the programmer more and the compiler less, so use the highest one that fits.

1. **Discriminated union switch or if.** The compiler narrows automatically.
2. **`in` operator.** `"key" in obj` narrows to variants containing that key.
3. **`typeof` or `instanceof`.** For primitives and class instances.
4. **User-defined type guard.** When the above aren't enough.
5. **`as` cast.** Only after validation.

```ts
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "rect"; width: number; height: number };
type Rect = Extract<Shape, { kind: "rect" }>;

// Don't
function area(s: Shape): number {
  if ((s as Rect).width !== undefined) return (s as Rect).width * (s as Rect).height;
  return Math.PI * (s as Exclude<Shape, Rect>).radius ** 2;
}

// Do
function area(s: Shape): number {
  if (s.kind === "circle") return Math.PI * s.radius ** 2;
  return s.width * s.height;
}
```

## Type guards

A guard's `x is T` return is trusted without proof, so a guard that checks less than it claims hides the bug behind a name that says the value is safe.

```ts
// Don't
function isOrder(x: unknown): x is Order {
  return typeof x === "object" && x !== null && "id" in x;
}

// Do
function isCircle(s: Shape): s is Extract<Shape, { kind: "circle" }> {
  return s.kind === "circle";
}
```

The Don't passes `{ id: 1 }` as an `Order`. Name guards `isX` or `hasX`. Prefer discriminant narrowing when possible, and a schema when the input is external.

## Exhaustiveness

A `never`-typed local in the default arm turns a new, unhandled variant into a compile error instead of a silent fallback.

```ts
// Don't
function label(s: Shape): string {
  switch (s.kind) {
    case "circle":
      return "Circle";
    case "rect":
      return "Rectangle";
    default:
      return "Shape";
  }
}
```

```ts
// Do
function label(s: Shape): string {
  switch (s.kind) {
    case "circle":
      return "Circle";
    case "rect":
      return "Rectangle";
    default: {
      const _exhaustive: never = s;
      return _exhaustive;
    }
  }
}
```

In a statement switch, discard the local instead of returning it.

```ts
// Do
function draw(s: Shape): void {
  switch (s.kind) {
    case "circle":
      drawCircle(s);
      break;
    case "rect":
      drawRect(s);
      break;
    default: {
      const _exhaustive: never = s;
      void _exhaustive;
    }
  }
}
```

## `satisfies` over `as`

`satisfies` checks the value against the type and keeps its literal types, where `as` skips the check and widens.

```ts
type Config = { theme: "dark" | "light"; cols: number };

// Don't
const config = { theme: "dark", cols: 3 } as Config;

// Do
const config = { theme: "dark", cols: 3 } satisfies Config;
```

With `satisfies`, `config.theme` has type `"dark"`, and deleting `cols` is a compile error. With `as`, `theme` widens to the union and `{ theme: "dark" } as Config` still compiles.

## Boundary validation

Parsing once where data enters gives every function inside a typed value it can trust, so re-checks deep in the call chain are noise that hides which check matters.

```ts
// Don't
function applyDiscount(order: Record<string, unknown>): number {
  if (typeof order.total !== "number") throw new Error("bad total");
  return order.total * 0.9;
}
```

```ts
// Do
import { z } from "zod";

const OrderSchema = z.object({ id: z.string().min(1), total: z.number().nonnegative() });
type Order = z.infer<typeof OrderSchema>;

export async function handleCheckout(req: Request): Promise<Response> {
  const order = OrderSchema.parse(await req.json());
  return Response.json({ total: applyDiscount(order) });
}

function applyDiscount(order: Order): number {
  return order.total * 0.9;
}
```

- **Wire formats** (proto, JSON-RPC): parse with `ignoreUnknownFields` so forward-compatible changes don't break old clients.
- **Persisted JSON:** a versioned blob, parsed inside a try/catch that maps failure to a typed result.
- **Don't re-validate** deep in call chains.

See the `boundary-discipline` principle.

## Schema-derived types

A hand-copied shape drifts when the schema changes, while a derived one breaks the build at every stale use.

```ts
// Don't
type CheckSummary = {
  totalCount: number;
  checks: { name: string; status: string }[];
};

// Do
import type { ChecksMessage } from "./gen/checks_pb";

type CheckSummary = Pick<ChecksMessage, "totalCount" | "checks">;
```

The same applies to a function's own output: prefer `Awaited<ReturnType<typeof fetchProfile>>` over a parallel `Profile` interface. Reach for `Pick`, `Omit`, `Parameters`, `ReturnType`, `Awaited`, and `typeof` before writing a new interface.

## Typed async errors

An empty `catch` turns a failure into a silent wrong value, while a `Result` union or a named error class makes the caller handle the failure it can recover from.

```ts
// Don't
async function loadProfile(id: UserId): Promise<Profile | undefined> {
  try {
    const res = await fetch(`/api/profiles/${id}`);
    return ProfileSchema.parse(await res.json());
  } catch (e) {}
}
```

```ts
// Do
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
type ProfileError = { kind: "not-found" } | { kind: "unavailable"; status: number };

async function loadProfile(id: UserId): Promise<Result<Profile, ProfileError>> {
  const res = await fetch(`/api/profiles/${id}`);
  if (res.status === 404) return { ok: false, error: { kind: "not-found" } };
  if (!res.ok) return { ok: false, error: { kind: "unavailable", status: res.status } };
  return { ok: true, value: ProfileSchema.parse(await res.json()) };
}
```

Or throw a domain error class, and catch only that class where it can be handled.

```ts
// Do
class ProfileNotFoundError extends Error {
  readonly userId: UserId;
  constructor(userId: UserId) {
    super(`profile ${userId} not found`);
    this.userId = userId;
  }
}

async function profilePage(id: UserId): Promise<string> {
  try {
    return renderProfile(await getProfile(id));
  } catch (error) {
    if (error instanceof ProfileNotFoundError) return renderNotFound(error.userId);
    throw error;
  }
}
```

Under `strict`, a `catch` variable is `unknown`. Narrow it with `instanceof` and rethrow what you did not handle.

## Object args

Named fields make argument order irrelevant, so two arguments of the same type cannot be swapped silently.

```ts
// Don't
declare function transfer(from: AccountId, to: AccountId, amountCents: number): Promise<void>;

await transfer(checking, savings, 500);

// Do
type TransferArgs = { from: AccountId; to: AccountId; amountCents: number };
declare function transfer(args: TransferArgs): Promise<void>;

await transfer({ from: savings, to: checking, amountCents: 500 });
```

Skip on hot paths: per-frame render, tokenizers, parsers, anything in a tight loop where the allocation cost matters.

## Real tests

A mock encodes a belief about the dependency, so only a test against the real thing fails when that belief is wrong.

```ts
// Don't
vi.mock("node:fs/promises");

test("saves settings", async () => {
  await saveSettings("/config", { theme: "dark" });
  expect(writeFile).toHaveBeenCalled();
});
```

```ts
// Do
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { expect, onTestFinished, test } from "vitest";

test("saved settings load back unchanged", async () => {
  const dir = await mkdtemp(join(tmpdir(), "settings-"));
  onTestFinished(() => rm(dir, { recursive: true, force: true }));
  await saveSettings(dir, { theme: "dark" });
  expect(await loadSettings(dir)).toEqual({ theme: "dark" });
});
```

For UI, render the component with its real store and query by role, then check the change in a running build. Mock only what cannot run locally, such as a paid third-party API.

## Literal assertions

An assertion that passes for a wrong value cannot fail for a defect, so compare against the literal output.

```ts
// Don't
test("slugify", () => {
  const slug = slugify("Hello, World!");
  expect(slug).toBeDefined();
  expect(slug).toBeTruthy();
});

test("closing a case notifies", async () => {
  await closeCase("case-42");
  expect(notify).toHaveBeenCalled();
});
```

```ts
// Do
test("slugify lowercases and drops punctuation", () => {
  expect(slugify("Hello, World!")).toBe("hello-world");
});

test("closing a case notifies its owner with the case id", async () => {
  await closeCase("case-42");
  expect(notify).toHaveBeenCalledWith({ to: "owner@example.com", caseId: "case-42" });
});
```

For an absence, assert the presence on the other input in the same test. A compile-time check belongs in a `*.test-d.ts` file. See the `test-quality` skill, and run `scripts/test-smells.sh` on every test you touch.

## Structured telemetry

A structured event carries the ids needed to find the failing request later, while a `console.log` string ships noise nobody can query.

```ts
// Don't
console.log("sync failed", err);

// Do
logger.error({ event: "sync.failed", syncId, attempt, err }, "sync failed");
```

Use the repository's logger. The call above is the pino shape, a context object then a message. Include the id a reader would search for, not the whole payload.
