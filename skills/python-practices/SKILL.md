---
name: python-practices
description: Python best practices grounding the type-system, boundary, and test principles in Python syntax. Use when reading or editing any .py file.
paths: ["**/*.py"]
---

# Python practices

Apply the `type-system-discipline` and `boundary-discipline` principles first.

| Rule | Summary |
|------|---------|
| Typed public signatures | Annotate every parameter and return of every public function and method, `-> None` included. The project's checker (`mypy --strict` or `pyright` strict) stays clean on every file you touch. Write `list[str]`, not `typing.List`. |
| No `Any`, no bare ignores | Raw input is typed `object` and lives only in the parse function. `Any` in a domain signature and `typing.cast` are lies to the checker. Every suppression names its code and a reason: `# type: ignore[import-untyped]  # <why>`. |
| Sum types | A closed set of tags is a `Literal[...]` alias. Variants that carry data are frozen dataclasses, each with a `kind: Literal[...]` field, joined in one union alias. Never a bag of booleans and optionals. |
| Exhaustive `match` | Branch on a sum type with `match` and class or literal patterns. The last arm is `case _: assert_never(x)`, so the checker fails when someone adds a variant. No `isinstance` chain ending in a silent `else`. |
| `NewType` for identifiers | `UserId = NewType("UserId", str)` for any identifier that could be swapped with another. Construct it only in the function that validated it. Trust it downstream. |
| Parse at the boundary | JSON, env vars, CLI args, DB rows, and HTTP bodies are parsed once, where they enter, into a typed model. Use the project's schema library (pydantic if present), else a dataclass plus `parse_x(raw) -> X`. Inside, never re-check what the parse checked. |
| Frozen domain values | `@dataclass(frozen=True)` for domain values, changed with `dataclasses.replace`. Collection fields are `tuple` or `frozenset`. No `Optional` fields whose combinations mean nothing. Build the shape so the illegal value cannot exist: a `first` plus a `rest` tuple for a non-empty list. |
| Exceptions, not sentinels | Failure raises. Never return `-1`, `""`, `False`, or `None` to mean an error; `None` means only a real absence. One exception class per failure a caller branches on. No bare `except:`, no `except Exception: pass`. Wrap with `raise ... from exc`. |
| Pure core, I/O shell | Business rules are pure functions over domain values. No request, session, ORM row, client, file, or clock inside them; pass `now` in. The shell loads, calls the pure function, and writes. |
| No mutable defaults or globals | No `[]`, `{}`, or `set()` as a default argument; use `()`, `None`, or `field(default_factory=...)`. Module-level values are immutable constants (`Final`, `tuple`, `frozenset`). State lives in an object the caller creates and passes. |
| `Protocol` at the consumer | The module that needs a capability declares a `Protocol` with only the methods it calls. Implementations do not inherit from it. No abstract base class hierarchy just to share an interface. |
| Precise stdlib types | `pathlib.Path` for paths, timezone-aware `datetime` (`datetime.now(UTC)`), `timedelta` for durations, `Decimal` built from strings for money. Never a float for currency, never a naive datetime. |
| Behavior tests | `pytest`. Parametrize over literal inputs and literal expected values. `pytest.raises(Error, match="...")`. A test whose only assertions are `assert x is not None`, `isinstance`, or `mock.called` observes nothing. Apply the `test-quality` skill. |
| Fakes over mocks | Do not mock what you can run: `tmp_path`, a test database, a local server. For what you cannot run, write a fake class that satisfies the `Protocol` and behaves. Assert the resulting state or the payload sent, never only that a call happened. |
| Structured logging | `logger = logging.getLogger(__name__)` per module. Constant message, context in `extra={...}`. `logger.exception` inside `except` keeps the traceback. No `print` in shipped code, no f-string messages. |
| Generated code is derived | Protobuf `*_pb2.py` and `*_pb2.pyi` change only by editing the `.proto` and regenerating. A migration that has run anywhere is history: add a new one. Convert generated types to domain types at the boundary. No hand-written mirror. |

## Tells

Grep the diff for these. Each one is a rule above, broken.

- `Any` in a signature outside a parse function.
- `# type: ignore` with no `[code]`, or a `cast(` call.
- `except:` or `except Exception:` followed by `pass`.
- An `if`/`elif` chain of `isinstance(` or `.kind ==` checks where a `match` with `assert_never` belongs.
- String-key access (`raw["id"]`, `raw.get("id")`) past the parse function, where a dataclass exists.
- `=[]`, `={}`, or `=set()` in a `def` line, or a `global` statement.
- `datetime.now()` or `datetime.utcnow()` with no tz, or a `float` money field.
- `time.sleep` in a test.

Examples: `references/patterns.md`.
