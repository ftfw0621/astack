# astack design rules

astack is a set of Claude Code skills for rigorous engineering work. It is derived from pstack (see `pstack-audit.md`) and rebuilt for two constraints pstack does not have: it must work on ordinary models, and it must run natively in Claude Code.

## The one router

`/astack <task>` is the entry point. It matches the task to a playbook, copies the playbook's steps into the todo list, and invokes the other skills as steps fire. The other skills are usable on their own. Nothing else is a mode.

## Written for ordinary models

1. **Numbered steps, each ending in a check.** A step names what to produce and what proves it. No step says "use judgment" without a default rule for when judgment is unavailable.
2. **Templates over instructions.** A brief template for delegates, a PR body template, a reply contract per playbook, a decision-log row. The model fills placeholders. It does not invent structure.
3. **Scripts over prose.** When a rule is checkable, a script checks it. `scripts/check-skill.sh` validates skills, `scripts/test-smells.sh` flags tests that observe nothing, `scripts/code-smells.sh` flags the checkable half of the code-quality standard, `scripts/log.sh` writes decision rows. Every script has a fixture test in `tests/run.sh`. A cited principle with no script in the diff was not applied (`build-the-lever`).
4. **Definition of done is a checklist the reply must fill.** Every playbook ends with a Reply section. Each item carries evidence or its label: measured, inferred, or guess.
5. **Short.** The router stays under 8 KB. A leaf skill stays under 6 KB. References load only when a step needs them. The 23 principles cost one description in context, not 23.

## Roles by model strength

| Role | Default | Why |
|---|---|---|
| Judgment (design pick, review verdict, dismissals, synthesis) | the strongest model available, `opus` by default, or the parent model | quality ceiling sits here |
| Code delegate (feature, fix, refactor edits) | `sonnet` | follows a good brief well and is cheap |
| Explorer (read-only fan-out) | `haiku` | bulk reading, summaries only |
| Adversarial reviewer | `opus` plus `codex exec` when the CLI is installed | different family, different blind spots |

Override in `~/.claude/astack-models.md`, one line per role. A missing file keeps the defaults. The author of a diff never judges its own diff.

## Claude Code native

- Routing uses the Skill tool. Delegation uses the Agent tool with `model`, `run_in_background: true`, and `isolation: "worktree"` when the delegate writes code.
- Custom agents live in `agents/` (`comment-sicko`, `astack-agent`). When installed as a plugin they appear as `astack:<name>`.
- Autonomous runs use `/loop` and `ScheduleWakeup`, never a sleep loop.
- Transcripts live under `~/.claude/projects/<slug>/`, where `<slug>` is the workspace path with `/` replaced by `-`.
- Skills refer to each other by bare name ("the `how` skill"). The plugin namespace resolves that to `astack:how`; a symlink install resolves it to `how`.

## Skill shape

```
---
name: <bare-name>
description: <one or two sentences, under 30 words, trigger words first>
---

# <Title>

**You own <the thing>.** One paragraph contract.

1. Step. Check.
2. Step. Check.

**Reply:** the items the reply must contain, with the evidence for each.
```

Skills that no one but a human should fire (`bro`, `setup-astack`) set `disable-model-invocation: true`. Everything else is model-invocable so the router can reach it.

## Provenance

Each skill's pstack origin and the changes made are recorded in `pstack-audit.md`, not in the skill body, so the body carries only instructions.
