# pstack audit

Every file in pstack 0.15.3 (`cursor/plugins/pstack`, read 2026-09-23), classified for astack. Verdicts: **adopt** (keep the idea and most of the text), **adapt** (keep the idea, rewrite the mechanics for Claude Code or for ordinary models), **skip** (do not carry over). Wave numbers refer to `roadmap.md`.

## Skills

| pstack skill | verdict | astack | wave | why |
|---|---|---|---|---|
| `poteto-mode` | adapt | `astack` | 1 | The router is the best idea in the stack: match a playbook, copy its steps into the todo list, invoke leaves as steps fire, end with a reply contract. Cursor-only parts dropped: `mode: true` sticky frontmatter, `/goal`, cloud agents, `Task` field names, model slugs, `/deslop` and `control-*` from `cursor-team-kit`. Cut from 19 KB to under 8 KB. |
| 23 `principle-*` skills | adopt | `principles` | 1 | All 23 kept nearly verbatim. Packaged as one skill with the index in `SKILL.md` and one file per principle under `references/`, so the catalog costs one description in context instead of 23. |
| `how` | adopt | `how` | 1 | Explorer and explainer prompts kept. Models mapped to Agent tool roles (explorers on the explore model, explainer on the judgment model). |
| `why` | adapt | `why` | 2 | Evidence-category design and epistemics kept whole. MCP discovery rewritten for Claude Code MCP servers. Source playbooks adapted to the user's tools (Linear, Slack, Grafana, Loki, Databricks). |
| `recall` | adapt | `recall` | 3 | Transcript path becomes `~/.claude/projects/<slug>/`. Otherwise kept. |
| `blast-radius` | adopt | `blast-radius` | 2 | The "prove the one fact it is safe because of" rule is exactly the kind of mechanism ordinary models need. |
| `architect` | adopt | `architect` | 1 | Usage-first, design-it-twice, red-flag screen, scrap rule. Runners mapped to Agent tool models. |
| `arena` | adopt | `arena` | 1 | Candidates get `isolation: "worktree"`. Cross-judge on a different model than the parent. |
| `swarm` | adapt | `swarm` | 2 | `environment: "cloud"` and `cloud_base_branch` dropped. Frame, fan out, aggregate, report kept. |
| `interrogate` | adapt | `interrogate` | 1 | Reviewer panel becomes Claude models plus `codex exec` when installed. Rubric, code-quality lens, lead-judgment filter kept whole. |
| `automate-me` | adapt | `automate-me` | 3 | Mines Claude Code transcripts instead of Cursor's. Low priority. |
| `make-bot-ui` | skip | | | Grok Bot webhooks and Tailscale. Cursor product feature. |
| `setup-pstack` | adapt | `setup-astack` | 2 | Writes `~/.claude/astack-models.md`. Roles collapse to four: judgment, code, explore, adversarial. |
| `reflect` | adapt | `reflect` | 2 | Three-lens review and the approve-before-apply gate kept. Transcript path and skill locations changed. |
| `teach` | adopt | `teach` | 3 | Image-generation step dropped. |
| `tdd` | adopt | `tdd` | 1 | Kept. Paired with `test-quality` so the failing test is also a good test. |
| `no-comments` + Comment Sicko | adopt | `no-comments`, `agents/comment-sicko.md` | 1 | The author-versus-reviewer separation applied to comments. Cursor `Task` wording replaced with the Agent tool. |
| `typescript-best-practices` | adapt | `typescript-practices`, plus `go-practices`, `python-practices` | 2 | The monorepo is Go, Python, Java, TypeScript. One pack per language, each with `paths:` auto-load. |
| `figure-it-out` | adopt | `figure-it-out` | 2 | Kept. |
| `show-me-your-work` | adopt | `show-me-your-work` | 1 | TSV log and `log.sh` kept. Transcript audit path changed. |
| `create-verification-skill` | adapt | `create-verification-skill` | 3 | Output moves to `.claude/skills/verify-<app>/`. |
| `maintain-verification-skill` | adapt | `maintain-verification-skill` | 3 | Same. |
| `unslop` | adopt | `unslop` | 1 | A pattern catalog with stable rule numbers. Mechanical. Kept verbatim. |
| `bro` | adopt | `bro` | 1 | Three lines. |
| `technical-writing` | adopt | `technical-writing` | 2 | Kept. |
| `poteto-agent` | adapt | `agents/astack-agent.md` | 1 | Reads the router in full before working. |

astack-original skills with no pstack counterpart: `code-quality` (merged from the user's thermo-nuclear review standard and pstack's code-quality lens), `test-quality` (the test-behavior principle as a checklist plus `scripts/test-smells.sh`), `formal-verification` (triage plus TLA+ and Lean paths, modelled on the monorepo's StartupMigration spec pattern), `go-practices` and `python-practices` (siblings of the TypeScript pack).

## Playbooks

| playbook | verdict | wave | why |
|---|---|---|---|
| investigation | adapt | 1 | Kept. `unslop` pass kept. |
| bug-fix | adapt | 1 | Control-skill reproduction replaced with "reproduce on the cheapest real surface: a test, a script, the running service". Delegate brief template added. |
| feature | adapt | 1 | Throughput checkpoint kept. Delegate brief template with the named shape, caller usage, acceptance, and forbidden moves added so an ordinary model can execute it. |
| refactoring | adapt | 1 | Kept. Pin the contract first, subtract, move, prove equivalence. |
| prototype | adopt | 1 | Kept. |
| opening-a-pr | adapt | 1 | Origin and Graphite forge logic, `--status open`, and `/deslop` dropped. Conventional Commits, briefing-style body, ready-not-draft kept. Slop strip folded into a checklist. |
| autonomous-run | adapt | 1 | Wake mechanism becomes `/loop` and `ScheduleWakeup`. |
| authoring-a-skill | adapt | 1 | Cursor's `create-skill` replaced with `scripts/check-skill.sh` and the skill shape in `design.md`. |
| perf-issue | adopt | 2 | The eight strategy families are a good hypothesis generator. |
| hillclimb | adopt | 2 | Kept. |
| session-pickup | adapt | 2 | Transcript path changed. |
| pause-safely | adapt | 2 | Resume note path changed. |
| babysit | adapt | 2 | Mode declaration, merge frontier, one-retry CI rule, skeptical bot triage kept. Origin, Graphite, queued-merge verdict names, and the `watch-pr` TypeScript watcher dropped. |
| multi-phase-plan | adapt | 2 | Plan as checkboxes with evidence and a check script kept. Ten live lanes per PR, `/goal`, and the 30-minute audit tick dropped. |
| worktree-cleanup | adapt | 2 | Audit script rewritten for Claude Code transcripts. Adds the lesson that build caches leave read-only files, so `git worktree remove --force` after `chmod -R u+w`. |
| eval | adapt | 3 | Blinding rules kept. `claude plugin eval` added for trigger tests. |
| runtime-forensics, trace-forensics | adopt | 3 | Short and portable. |
| visual-parity | adopt | 3 | Needs a UI control skill first. |
| shipping | skip | | Stack landing through Origin or Graphite with per-PR cloud verifiers. The target repos squash-merge single PRs and a human merges. The patch-id rule survives as a note in babysit. |
| orchestrate | skip | | Coordinator store, `orch.ts`, sub-coordinators, hundreds of subagents. Heavy machinery for a program scale the user does not run. |
| autopilot-full, autopilot-stack | skip | | One cloud owner per PR with merge authority. Same reason. |

## References, scripts, agents, automations

| item | verdict | wave | why |
|---|---|---|---|
| `references/bugbot-triage.md` | adapt | 2 | Becomes a generic bot-review triage rubric with the same learned-pattern format. |
| `scripts/log.sh` | adopt | 1 | Kept, with the formula-prefix guard. |
| `scripts/check-plan.mjs` | adapt | 2 | Rewritten for the trimmed plan template. |
| `scripts/worktree-audit.sh` | adapt | 2 | Transcript path and PR lookup changed. |
| `scripts/watch-pr/*` | skip | | Bun and TypeScript GitHub watcher tied to queued-merge verdicts. `gh pr checks --watch` covers the need. |
| `scripts/orch/*`, `scripts/bootstrap.ts` | skip | | Orchestrate tooling. |
| `agents/comment-sicko.md` | adopt | 1 | Kept. |
| `automations/benny/*` | skip | | Cursor Automations product. The idea (Slack report to triage to repro) could return as a Claude Code routine later. |
| `docs/guide/*` | adapt | 3 | astack writes its own short guide once wave 2 lands. |
| `~/.cursor/rules/pstack-models.mdc` | adapt | 2 | Becomes `~/.claude/astack-models.md`. |
