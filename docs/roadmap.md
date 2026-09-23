# Roadmap

Waves are ordered by what the feature and bug-fix paths need first. A wave ships when its skills pass `scripts/check-skill.sh` and one real task has run through them.

## Wave 1, shipped in the first commit

Router and the code path: `astack` (router) with playbooks investigation, bug-fix, feature, refactoring, prototype, opening-a-pr, autonomous-run, authoring-a-skill. Leaves: `principles`, `how`, `architect`, `arena`, `interrogate`, `tdd`, `test-quality`, `no-comments`, `unslop`, `show-me-your-work`, `bro`. Agents: `comment-sicko`, `astack-agent`. Scripts: `check-skill.sh`, `test-smells.sh`, `log.sh`.

## Wave 2, understanding and shipping

- `why` with Claude Code MCP discovery (Linear, Slack, Grafana or Chronosphere, Loki, Databricks).
- `blast-radius`, `swarm`, `figure-it-out`, `technical-writing`, `reflect`, `setup-astack`.
- Playbooks: perf-issue, hillclimb, session-pickup, pause-safely, babysit (generic bot-review triage, one-retry CI rule, merge frontier), multi-phase-plan with `scripts/check-plan.mjs`, worktree-cleanup with `scripts/worktree-audit.sh`.
- Language packs with `paths:` auto-load: `go-practices`, `python-practices`, `typescript-practices`, each grounding `type-system-discipline` and `boundary-discipline` in syntax.

## Wave 3, verification and measurement

- `create-verification-skill` and `maintain-verification-skill` targeting `.claude/skills/verify-<app>/`.
- `recall`, `teach`, `automate-me` on Claude Code transcripts.
- Playbooks: eval (blinded arena plus `claude plugin eval`), runtime-forensics, trace-forensics, visual-parity.
- An `evals/` suite for `claude plugin eval`: a feature task, a bug-fix task, and a test-quality task on a fixture repo, graded with and without the plugin.

## Not planned

`orchestrate`, `autopilot-full`, `autopilot-stack`, `shipping`, `make-bot-ui`, the `benny` automation pack, and the `watch-pr` and `orch` TypeScript tooling. See `pstack-audit.md` for the reasons.
