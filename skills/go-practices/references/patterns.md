# Go patterns

## Sum types

A struct of optional fields lets contradictory states compile, while a sealed interface lets only the variants this package declares exist.

```go
// Don't
type Shape struct {
	Kind   string
	Radius float64
	Width  float64
	Height float64
}

func Area(s Shape) float64 {
	if s.Kind == "circle" {
		return math.Pi * s.Radius * s.Radius
	}
	return s.Width * s.Height
}
```

```go
// Do
//sumtype:decl
type Shape interface{ isShape() }

type Circle struct{ Radius float64 }
type Rect struct{ Width, Height float64 }

func (Circle) isShape() {}
func (Rect) isShape()   {}

func Area(s Shape) float64 {
	switch v := s.(type) {
	case Circle:
		return math.Pi * v.Radius * v.Radius
	case Rect:
		return v.Width * v.Height
	default:
		panic(fmt.Sprintf("area: unhandled shape %T", s))
	}
}
```

## Exhaustive switches

Enable `exhaustive` for `const` enums and `gochecksumtype` for sealed interfaces, both with `default-signifies-exhaustive: false`, so adding a variant fails lint at every switch that misses it and the `default` arm fails loudly instead of returning something plausible.

```go
// Don't
func Label(status string) string {
	switch status {
	case "open":
		return "Open"
	case "paid":
		return "Paid"
	}
	return ""
}
```

```go
// Do
type Status int

const (
	StatusOpen Status = iota + 1
	StatusPaid
)

func Label(s Status) string {
	switch s {
	case StatusOpen:
		return "Open"
	case StatusPaid:
		return "Paid"
	default:
		panic(fmt.Sprintf("label: unhandled status %d", s))
	}
}
```

## No `any` inside

`any` turns a compile-time fact into a runtime assertion that panics when wrong, so it stays where data is truly untyped and generics carry the type everywhere else.

```go
// Don't
type Cache struct {
	items map[string]any
}

func (c *Cache) Get(key string) any {
	return c.items[key]
}

func priceOf(c *Cache, id string) float64 {
	return c.Get(id).(LineItem).Price
}
```

```go
// Do
type Cache[K comparable, V any] struct {
	items map[K]V
}

func (c *Cache[K, V]) Get(key K) (V, bool) {
	v, ok := c.items[key]
	return v, ok
}

func priceOf(c *Cache[ItemID, LineItem], id ItemID) (float64, bool) {
	item, ok := c.Get(id)
	return item.Price, ok
}
```

## Parse at the boundary

Raw input is untrusted until one function turns it into a domain type, and after that the type is the proof, so inner code never checks again.

```go
// Don't
type Config struct {
	Port    string `json:"port"`
	Timeout string `json:"timeout"`
}

func dial(cfg Config) (net.Conn, error) {
	if cfg.Port == "" {
		return nil, errors.New("port missing")
	}
	d, err := time.ParseDuration(cfg.Timeout)
	if err != nil {
		return nil, err
	}
	return net.DialTimeout("tcp", ":"+cfg.Port, d)
}
```

```go
// Do
type Config struct {
	Port    uint16
	Timeout time.Duration
}

func parseConfig(raw []byte) (Config, error) {
	var w struct {
		Port    uint16 `json:"port"`
		Timeout string `json:"timeout"`
	}
	if err := json.Unmarshal(raw, &w); err != nil {
		return Config{}, fmt.Errorf("parse config: %w", err)
	}
	if w.Port == 0 {
		return Config{}, errors.New("parse config: port is required")
	}
	timeout, err := time.ParseDuration(w.Timeout)
	if err != nil {
		return Config{}, fmt.Errorf("parse config: timeout: %w", err)
	}
	return Config{Port: w.Port, Timeout: timeout}, nil
}
```

## Typed identifiers

Two IDs that are both `string` swap silently at a call site, and distinct named types make the compiler reject the swap.

```go
// Don't
type Order struct {
	ID         string
	CustomerID string
}

func (s *Service) Refund(ctx context.Context, orderID, customerID string) error {
	return s.payments.Refund(ctx, orderID, customerID)
}
```

```go
// Do
type OrderID string

func ParseOrderID(s string) (OrderID, error) {
	if !strings.HasPrefix(s, "ord_") || len(s) == len("ord_") {
		return "", fmt.Errorf("invalid order id %q", s)
	}
	return OrderID(s), nil
}

type Order struct {
	ID         OrderID
	CustomerID CustomerID
}

func (s *Service) Refund(ctx context.Context, order OrderID, customer CustomerID) error {
	return s.payments.Refund(ctx, order, customer)
}
```

## Valid by construction

If a struct literal can hold an invalid state, every reader must guard against it, so either the zero value is correct or one constructor refuses bad input.

```go
// Don't
type Window struct {
	Start time.Time
	End   time.Time
}

func (w Window) Contains(t time.Time) bool {
	if w.End.Before(w.Start) {
		return false
	}
	return !t.Before(w.Start) && t.Before(w.End)
}
```

```go
// Do
type Window struct {
	start time.Time
	dur   time.Duration
}

func NewWindow(start time.Time, dur time.Duration) (Window, error) {
	if dur <= 0 {
		return Window{}, fmt.Errorf("window duration must be positive, got %s", dur)
	}
	return Window{start: start, dur: dur}, nil
}

func (w Window) Contains(t time.Time) bool {
	return !t.Before(w.start) && t.Before(w.start.Add(w.dur))
}
```

## Wrapped errors

A wrapped error keeps its cause inspectable, so callers branch on identity with `errors.Is` and `errors.As` instead of on message text that changes.

```go
// Don't
func (s *Store) Load(ctx context.Context, id OrderID) (Order, error) {
	o, err := s.db.Get(ctx, id)
	if err != nil {
		return Order{}, fmt.Errorf("load order: %v", err)
	}
	return o, nil
}

func status(err error) int {
	if strings.Contains(err.Error(), "no rows") {
		return http.StatusNotFound
	}
	return http.StatusInternalServerError
}
```

```go
// Do
var ErrOrderNotFound = errors.New("order not found")

func (s *Store) Load(ctx context.Context, id OrderID) (Order, error) {
	o, err := s.db.Get(ctx, id)
	if errors.Is(err, sql.ErrNoRows) {
		return Order{}, fmt.Errorf("load order %s: %w", id, ErrOrderNotFound)
	}
	if err != nil {
		return Order{}, fmt.Errorf("load order %s: %w", id, err)
	}
	return o, nil
}

func status(err error) int {
	var ve *ValidationError
	switch {
	case errors.Is(err, ErrOrderNotFound):
		return http.StatusNotFound
	case errors.As(err, &ve):
		return http.StatusBadRequest
	}
	return http.StatusInternalServerError
}
```

## Context first

A context carries one call's deadline and cancellation, so it travels as that call's first argument, and a stored context outlives the call and cancels the wrong work.

```go
// Don't
type Fetcher struct {
	ctx    context.Context
	client *http.Client
}

func (f *Fetcher) Fetch(url string) (*http.Response, error) {
	req, err := http.NewRequestWithContext(f.ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	return f.client.Do(req)
}
```

```go
// Do
type Fetcher struct {
	client *http.Client
}

func (f *Fetcher) Fetch(ctx context.Context, url string) (*http.Response, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}
	return f.client.Do(req)
}
```

## No package state

A package-level variable is hidden shared input that tests cannot isolate and goroutines race on, and `init()` runs before `main` can supply config or handle the error.

```go
// Don't
var db *sql.DB

func init() {
	var err error
	db, err = sql.Open("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
}

func CountOrders(ctx context.Context) (int, error) {
	var n int
	err := db.QueryRowContext(ctx, "SELECT count(*) FROM orders").Scan(&n)
	return n, err
}
```

```go
// Do
type OrderRepo struct {
	db *sql.DB
}

func NewOrderRepo(db *sql.DB) *OrderRepo {
	return &OrderRepo{db: db}
}

func (r *OrderRepo) Count(ctx context.Context) (int, error) {
	var n int
	if err := r.db.QueryRowContext(ctx, "SELECT count(*) FROM orders").Scan(&n); err != nil {
		return 0, fmt.Errorf("count orders: %w", err)
	}
	return n, nil
}
```

## Owned goroutines

A goroutine nobody waits for leaks, loses its error, and keeps running after the caller returns, so the function that starts it waits for it and hands it a context that stops it.

```go
// Don't
func (s *Syncer) SyncAll(ctx context.Context, ids []AccountID) {
	for _, id := range ids {
		go func() {
			if err := s.sync(context.Background(), id); err != nil {
				log.Println(err)
			}
		}()
	}
}
```

```go
// Do
func (s *Syncer) SyncAll(ctx context.Context, ids []AccountID) error {
	g, ctx := errgroup.WithContext(ctx)
	g.SetLimit(8)
	for _, id := range ids {
		g.Go(func() error {
			if err := s.sync(ctx, id); err != nil {
				return fmt.Errorf("sync %s: %w", id, err)
			}
			return nil
		})
	}
	return g.Wait()
}
```

## Pure core, thin shell

A rule that reads the clock, the database, or a logger can only be tested through fakes, while a pure function over domain values is tested with one literal input and one literal output.

```go
// Don't
func (h *Handler) Checkout(ctx context.Context, id CartID) (Cents, error) {
	cart, err := h.carts.Get(ctx, id)
	if err != nil {
		return 0, fmt.Errorf("checkout %s: %w", id, err)
	}
	total := cart.Subtotal
	if cart.Coupon.ValidAt(time.Now()) {
		total = total * 90 / 100
	}
	if total > 100_00 {
		total -= 5_00
	}
	h.log.InfoContext(ctx, "checkout total", "cart_id", id, "total", total)
	return total, nil
}
```

```go
// Do
func Total(c Cart, now time.Time) Cents {
	total := c.Subtotal
	if c.Coupon.ValidAt(now) {
		total = total * 90 / 100
	}
	if total > 100_00 {
		total -= 5_00
	}
	return total
}

func (h *Handler) Checkout(ctx context.Context, id CartID) (Cents, error) {
	cart, err := h.carts.Get(ctx, id)
	if err != nil {
		return 0, fmt.Errorf("checkout %s: %w", id, err)
	}
	return Total(cart, h.now()), nil
}
```

## Consumer interfaces

An interface declared by the package that needs it names only the methods that package calls, so any type with those methods fits and the producer stays free to grow.

```go
// Don't
package storage

type OrderStore interface {
	Get(ctx context.Context, id OrderID) (Order, error)
	Put(ctx context.Context, o Order) error
	Delete(ctx context.Context, id OrderID) error
	List(ctx context.Context, f Filter) ([]Order, error)
}

func NewOrderStore(db *sql.DB) OrderStore {
	return &pgOrderStore{db: db}
}
```

```go
// Do
package billing

type orderGetter interface {
	Get(ctx context.Context, id storage.OrderID) (storage.Order, error)
}

type Invoicer struct {
	orders orderGetter
}

func NewInvoicer(orders orderGetter) *Invoicer {
	return &Invoicer{orders: orders}
}
```

## Table tests with literal want

A test earns its place only if it fails when the code is wrong, and that takes a literal expected value compared against what the code returned.

```go
// Don't
func TestParseOrderID(t *testing.T) {
	id, err := ParseOrderID("ord_123")
	require.NoError(t, err)
	assert.NotNil(t, id)
}
```

```go
// Do
func TestParseOrderID(t *testing.T) {
	tests := []struct {
		name    string
		in      string
		want    OrderID
		wantErr bool
	}{
		{name: "prefixed id", in: "ord_123", want: "ord_123"},
		{name: "missing prefix", in: "123", wantErr: true},
		{name: "prefix only", in: "ord_", wantErr: true},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := ParseOrderID(tc.in)
			if (err != nil) != tc.wantErr {
				t.Fatalf("ParseOrderID(%q) error = %v, wantErr %v", tc.in, err, tc.wantErr)
			}
			if diff := cmp.Diff(tc.want, got); diff != "" {
				t.Errorf("ParseOrderID(%q) mismatch (-want +got):\n%s", tc.in, diff)
			}
		})
	}
}
```

## Run, don't mock

A mock that records calls passes whenever the code makes the same calls, even when the result is wrong, while a fake with behavior fails when the outcome is wrong.

```go
// Don't
func TestRename(t *testing.T) {
	store := new(MockStore)
	store.On("Get", mock.Anything, UserID("u1")).Return(User{ID: "u1", Name: "Ann"}, nil)
	store.On("Put", mock.Anything, mock.Anything).Return(nil)

	svc := NewService(store)
	require.NoError(t, svc.Rename(t.Context(), "u1", "Bo"))
	store.AssertExpectations(t)
}
```

```go
// Do
type memStore struct {
	users map[UserID]User
}

func (m *memStore) Get(_ context.Context, id UserID) (User, error) {
	u, ok := m.users[id]
	if !ok {
		return User{}, ErrUserNotFound
	}
	return u, nil
}

func (m *memStore) Put(_ context.Context, u User) error {
	m.users[u.ID] = u
	return nil
}

func TestRenameStoresNewName(t *testing.T) {
	store := &memStore{users: map[UserID]User{"u1": {ID: "u1", Name: "Ann"}}}
	svc := NewService(store)
	require.NoError(t, svc.Rename(t.Context(), "u1", "Bo"))
	assert.Equal(t, User{ID: "u1", Name: "Bo"}, store.users["u1"])
}
```

## Structured logging

Key-value records can be filtered and joined by ID in the log backend, while `fmt.Println` writes untagged text that no query finds.

```go
// Don't
func (s *Service) Ship(ctx context.Context, id OrderID) error {
	if err := s.carrier.Book(ctx, id); err != nil {
		fmt.Println("booking failed for order", id, err)
		return err
	}
	log.Printf("shipped %s", id)
	return nil
}
```

```go
// Do
func (s *Service) Ship(ctx context.Context, id OrderID) error {
	if err := s.carrier.Book(ctx, id); err != nil {
		return fmt.Errorf("ship %s: book carrier: %w", id, err)
	}
	s.log.InfoContext(ctx, "order shipped", slog.String("order_id", string(id)))
	return nil
}
```

## Generated code is derived

A generated file is output, so a hand edit vanishes on the next regeneration, and the fix belongs in the source schema or in a conversion at the boundary.

```go
// Don't
// Code generated by protoc-gen-go. DO NOT EDIT.

package orderpb

func (x *Order) IsPaid() bool {
	return x.GetStatus() == Status_STATUS_PAID
}
```

```go
// Do
package order

func fromProto(m *orderpb.Order) (Order, error) {
	id, err := ParseOrderID(m.GetId())
	if err != nil {
		return Order{}, fmt.Errorf("order from proto: %w", err)
	}
	return Order{ID: id, Paid: m.GetStatus() == orderpb.Status_STATUS_PAID}, nil
}
```
