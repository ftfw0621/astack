#!/usr/bin/env bash
# Prove the scripts flag what they claim to flag. Usage: tests/run.sh
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 1
fail=0
expect() {
	# expect <output-file> <pattern> <label>
	if grep -q -- "$2" "$1"; then printf 'ok    %s\n' "$3"; else printf 'FAIL  %s (no line matching %s)\n' "$3" "$2"; fail=1; fi
}
expect_absent() {
	if grep -q -- "$2" "$1"; then printf 'FAIL  %s (unexpected line matching %s)\n' "$3" "$2"; fail=1; else printf 'ok    %s\n' "$3"; fi
}

out=$(mktemp)
scripts/test-smells.sh tests/fixtures/tests > "$out" 2>/dev/null
[ $? -eq 1 ] && printf 'ok    test-smells exits 1 on fixtures\n' || { printf 'FAIL  test-smells exit code\n'; fail=1; }
expect "$out" 'weak_test.go:10: no assertion in TestNoAssertion' 'go: no assertion'
expect "$out" 'weak_test.go:14: only weak assertions in TestWeakOnly' 'go: weak only'
expect_absent "$out" 'TestStrong' 'go: strong test not flagged'
expect "$out" 'weak_test.go:2[0-9]: asserts a mock was called' 'go: mock only'
expect "$out" 'test_weak.py:1: no assertion in test_no_assertion' 'py: no assertion'
expect "$out" 'test_weak.py:5: only weak assertions in test_weak_only' 'py: weak only'
expect_absent "$out" 'test_strong' 'py: strong test not flagged'
expect "$out" 'test_weak.py:1[0-9]: only weak assertions in test_mock_only' 'py: mock only'
expect_absent "$out" 'test_multiline_strong' 'py: multi-line strong assert not flagged'
expect "$out" 'test_weak.py:2[0-9]: only weak assertions in test_multiline_weak' 'py: multi-line weak assert'
expect "$out" 'weak.test.ts:2: no assertion in "no assertion"' 'ts: no assertion'
expect "$out" 'weak.test.ts:6: only weak assertions in "weak only"' 'ts: weak only'
expect_absent "$out" '"strong"' 'ts: strong test not flagged'
expect "$out" 'weak.test.ts:16: only weak assertions in "mock only"' 'ts: mock only'

scripts/code-smells.sh tests/fixtures/code/smelly.ts tests/fixtures/code/smelly.py tests/fixtures/code/smelly.go > "$out" 2>/dev/null
[ $? -eq 1 ] && printf 'ok    code-smells exits 1 on fixtures\n' || { printf 'FAIL  code-smells exit code\n'; fail=1; }
expect "$out" 'smelly.ts:2: cast' 'ts: cast'
expect "$out" 'smelly.ts:3: type-escape' 'ts: as any'
expect "$out" 'smelly.ts:4: type-escape' 'ts: ts-ignore'
expect "$out" 'smelly.ts:6: todo-left-behind' 'ts: todo'
expect "$out" 'smelly.ts:7: commented-out-code' 'ts: commented-out code'
expect "$out" 'smelly.ts:8: narrating-comment' 'ts: narrating comment'
expect "$out" 'smelly.ts:11: swallowed-error' 'ts: empty catch'
expect "$out" 'smelly.ts:12: debug-print' 'ts: console.log'
expect "$out" 'smelly.ts:18: deep-nesting' 'ts: deep nesting'
expect "$out" 'smelly.py:5: type-escape' 'py: cast and type: ignore'
expect "$out" 'smelly.py:9: swallowed-error' 'py: except pass'
expect "$out" 'smelly.py:10: commented-out-code' 'py: commented-out code'
expect "$out" 'smelly.go:3: type-escape' 'go: interface{}'
expect "$out" 'smelly.go:4: cast' 'go: type assertion'
expect "$out" 'smelly.go:5: swallowed-error' 'go: _ = err'
expect "$out" 'smelly.go:6: type-escape' 'go: nolint'

# diff mode: a fixture repo where one function grows past 80 lines and a file crosses 1000 lines
tmp=$(mktemp -d)
( cd "$tmp" && git init -q -b main && git config user.email t@example.com && git config user.name t
  printf 'package big\n\nfunc Small() int {\n\treturn 1\n}\n' > big.go
  for i in $(seq 1 998); do printf '// line %d\n' "$i"; done > long.go
  git add . && git commit -qm base
  { printf 'package big\n\nfunc Small() int {\n'; for i in $(seq 1 85); do printf '\tx%d := %d\n' "$i" "$i"; done; printf '\treturn 1\n}\n'; } > big.go
  for i in $(seq 1 1005); do printf '// line %d\n' "$i"; done > long.go
  "$root/scripts/code-smells.sh" --base main > out.txt 2>/dev/null; echo "exit=$?" >> out.txt )
expect "$tmp/out.txt" 'big.go:3: long-function' 'diff: long function touched by change'
expect "$tmp/out.txt" 'long.go:1: file-over-1000-lines: 998 -> 1005' 'diff: file crosses 1000 lines'
expect "$tmp/out.txt" 'exit=1' 'diff: exit 1'
rm -rf "$tmp" "$out"
[ $fail -eq 0 ] && printf 'all script tests passed\n'
exit $fail
