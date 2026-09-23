# Widget plan

Two PRs. The rule: every PR proves itself live.

## How to read this

One box is one unit of work. Every box names the evidence that checks it. Check a box only when its evidence exists: a file, a log line, a screenshot, a test run, a SHA. The body is a how-to.

Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

- [ ] PR-1 first, PR-2 after PR-1.

## Add the widget model (PR-1)

**Depends on.** None.

**Files.**

- [ ] Edit `src/widget.go`.

**Build.**

- [ ] Add `Widget` in `src/widget.go`.

**You see.**

- [ ] `go test ./...` prints `ok`.

**Verify.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Unit. `widget_test.go` gains `TestWidgetRoundTrip`. Run `go test ./src/...`.

- [ ] Perf. n/a, no hot path touched.

**Ship.**

- [ ] Clean-diff checklist passes at the head SHA.

## Close the program

- [ ] Every box above is checked with its evidence.

## Appendix A. Prototype evidence

None needed.
