#!/usr/bin/env bash
# Flag the checkable subset of the code-quality skill on a diff.
# Usage: scripts/code-smells.sh [--base <ref>] [file ...]
#   --base <ref>   diff the working tree against <ref> (default: origin/main, else main)
#   file ...       scan whole files instead of a diff (every line counts as added)
# Prints file:line: <category>: <snippet>. Exit 1 when anything is flagged.
# Heuristic. Every printed line is fixed or justified in one sentence in the PR body.
# The judgment half of the standard (shallow modules, spaghetti growth, wrong layer) is the skill's job.
set -u
base=""
files=()
while [ $# -gt 0 ]; do
	case "$1" in
		--base) base=$2; shift 2 ;;
		*) files+=("$1"); shift ;;
	esac
done
if [ ${#files[@]} -eq 0 ] && [ -z "$base" ]; then
	if git rev-parse --verify -q origin/main >/dev/null; then base=origin/main; else base=main; fi
fi

flagged=0
flag() { printf '%s:%s: %s: %s\n' "$1" "$2" "$3" "$4"; flagged=$((flagged + 1)); }

# Pattern checks on added lines. $1 file, $2 line number, $3 text.
check_line() {
	local f=$1 n=$2 t=$3 ext=${1##*.}
	case "$t" in *TODO*|*FIXME*|*HACK*|*XXX*) flag "$f" "$n" "todo-left-behind" "$t" ;; esac
	case "$ext" in
		ts|tsx|js|jsx)
			case "$t" in
				*'as any'*|*': any'*|*'<any>'*|*'@ts-ignore'*|*'@ts-expect-error'*|*'eslint-disable'*) flag "$f" "$n" "type-escape" "$t" ;;
			esac
			[[ "$t" =~ \ as\ [A-Z][A-Za-z0-9_]* ]] && flag "$f" "$n" "cast" "$t"
			[[ "$t" =~ catch[[:space:]]*(\([^\)]*\))?[[:space:]]*\{[[:space:]]*\} ]] && flag "$f" "$n" "swallowed-error" "$t"
			[[ "$t" =~ console\.(log|debug)\( ]] && flag "$f" "$n" "debug-print" "$t"
			;;
		go)
			case "$t" in *'interface{}'*|*'//nolint'*) flag "$f" "$n" "type-escape" "$t" ;; esac
			[[ "$t" =~ \.\([A-Z][A-Za-z0-9_]*\) ]] && flag "$f" "$n" "cast" "$t"
			[[ "$t" =~ ^[[:space:]]*_[[:space:]]*=[[:space:]]*err ]] && flag "$f" "$n" "swallowed-error" "$t"
			;;
		py)
			case "$t" in *'# type: ignore'*|*'# noqa'*|*'cast('*) flag "$f" "$n" "type-escape" "$t" ;; esac
			[[ "$t" =~ ^[[:space:]]*except[^:]*:[[:space:]]*pass ]] && flag "$f" "$n" "swallowed-error" "$t"
			;;
		java)
			case "$t" in *'@SuppressWarnings'*) flag "$f" "$n" "type-escape" "$t" ;; esac
			[[ "$t" =~ catch[[:space:]]*\([^\)]*\)[[:space:]]*\{[[:space:]]*\} ]] && flag "$f" "$n" "swallowed-error" "$t"
			;;
	esac
	# commented-out code and narrating comments
	if [[ "$t" =~ ^[[:space:]]*(//|#)[[:space:]]*(if|for|while|return|const|let|var|func|def|import|from|print|console|[A-Za-z_][A-Za-z0-9_.]*\(|[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=[^=]) ]]; then
		flag "$f" "$n" "commented-out-code" "$t"
	elif [[ "$t" =~ ^[[:space:]]*(//|#)[[:space:]]*(Step[[:space:]]+[0-9]|Phase[[:space:]]+[0-9]|First,|Then,|Now,|Finally,|Next,) ]]; then
		flag "$f" "$n" "narrating-comment" "$t"
	fi
	# nesting depth (5 levels of tab or 4-space indent)
	if [[ "$t" =~ ^(\t{5,}|( {4}){5,})[^[:space:]] ]]; then flag "$f" "$n" "deep-nesting" "$t"; fi
}

# Two-line window for `except ...:` followed by `pass`, and `catch (...) {` followed by `}`.
prev_text=""
prev_n=0
prev_f=""
check_pair() {
	local f=$1 n=$2 t=$3
	if [ "$f" = "$prev_f" ] && [ "$n" -eq $((prev_n + 1)) ]; then
		if [[ "$prev_text" =~ ^[[:space:]]*except[^:]*:[[:space:]]*$ ]] && [[ "$t" =~ ^[[:space:]]*pass[[:space:]]*$ ]]; then flag "$f" "$n" "swallowed-error" "$prev_text / $t"; fi
		if [[ "$prev_text" =~ catch[[:space:]]*(\([^\)]*\))?[[:space:]]*\{[[:space:]]*$ ]] && [[ "$t" =~ ^[[:space:]]*\}[[:space:]]*$ ]]; then flag "$f" "$n" "swallowed-error" "$prev_text / $t"; fi
	fi
	prev_text=$t; prev_n=$n; prev_f=$f
}

# Long functions (over 80 lines) that contain added lines. $1 file, $2 space-separated added line numbers.
check_long_functions() {
	local f=$1 added=$2 ext=${1##*.}
	[ -f "$f" ] || return
	awk -v file="$f" -v added=" $added " -v ext="$ext" '
	function is_start(s) {
		if (ext == "go") return s ~ /^func /
		if (ext == "py") return s ~ /^[ \t]*(async )?def /
		if (ext == "ts" || ext == "tsx" || ext == "js" || ext == "jsx") return s ~ /^[ \t]*(export )?(default )?(async )?function /
		if (ext == "java") return s ~ /^[ \t]*(public|private|protected|static|final|synchronized|abstract)([ \t]+[a-zA-Z<>\[\], ]+)+\(/ && s !~ /;[ \t]*$/
		return 0
	}
	function report() {
		if (start && NR - 1 - start + 1 > 80) {
			for (i = start; i < NR; i++) if (index(added, " " i " ")) { print file ":" start ": long-function: " len " lines, touched by this change"; break }
		}
	}
	{ if (is_start($0)) { len = NR - start; report(); start = NR } }
	END { len = NR - start + 1; NR++; report() }' "$f"
}

added_lines_for() {
	# print "file<TAB>line<TAB>text" for every added line in the diff
	git diff --no-color --unified=0 "$base" -- 2>/dev/null | awk '
	/^\+\+\+ / { f = $2; sub(/^b\//, "", f); next }
	/^@@/ { match($3, /\+[0-9]+/); n = substr($3, RSTART + 1, RLENGTH - 1) + 0; next }
	/^\+/ && f != "/dev/null" { print f "\t" n "\t" substr($0, 2); n++; next }
	/^[^-]/ && !/^diff/ && !/^index/ && !/^---/ { n++ }'
}

file_size_check() {
	local f=$1 before after
	[ -f "$f" ] || return
	after=$(wc -l < "$f" | tr -d ' ')
	if [ -n "$base" ]; then before=$(git show "$base:$f" 2>/dev/null | wc -l | tr -d ' '); else before=0; fi
	if [ "$after" -gt 1000 ] && [ "$before" -le 1000 ]; then flag "$f" 1 "file-over-1000-lines" "$before -> $after lines"; fi
}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if [ ${#files[@]} -gt 0 ]; then
	for f in "${files[@]}"; do
		[ -f "$f" ] || continue
		n=0
		while IFS= read -r line; do n=$((n + 1)); check_line "$f" "$n" "$line"; check_pair "$f" "$n" "$line"; printf '%s\t%s\n' "$f" "$n" >> "$tmp"; done < "$f"
		file_size_check "$f"
	done
else
	while IFS=$'\t' read -r f n t; do
		[ -n "$f" ] || continue
		check_line "$f" "$n" "$t"; check_pair "$f" "$n" "$t"; printf '%s\t%s\n' "$f" "$n" >> "$tmp"
	done < <(added_lines_for)
	while IFS= read -r f; do [ -n "$f" ] && file_size_check "$f"; done < <(cut -f1 "$tmp" | sort -u)
fi
while IFS= read -r f; do
	[ -n "$f" ] || continue
	added=$(awk -F'\t' -v f="$f" '$1 == f { printf "%s ", $2 }' "$tmp")
	while IFS= read -r line; do [ -n "$line" ] && { printf '%s\n' "$line"; flagged=$((flagged + 1)); }; done < <(check_long_functions "$f" "$added")
done < <(cut -f1 "$tmp" | sort -u)
printf 'code-smells: %d flagged\n' "$flagged" >&2
[ "$flagged" -eq 0 ]
