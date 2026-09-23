#!/usr/bin/env bash
# Run an external runner seat headlessly and classify the outcome (runners.md).
# Usage: scripts/runner.sh <runner> <cwd> <prompt-file> <out-file> [--model M] [--effort E] [--timeout SECONDS] [--config FILE]
# Prints one status line on stdout: OK | UNAVAILABLE <reason> | FAILED exit=N | TIMEOUT | NATIVE
# Exit codes: 0 OK, 1 FAILED, 3 UNAVAILABLE, 4 TIMEOUT, 5 NATIVE (spawn it through the host), 2 usage.
set -u
runner=${1:-}; cwd=${2:-}; prompt=${3:-}; out=${4:-}
[ -n "$runner" ] && [ -n "$cwd" ] && [ -n "$prompt" ] && [ -n "$out" ] || { echo "usage: runner.sh <runner> <cwd> <prompt-file> <out-file> [--model M] [--effort E] [--timeout S] [--config FILE]" >&2; exit 2; }
shift 4
model=""; effort=""; timeout=900; config=${ASTACK_RUNNERS:-$HOME/.config/astack/runners.md}
while [ $# -gt 0 ]; do
	case "$1" in
		--model) model=$2; shift 2 ;;
		--effort) effort=$2; shift 2 ;;
		--timeout) timeout=$2; shift 2 ;;
		--config) config=$2; shift 2 ;;
		*) echo "unknown option $1" >&2; exit 2 ;;
	esac
done
[ -f "$config" ] || { echo "runners file not found: $config" >&2; exit 2; }
[ -f "$prompt" ] || { echo "prompt file not found: $prompt" >&2; exit 2; }

# Read the runner's block: lines indented under "<runner>:" until the next unindented key.
block=$(awk -v r="$runner" '
	/^[a-zA-Z0-9_-]+:[ \t]*$/ { name=$0; sub(/:.*/, "", name); inblk = (name == r); next }
	inblk && /^[ \t]+[a-zA-Z_-]+:/ { line=$0; sub(/^[ \t]+/, "", line); print line }' "$config")
[ -n "$block" ] || { echo "runner not defined: $runner" >&2; exit 2; }
field() { printf '%s\n' "$block" | sed -n "s/^$1:[ \t]*//p" | head -1; }
command_tpl=$(field command)
if [ -z "$command_tpl" ]; then echo "NATIVE"; exit 5; fi
unavailable_re=$(field unavailable)

# Substitute placeholders. Paths are absolute so the template's cd cannot be fooled.
cwd=$(cd "$cwd" && pwd) || { echo "cwd not found" >&2; exit 2; }
prompt=$(cd "$(dirname "$prompt")" && pwd)/$(basename "$prompt")
mkdir -p "$(dirname "$out")"; out=$(cd "$(dirname "$out")" && pwd)/$(basename "$out")
cmd=$command_tpl
cmd=${cmd//\{cwd\}/$cwd}; cmd=${cmd//\{prompt\}/$prompt}; cmd=${cmd//\{out\}/$out}
cmd=${cmd//\{model\}/$model}; cmd=${cmd//\{effort\}/$effort}

errfile=$(mktemp)
: > "$out"
bash -c "$cmd" < /dev/null > "$out.stdout" 2> "$errfile" &
pid=$!
elapsed=0
while kill -0 "$pid" 2>/dev/null; do
	if [ "$elapsed" -ge "$timeout" ]; then
		kill "$pid" 2>/dev/null; sleep 1; kill -9 "$pid" 2>/dev/null
		echo "TIMEOUT"; cat "$errfile" >&2; rm -f "$errfile"; exit 4
	fi
	sleep 1; elapsed=$((elapsed + 1))
done
wait "$pid"; code=$?
# Templates that do not redirect stdout to {out} still get their answer captured.
[ -s "$out" ] || cat "$out.stdout" > "$out"
rm -f "$out.stdout"
combined=$(cat "$errfile" "$out" 2>/dev/null)
if [ "$code" -ne 0 ]; then
	if [ -n "$unavailable_re" ] && printf '%s' "$combined" | grep -qiE "$unavailable_re"; then
		reason=$(printf '%s' "$combined" | grep -oiE "$unavailable_re" | head -1)
		echo "UNAVAILABLE $reason"; cat "$errfile" >&2; rm -f "$errfile"; exit 3
	fi
	echo "FAILED exit=$code"; cat "$errfile" >&2; rm -f "$errfile"; exit 1
fi
if [ ! -s "$out" ]; then echo "FAILED exit=0 empty output"; cat "$errfile" >&2; rm -f "$errfile"; exit 1; fi
echo "OK"; rm -f "$errfile"; exit 0
