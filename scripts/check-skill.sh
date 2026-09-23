#!/usr/bin/env bash
# Validate every skill and agent in this repo against docs/design.md.
# Usage: scripts/check-skill.sh            (whole repo)
#        scripts/check-skill.sh skills/how (one skill dir)
# Exit 1 on any ERROR. WARN lines do not fail the run.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
errors=0
warns=0
err() { printf 'ERROR %s\n' "$1"; errors=$((errors + 1)); }
warn() { printf 'WARN  %s\n' "$1"; warns=$((warns + 1)); }

frontmatter() { awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f{print}' "$1"; }
body() { awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{f=0;b=1;next} b{print}' "$1"; }

# em dash, en dash, curly quotes outside backtick spans (unslop rules 13 and 19)
check_typography() {
	local file=$1 line
	while IFS= read -r line; do
		err "$file: typography (dash or curly quote) at body line ${line%%:*}"
	done < <(body "$file" | sed 's/`[^`]*`//g' | grep -n '[—–‘’“”]')
}

# relative markdown links must resolve
check_md_links() {
	local file=$1 dir link
	dir=$(dirname "$file")
	while IFS= read -r link; do
		case "$link" in http*|/*) continue ;; esac
		[ -e "$dir/$link" ] || err "$file: link target missing: $link"
	done < <(grep -o '\]([^)#]*\.md[^)]*)' "$file" | sed 's/^](//; s/)$//; s/#.*//' | sort -u)
}

# backticked repo paths must exist relative to the skill dir or the repo root
check_path_refs() {
	local file=$1 base=$2 ref skill
	while IFS= read -r ref; do
		case "$ref" in *'<'*|*'*'*) continue ;; esac
		[ -e "$base/$ref" ] || [ -e "$root/$ref" ] || [ -e "$root/skills/astack/$ref" ] || err "$file: referenced file missing: $ref"
	done < <(grep -o '`\(playbooks\|references\|scripts\|agents\)/[^` ]*`' "$file" | tr -d '`' | sort -u)
	while IFS= read -r skill; do
		[ -d "$root/skills/$skill" ] || warn "$file: refers to skill '$skill' which is not in this repo"
	done < <(grep -o 'the `[a-z-]*` skill' "$file" | sed 's/the `//; s/` skill//' | sort -u)
}

# a claude model spec always carries its version; adjacent versions differ and aliases move
check_versioned_models() {
	local file=$1 line
	while IFS= read -r line; do
		err "$file: versionless model spec at line ${line%%:*}: ${line#*:}"
	done < <(grep -n -E 'claude:(opus|sonnet|haiku|fable)(@|[^-a-z0-9]|$)' "$file" | cut -c1-120)
}

# skill bodies stay host-neutral; only hosts.md and runners.md name host-specific tools
check_host_neutral() {
	local file=$1 line
	case "$file" in */references/hosts.md|*/references/runners.md) return ;; esac
	while IFS= read -r line; do
		err "$file: host-specific term at line ${line%%:*} (move it to references/hosts.md): ${line#*:}"
	done < <(grep -n -E 'Agent tool|Skill tool|subagent_type|run_in_background|isolation: "worktree"|ScheduleWakeup|`Monitor`|/loop|~/\.claude/projects|~/\.claude/astack-models' "$file" | cut -c1-120)
}

check_skill() {
	local file=$1 dir name fm fname desc words size limit extra
	dir=$(dirname "$file")
	name=$(basename "$dir")
	if [ "$(head -1 "$file")" != "---" ]; then err "$file: no frontmatter"; return; fi
	fm=$(frontmatter "$file")
	fname=$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')
	[ "$fname" = "$name" ] || err "$file: frontmatter name '$fname' does not match directory '$name'"
	desc=$(printf '%s\n' "$fm" | sed -n 's/^description: *//p')
	[ -n "$desc" ] || err "$file: no description"
	words=$(printf '%s' "$desc" | wc -w | tr -d ' ')
	[ "$words" -le 45 ] || warn "$file: description is $words words (keep under 45)"
	printf '%s\n' "$fm" | grep -Eq '^(mode|icon|color|reminder|is_background):' && err "$file: Cursor-only frontmatter key"
	size=$(wc -c < "$file" | tr -d ' ')
	limit=6144
	[ "$name" = astack ] && limit=8192
	[ "$size" -le "$limit" ] || warn "$file: $size bytes, budget is $limit"
	case "$name" in astack|principles|unslop|bro|*-practices) ;; *)
		grep -q '^\*\*Reply:\*\*' "$file" || warn "$file: no **Reply:** contract" ;;
	esac
	check_typography "$file"
	check_md_links "$file"
	check_path_refs "$file" "$dir"
	check_host_neutral "$file"
	check_versioned_models "$file"
	for extra in "$dir"/playbooks/*.md "$dir"/references/*.md "$dir"/references/sources/*.md; do
		[ -f "$extra" ] || continue
		check_typography "$extra"
		check_md_links "$extra"
		check_path_refs "$extra" "$dir"
		check_host_neutral "$extra"
		check_versioned_models "$extra"
	done
}

check_agent() {
	local file=$1 fm
	if [ "$(head -1 "$file")" != "---" ]; then err "$file: no frontmatter"; return; fi
	fm=$(frontmatter "$file")
	printf '%s\n' "$fm" | grep -q '^name: ' || err "$file: agent has no name"
	printf '%s\n' "$fm" | grep -q '^description: ' || err "$file: agent has no description"
	check_typography "$file"
	check_host_neutral "$file"
}

if [ $# -eq 0 ]; then
	for f in "$root"/skills/*/SKILL.md; do check_skill "$f"; done
	for f in "$root"/agents/*.md; do check_agent "$f"; done
	for f in "$root"/docs/*.md "$root"/README.md; do
		[ -f "$f" ] || continue
		check_typography "$f"
		check_md_links "$f"
	done
	for s in "$root"/scripts/*.sh; do
		[ -x "$s" ] || err "$s: not executable"
		bash -n "$s" || err "$s: does not parse"
	done
else
	for t in "$@"; do
		if [ -f "$t/SKILL.md" ]; then check_skill "$t/SKILL.md"
		elif [ -f "$t" ]; then case "$t" in */agents/*) check_agent "$t" ;; *) check_skill "$t" ;; esac
		else err "$t: not a skill directory or file"; fi
	done
fi
printf '%d errors, %d warnings\n' "$errors" "$warns"
[ "$errors" -eq 0 ]
