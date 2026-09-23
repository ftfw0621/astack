# Python patterns

One section per rule in `SKILL.md`, in the same order. Python 3.11 or newer.

## Typed public signatures

An unannotated parameter is `Any` to the checker, so nothing that flows through it is checked.

```python
# Don't
def order_total(order, discount=None):
    subtotal = sum(line["price"] * line["qty"] for line in order["lines"])
    return subtotal - (discount or 0)
```

```python
# Do
from decimal import Decimal

def order_total(order: Order, discount: Decimal = Decimal("0")) -> Decimal:
    subtotal = sum((line.price * line.quantity for line in order.lines), Decimal("0"))
    return subtotal - discount
```

## No `Any`, no bare ignores

`Any`, `cast`, and an uncoded ignore each switch the checker off for everything downstream of them.

```python
# Don't
from typing import Any, cast

import legacy_billing  # type: ignore

def owner_of(payload: Any) -> str:
    return payload["owner"]["id"]

def load_settings(raw: dict[str, Any]) -> Settings:
    return cast(Settings, raw)
```

```python
# Do
import legacy_billing  # type: ignore[import-untyped]  # vendor ships no py.typed marker

def owner_of(payload: object) -> UserId:
    match payload:
        case {"owner": {"id": str(owner_id)}}:
            return UserId(owner_id)
        case _:
            raise PayloadError(f"no owner id in {payload!r}")
```

Under pyright the suppression is `# pyright: ignore[reportMissingTypeStubs]`, with the same trailing reason.

## Sum types

A union of variants admits only the states that exist, where a bag of booleans and optionals admits every combination.

```python
# Don't
@dataclass
class Job:
    running: bool = False
    finished: bool = False
    exit_code: int | None = None
    error: str | None = None
```

```python
# Do
from dataclasses import dataclass
from datetime import datetime
from typing import Literal

Priority = Literal["low", "normal", "urgent"]

@dataclass(frozen=True)
class Running:
    started_at: datetime
    kind: Literal["running"] = "running"

@dataclass(frozen=True)
class Finished:
    exit_code: int
    kind: Literal["finished"] = "finished"

@dataclass(frozen=True)
class Crashed:
    error: str
    kind: Literal["crashed"] = "crashed"

JobState = Running | Finished | Crashed
```

`match` keys on the class. The `kind` field is what JSON and a pydantic discriminated union (`Field(discriminator="kind")`) key on.

## Exhaustive `match`

`assert_never` in the last arm turns a forgotten variant into a type error instead of a silent fallthrough.

```python
# Don't
def describe(state: JobState) -> str:
    if isinstance(state, Running):
        return f"running since {state.started_at:%H:%M}"
    elif isinstance(state, Finished):
        return f"exited {state.exit_code}"
    else:
        return "unknown"
```

```python
# Do
from typing import assert_never

def describe(state: JobState) -> str:
    match state:
        case Running(started_at=started_at):
            return f"running since {started_at:%H:%M}"
        case Finished(exit_code=code):
            return f"exited {code}"
        case Crashed(error=error):
            return f"crashed: {error}"
        case _:
            assert_never(state)

def sla_hours(priority: Priority) -> int:
    match priority:
        case "urgent":
            return 4
        case "normal":
            return 24
        case "low":
            return 72
        case _:
            assert_never(priority)
```

## `NewType` for identifiers

Two `str` parameters that mean different things swap silently, and two `NewType`s do not.

```python
# Don't
def grant(user_id: str, org_id: str, role: str) -> None: ...

grant(org.id, user.id, "admin")
```

```python
# Do
from typing import NewType

UserId = NewType("UserId", str)
OrgId = NewType("OrgId", str)

def parse_user_id(raw: str) -> UserId:
    if not raw.startswith("usr_"):
        raise ValueError(f"not a user id: {raw!r}")
    return UserId(raw)

def grant(user_id: UserId, org_id: OrgId, role: Role) -> None: ...
```

## Parse at the boundary

One parse where data enters means every function inside takes a typed value and checks nothing.

```python
# Don't
def retry_delay(config: dict) -> float:
    retries = config.get("retries", 3)
    if not isinstance(retries, int) or retries < 0:
        raise ValueError("retries must be a non-negative int")
    return 2.0 ** retries
```

```python
# Do, without a schema library
@dataclass(frozen=True)
class Config:
    retries: int
    region: str

def parse_config(raw: dict[str, object]) -> Config:
    retries = raw.get("retries", 3)
    region = raw.get("region")
    if not isinstance(retries, int) or retries < 0:
        raise ConfigError(f"retries must be a non-negative int, got {retries!r}")
    if not isinstance(region, str):
        raise ConfigError(f"region must be a string, got {region!r}")
    return Config(retries=retries, region=region)

def retry_delay(config: Config) -> float:
    return 2.0 ** config.retries
```

```python
# Do, with pydantic
from pydantic import BaseModel, ConfigDict, Field

class ConfigIn(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)
    retries: int = Field(default=3, ge=0)
    region: str

def load_config(path: Path) -> Config:
    parsed = ConfigIn.model_validate_json(path.read_bytes())
    return Config(retries=parsed.retries, region=parsed.region)
```

The pydantic model stays in the module that reads the file. Everything past `load_config` sees the plain `Config`.

## Frozen domain values

A frozen value cannot change under a caller that holds it, and a shape with no contradictory fields needs no comment saying which combinations are valid.

```python
# Don't
@dataclass
class Task:
    title: str
    done: bool = False
    done_at: datetime | None = None

@dataclass
class Email:
    subject: str
    recipients: list[EmailAddress]
```

```python
# Do
from dataclasses import dataclass, replace
from datetime import datetime

@dataclass(frozen=True)
class Task:
    title: str
    done_at: datetime | None = None

    @property
    def done(self) -> bool:
        return self.done_at is not None

@dataclass(frozen=True)
class Email:
    subject: str
    first_recipient: EmailAddress
    other_recipients: tuple[EmailAddress, ...] = ()

def complete(task: Task, at: datetime) -> Task:
    return replace(task, done_at=at)
```

## Exceptions, not sentinels

A sentinel return is a failure the caller can forget to check, and a swallowed exception is a failure nobody sees.

```python
# Don't
def withdraw(account: Account, amount: Decimal) -> Account | None:
    if amount > account.balance:
        return None
    return replace(account, balance=account.balance - amount)

def charge(card: Card, amount: Decimal) -> bool:
    try:
        gateway.charge(card.token, amount)
    except Exception:
        pass
    return True
```

```python
# Do
class InsufficientFunds(Exception):
    def __init__(self, account_id: AccountId, shortfall: Decimal) -> None:
        super().__init__(f"{account_id} is short by {shortfall}")
        self.shortfall = shortfall

def withdraw(account: Account, amount: Decimal) -> Account:
    if amount > account.balance:
        raise InsufficientFunds(account.id, amount - account.balance)
    return replace(account, balance=account.balance - amount)

def charge(card: Card, amount: Decimal) -> ChargeId:
    try:
        return gateway.charge(card.token, amount)
    except GatewayTimeout as exc:
        raise ChargeFailed(card.id, "gateway timeout") from exc

def pay(account: Account, amount: Decimal) -> Receipt:
    try:
        return Receipt(account=withdraw(account, amount))
    except InsufficientFunds as exc:
        return Receipt(account=account, declined_for=exc.shortfall)
```

## Pure core, I/O shell

A rule that needs a database, a request, or the clock to run can only be tested with them.

```python
# Don't
def renew(conn: sqlite3.Connection, sub_id: str) -> None:
    plan, ends_at = conn.execute(
        "SELECT plan, ends_at FROM subs WHERE id = ?", (sub_id,)
    ).fetchone()
    ends = datetime.fromisoformat(ends_at)
    if plan == "annual" and ends - datetime.now(UTC) < timedelta(days=30):
        new_end = ends + timedelta(days=365)
        conn.execute("UPDATE subs SET ends_at = ? WHERE id = ?", (new_end.isoformat(), sub_id))
```

```python
# Do
def renewed(sub: Subscription, now: datetime) -> Subscription | None:
    if sub.plan != "annual" or sub.ends_at - now >= timedelta(days=30):
        return None
    return replace(sub, ends_at=sub.ends_at + timedelta(days=365))

def renew(repo: SubscriptionRepo, sub_id: SubscriptionId) -> None:
    sub = repo.load(sub_id)
    next_sub = renewed(sub, datetime.now(UTC))
    if next_sub is not None:
        repo.save(next_sub)
```

## No mutable defaults or globals

A mutable default is built once and shared by every call, and module state couples every caller and every test to each other.

```python
# Don't
_seen: set[str] = set()

def tag(event: Event, tags: list[str] = []) -> list[str]:
    _seen.add(event.id)
    tags.append(event.kind)
    return tags
```

```python
# Do
from dataclasses import dataclass, field
from typing import Final

ALLOWED_REGIONS: Final = frozenset({"us-east-1", "eu-west-1"})

def tag(event: Event, tags: tuple[str, ...] = ()) -> tuple[str, ...]:
    return (*tags, event.kind)

@dataclass
class Deduplicator:
    seen: set[EventId] = field(default_factory=set)

    def first_time(self, event_id: EventId) -> bool:
        if event_id in self.seen:
            return False
        self.seen.add(event_id)
        return True
```

## `Protocol` at the consumer

A `Protocol` declared by the code that uses it names exactly what that code needs, so any implementation, a test fake included, fits without inheriting anything.

```python
# Don't
class BaseStorage(ABC):
    @abstractmethod
    def read(self, key: str) -> bytes: ...

    @abstractmethod
    def write(self, key: str, data: bytes) -> None: ...

def load_manifest(storage: S3Storage, key: str) -> Manifest:
    return parse_manifest(storage.read(key))
```

```python
# Do
from pathlib import Path
from typing import Protocol

class BlobReader(Protocol):
    def read(self, key: str) -> bytes: ...

def load_manifest(store: BlobReader, key: str) -> Manifest:
    return parse_manifest(store.read(key))

class DirectoryBlobs:
    def __init__(self, root: Path) -> None:
        self.root = root

    def read(self, key: str) -> bytes:
        return (self.root / key).read_bytes()
```

## Precise stdlib types

`str` paths, naive datetimes, and floats accept wrong values silently: a missing separator, local time read as UTC, `1.10 + 2.20` equal to `3.3000000000000003`.

```python
# Don't
import os
from datetime import datetime

def invoice_path(root: str, customer_id: str) -> str:
    return os.path.join(root, customer_id, "invoice.json")

issued_at = datetime.now()
total = 1.10 + 2.20
```

```python
# Do
from datetime import UTC, datetime
from decimal import ROUND_HALF_EVEN, Decimal
from pathlib import Path

def invoice_path(root: Path, customer_id: CustomerId) -> Path:
    return root / customer_id / "invoice.json"

issued_at = datetime.now(UTC)
total = Decimal("1.10") + Decimal("2.20")
tax = (total * Decimal("0.0825")).quantize(Decimal("0.01"), rounding=ROUND_HALF_EVEN)
```

## Behavior tests

A test observes behavior only when it calls the code with a concrete input and compares the result to a literal written in the test.

```python
# Don't
def test_slugify() -> None:
    result = slugify("Hello, World!")
    assert result is not None
    assert isinstance(result, str)

def test_parse_amount_fails() -> None:
    with pytest.raises(Exception):
        parse_amount("abc")
```

```python
# Do
import pytest

@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Hello, World!", "hello-world"),
        ("  padded  ", "padded"),
        ("already-a-slug", "already-a-slug"),
    ],
)
def test_slugify_lowercases_and_hyphenates(raw: str, expected: str) -> None:
    assert slugify(raw) == expected

def test_parse_amount_rejects_non_numeric_text() -> None:
    with pytest.raises(InvalidAmount, match="not a number: 'abc'"):
        parse_amount("abc")
```

## Fakes over mocks

A mock records the calls the code made, so it passes when the result is wrong, while a real dependency or a fake with behavior fails.

```python
# Don't
from unittest.mock import Mock

def test_load_manifest() -> None:
    store = Mock()
    store.read.return_value = b'{"version": 2}'
    load_manifest(store, "manifest.json")
    assert store.read.called
```

```python
# Do
from pathlib import Path

class InMemoryBlobs:
    def __init__(self, blobs: dict[str, bytes]) -> None:
        self.blobs = blobs

    def read(self, key: str) -> bytes:
        return self.blobs[key]

def test_load_manifest_reads_version_from_disk(tmp_path: Path) -> None:
    (tmp_path / "manifest.json").write_bytes(b'{"version": 2}')
    assert load_manifest(DirectoryBlobs(tmp_path), "manifest.json") == Manifest(version=2)

def test_load_manifest_reads_version_from_fake() -> None:
    store = InMemoryBlobs({"manifest.json": b'{"version": 2}'})
    assert load_manifest(store, "manifest.json") == Manifest(version=2)
```

## Structured logging

A constant message with context in `extra` can be searched and aggregated by field, where a `print` or an f-string message cannot.

```python
# Don't
print(f"charged {card_id} {amount}")
logger.info(f"charge failed for {card_id}: {exc}")
```

```python
# Do
import logging

logger = logging.getLogger(__name__)

logger.info("card charged", extra={"card_id": card_id, "amount": str(amount)})

try:
    charge(card, amount)
except ChargeFailed:
    logger.exception("charge failed", extra={"card_id": card.id})
    raise
```

Keys in `extra` must not reuse a `LogRecord` attribute such as `name`, `msg`, or `message`, or logging raises `KeyError`.

## Generated code is derived

A hand edit to generated code is erased by the next regeneration, and a hand-written mirror of a generated type drifts from it.

```python
# Don't
@dataclass
class UserMessage:
    user_id: str
    email: str
    created_at_seconds: int

def user_from_bytes(data: bytes) -> UserMessage:
    msg = user_pb2.User.FromString(data)
    return UserMessage(msg.user_id, msg.email, msg.created_at.seconds)
```

```python
# Do
from datetime import UTC

def user_from_bytes(data: bytes) -> User:
    msg = user_pb2.User.FromString(data)
    return User(
        id=UserId(msg.user_id),
        email=msg.email,
        created_at=msg.created_at.ToDatetime(tzinfo=UTC),
    )
```

To change the shape, edit the `.proto` and rerun the project's generator. A migration that has run in any environment is history: write a new migration instead of editing it.
