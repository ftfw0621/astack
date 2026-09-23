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

## Roles by model strength, filled by runner chains

| role | default chain | why |
|---|---|---|
| judgment (design pick, review verdict, dismissals, synthesis) | `claude:opus-5-5@max > codex:gpt-6-astra@xhigh > parent` | quality ceiling sits here |
| hardest (investigation before the cause is known, the how explainer and why synthesizer, generation of cross-cutting or subtle code) | `claude:opus-5-5@xhigh > parent` | generation and judgment cannot be separated here |
| code (edits once shape, usage, acceptance, and cause are written down) | `codex:gpt-6-astra@high > claude:opus-5-5@high > parent` | follows a tight brief well |
| explore (read-only fan-out) | `claude:opus-5-5@high > codex:gpt-6-astra@xhigh > parent` | a summary is only as good as the reader's understanding of the code |
| chore (self-contained ad hoc tasks: git archaeology, a deletion or rename PR, a version bump, run a script and report) | `mini:deepseek-flash@max > claude:haiku-4-5 > parent` | one-paragraph spec, mechanical done-check, nothing decided by reading code |
| adversarial (panel) | `claude:opus-5-5@max, codex:gpt-6-astra@xhigh` | different families, different blind spots |

A runner is a headless way to run a model: a native delegate on the host, or an external CLI (`codex`, `mini`) invoked through `scripts/runner.sh`, read-only by default and through its `write-command` (`--write`) for a seat that edits files. A runner without quota, auth, or capacity falls through to the next in the chain, `parent` (the host's own model) closes every chain, and every fallback is named in the reply. Chains and runner commands live in `~/.config/astack/`, written by `setup-astack`. The author of a diff never judges its own diff. Full rules: `skills/astack/references/runners.md`.

## Host-neutral skills

astack runs under Claude Code, Codex, or mini-agent. Skill bodies use neutral words (spawn a delegate, invoke a skill, wake on an event, this session's transcript) and `skills/astack/references/hosts.md` maps each to the host's mechanism. `scripts/check-skill.sh` fails a skill that names a host-specific tool anywhere else.

## Agents

`agents/` holds the two agent contracts (`comment-sicko`, `astack-agent`). On Claude Code they are custom agents (`astack:<name>` as a plugin). On other hosts their bodies are prepended to the delegate's prompt. Skills refer to each other by bare name ("the `how` skill"); each host resolves that to its own invocation form.

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

Skills that no one but a human should fire (`bro`, `setup-astack`) set `disable-model-invocation: true`. Everything else is model-invocable so the router can reach it. Language packs add `paths:` so they load when a file of that language is edited.

## Provenance

Each skill's pstack origin and the changes made are recorded in `pstack-audit.md`, not in the skill body, so the body carries only instructions.
