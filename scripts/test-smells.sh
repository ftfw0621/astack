#!/usr/bin/env bash
# Flag tests that observe no behavior (the test-quality skill, shapes 1 and 2).
# Usage: scripts/test-smells.sh [--base <ref>] [file-or-dir ...]
#   --base <ref>   scan test files changed against <ref> (default when no paths given: origin/main, else main)
# Prints file:line: <smell>. Exit 1 when any test has no assertion or only weak assertions.
# Heuristic. Every printed line is fixed or justified in one sentence in the PR body.
set -u
base=""
paths=()
while [ $# -gt 0 ]; do
	case "$1" in
		--base) base=$2; shift 2 ;;
		*) paths+=("$1"); shift ;;
	esac
done

is_test_file() {
	case "$1" in
		*_test.go|*/test_*.py|*_test.py|*/tests/*.py|*.test.ts|*.test.tsx|*.test.js|*.test.jsx|*.spec.ts|*.spec.tsx|*.spec.js|*/__tests__/*) return 0 ;;
	esac
	return 1
}

collect() {
	if [ ${#paths[@]} -eq 0 ]; then
		if [ -z "$base" ]; then
			if git rev-parse --verify -q origin/main >/dev/null; then base=origin/main; else base=main; fi
		fi
		git diff --name-only "$base" 2>/dev/null
		git ls-files --others --exclude-standard 2>/dev/null
	else
		for p in "${paths[@]}"; do
			if [ -d "$p" ]; then find "$p" -type f; else printf '%s\n' "$p"; fi
		done
	fi
}

go_scan() {
	awk -v file="$1" '
	function flush() {
		if (!inblock) return
		if (strong + weak == 0) { print file ":" start ": no assertion in " name; bad++ }
		else if (strong == 0) { print file ":" start ": only weak assertions in " name " (" weak " weak, none against a literal expected value)"; bad++ }
	}
	/^func (Test|Example|Fuzz)/ { flush(); name=$2; sub(/\(.*/, "", name); start=NR; inblock=1; strong=0; weak=0; next }
	inblock && /^}/ { flush(); inblock=0 }
	inblock {
		if ($0 ~ /(assert|require)\.(Equal|EqualValues|Exactly|JSONEq|YAMLEq|ElementsMatch|Contains|NotContains|ErrorIs|ErrorAs|ErrorContains|EqualError|Same|Regexp|InDelta|Subset|Len\(t, [^,]+, [1-9])/ || $0 ~ /cmp\.(Diff|Equal)|reflect\.DeepEqual|t\.(Error|Errorf|Fatal|Fatalf)\(|assert\.Snapshot|golden/) strong++
		else if ($0 ~ /(assert|require)\.(NoError|Nil|NotNil|True|False|Empty|NotEmpty|Error|Zero|NotZero|Len\(t, [^,]+, 0\))\(/) { weak++; print file ":" NR ": weak matcher: " $0 }
		if ($0 ~ /AssertExpectations|AssertCalled|AssertNotCalled|AssertNumberOfCalls/) print file ":" NR ": asserts a mock was called, not what it received"
	}
	END { flush(); exit bad > 0 }' "$1"
}

py_scan() {
	awk -v file="$1" '
	function indent(s) { match(s, /[^ \t]/); return RSTART - 1 }
	function flush() {
		if (!inblock) return
		if (strong + weak == 0) { print file ":" start ": no assertion in " name; bad++ }
		else if (strong == 0) { print file ":" start ": only weak assertions in " name " (" weak " weak, none against a literal expected value)"; bad++ }
	}
	/^[ \t]*(async )?def test_/ { flush(); name=$0; sub(/^[ \t]*(async )?def /, "", name); sub(/\(.*/, "", name); start=NR; lvl=indent($0); inblock=1; strong=0; weak=0; next }
	inblock && /^[ \t]*((async )?def |class )/ && indent($0) <= lvl { flush(); inblock=0 }
	function depth(s,   i, c, d) { d = 0; for (i = 1; i <= length(s); i++) { c = substr(s, i, 1); if (c == "(" || c == "[" || c == "{") d++; else if (c == ")" || c == "]" || c == "}") d-- } return d }
	function classify(text, line) {
		if (text ~ /pytest\.raises|assertRaises|assertEqual|assertDictEqual|assertListEqual|assertTupleEqual|assertSequenceEqual|assertAlmostEqual|assertIn\(|assertNotIn\(|assertCountEqual|assertRegex|assert_called_with|assert_called_once_with|assert_has_calls|snapshot|assert .*(==|!=| in | not in |<=|>=)/) strong++
		else if (text ~ /^[ \t]*assert /) { weak++; print file ":" line ": weak assertion: " text }
		else if (text ~ /assertTrue\(|assertFalse\(|assertIsNone\(|assertIsNotNone\(|assertIsInstance\(|\.assert_called\(\)|\.assert_called_once\(\)|\.assert_not_called\(\)|assert .*\.called\b/) { weak++; print file ":" line ": weak assertion: " text }
	}
	inblock && pending != "" {
		pending = pending " " $0; sub(/[ \t]+$/, "", pending)
		if (depth(pending) <= 0 && pending !~ /\\$/) { classify(pending, pendline); pending = "" }
		next
	}
	inblock {
		if ($0 ~ /^[ \t]*assert / && (depth($0) > 0 || $0 ~ /\\$/)) { pending = $0; pendline = NR; next }
		classify($0, NR)
	}
	END { flush(); exit bad > 0 }' "$1"
}

ts_scan() {
	awk -v file="$1" '
	function flush() {
		if (!inblock) return
		if (strong + weak == 0) { print file ":" start ": no assertion in " name; bad++ }
		else if (strong == 0) { print file ":" start ": only weak assertions in " name " (" weak " weak, none against a literal expected value)"; bad++ }
	}
	/^[ \t]*(it|test)(\.each\([^)]*\))?\(/ { flush(); name=$0; sub(/^[ \t]*(it|test)(\.each\([^)]*\))?\([ \t]*/, "", name); sub(/,.*/, "", name); start=NR; inblock=1; strong=0; weak=0; next }
	inblock {
		if ($0 ~ /expect(TypeOf)?\(/ || $0 ~ /assert\.(equal|deepEqual|strictEqual|deepStrictEqual|match|throws)/) {
			if ($0 ~ /\.(toBeDefined|toBeTruthy|toBeFalsy|toBeUndefined|toBeInstanceOf|toBeGreaterThan\(0\)|toHaveBeenCalled\(\)|toHaveBeenCalledTimes|toEqual\(\[\]\)|toHaveLength\(0\))|\.not\.(toThrow|toHaveBeenCalled|toBe|toEqual)\(/) { weak++; print file ":" NR ": weak matcher: " $0 }
			else strong++
		}
	}
	END { flush(); exit bad > 0 }' "$1"
}

status=0
scanned=0
while IFS= read -r f; do
	[ -n "$f" ] && [ -f "$f" ] || continue
	is_test_file "$f" || continue
	scanned=$((scanned + 1))
	case "$f" in
		*.go) go_scan "$f" || status=1 ;;
		*.py) py_scan "$f" || status=1 ;;
		*.ts|*.tsx|*.js|*.jsx) ts_scan "$f" || status=1 ;;
	esac
done < <(collect | sort -u)
printf 'test-smells: scanned %d test files\n' "$scanned" >&2
exit $status
