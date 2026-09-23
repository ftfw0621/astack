# Runners and fallback

A role is a seat. A runner fills it. The host's own model is a runner named `parent`, always available, always last in a chain.

## Role file: `~/.config/astack/models.md`

```
# astack roles. A chain tries runners left to right. parent is the host model and is always last.
budget: large
judgment: claude:opus-5-5@max > codex:gpt-6-astra@xhigh > parent
hardest: claude:opus-5-5@xhigh > parent
code: codex:gpt-6-astra@high > claude:opus-5-5@high > parent
explore: claude:opus-5-5@high > codex:gpt-6-astra@xhigh > parent
chore: mini:deepseek-flash@max > claude:haiku-4-5 > parent
adversarial: claude:opus-5-5@max, codex:gpt-6-astra@xhigh
```

A runner spec is `<runner>:<model>[@<effort>]`. The model always carries its version (`opus-5-5`, not `opus`; `gpt-6-astra`, not `gpt-6`), because adjacent versions differ a lot and an alias silently moves. `parent` takes no model. A panel role (`adversarial`) lists seats separated by commas. One reviewer runs per seat. A seat may carry its own chain with `>`. A missing role line keeps the default chain in the `astack` skill. A missing file keeps every default.

`budget` sets the effort of every runner that has no explicit `@effort`, through each runner's `budget` map below. `unlimited` leaves the runner's top effort. An explicit `@effort` on a role line always wins.

## Runner file: `~/.config/astack/runners.md`

One block per runner. `command` is a shell template that runs read-only by mechanism. `write-command` is the template `runner.sh --write` uses for a seat that edits files (`code`, a chore that opens a PR); a runner without one reports `UNAVAILABLE no write-command` for such a seat and the chain moves on. `unavailable` is a regex over the runner's combined output that marks a quota, auth, or capacity failure.

```
claude:
  host: claude-code
  models: fable-5-1=claude-fable-5-1 opus-5-5=claude-opus-5-5 opus-5=claude-opus-5 opus-4-8=claude-opus-4-8 sonnet-5=claude-sonnet-5 haiku-4-5=claude-haiku-4-5
  aliases: fable-5-1=fable opus-5-5=opus sonnet-5=sonnet haiku-4-5=haiku
  efforts: low medium high xhigh max
  no-effort: haiku-4-5
  budget: unlimited=max large=xhigh medium=high small=medium
  verified: 2026-09-23 against the Claude API model list, and by probing the delegate aliases in Claude Code 2.1.280: opus ran claude-opus-5-5, sonnet ran claude-sonnet-5, haiku ran claude-haiku-4-5-20251001 (Opus 5.5 default effort is medium, so always set it; Haiku 4.5 rejects effort)
codex:
  command: cd {cwd} && codex exec --sandbox read-only -C {cwd} -m {model} -c model_reasoning_effort={effort} -o {out} < {prompt}
  write-command: cd {cwd} && codex exec --sandbox workspace-write -C {cwd} -m {model} -c model_reasoning_effort={effort} -o {out} < {prompt}
  models: gpt-6-astra gpt-6-sol gpt-6-luna gpt-5.6-sol gpt-5.6-terra gpt-5.6-luna gpt-5.5
  efforts: low medium high xhigh
  budget: unlimited=xhigh large=xhigh medium=high small=medium
  unavailable: rate.?limit|insufficient_quota|quota|429|401|unauthorized|overloaded|capacity
  verified: 2026-09-23 from ~/.codex/models_cache.json; xhigh confirmed by the user's config.toml
mini:
  command: cd {cwd} && node ~/workspace/mini-agent/dist/agent.js -p --model {model} --effort {effort} --output-format json < {prompt} > {out}
  write-command: cd {cwd} && MINI_AGENT_AUTO_APPROVE=1 node ~/workspace/mini-agent/dist/agent.js -p --model {model} --effort {effort} --output-format json < {prompt} > {out}
  models: deepseek-flash deepseek-v4-pro
  efforts: none low high max
  budget: unlimited=max large=max medium=high small=low
  unavailable: rate.?limit|insufficient|quota|429|401|invalid api key|ECONNREFUSED|ENOTFOUND
  verified: 2026-09-23 against api-docs.deepseek.com and mini-agent src/effort.ts
```

`mini` fills the `chore` seat only. It never fills a seat that reads code to decide (explore, judgment, adversarial). Its print mode declines every approval unless `MINI_AGENT_AUTO_APPROVE=1` is set, which `write-command` does; hard denies in mini-agent still apply.

A runner with `host:` and no `command` is native: the host spawns it itself (`hosts.md`). `models` lists the model IDs verified for that runner and, for claude, maps the short versioned name to the full ID for hosts and agent definitions that take one. `no-effort` names models that reject an effort setting. `verified` records when and against what the list was checked; re-check it when a provider ships a model. `aliases` maps it to the short alias a delegate tool accepts; when the host only takes an alias, the reply records the version that was requested and the alias that ran, because the alias may resolve to a different version than intended. A native runner's `@effort` applies where the host can set effort per delegate (an agent definition's `effort` field, or the session's effort when the parent does the work itself); where it cannot, the chain's effort is recorded in the reply as requested but not enforced. Any other runner is external and runs through `scripts/runner.sh`, which expands the template, enforces a timeout, and classifies the outcome as `OK`, `UNAVAILABLE <reason>`, `FAILED`, or `TIMEOUT`.

## Prompts for external runners

An external runner has no chat context and no skill catalog. Its prompt is self-contained:

- The filled template (reviewer prompt, investigator prompt, delegate brief) with every referenced skill body inlined or named by absolute path (`~/workspace/astack/skills/test-quality/SKILL.md`), never by skill name.
- For a code seat, the `agents/astack-agent.md` contract prepended verbatim. For a chore seat, the collapsed brief (GOAL, SCOPE, VERIFY, REPORT) and the exact commands it may run.
- The working directory it must stay inside, and the output file it must write.

Write the prompt to a file under the scratchpad. Never put it on the command line.

## Fallback rules

1. Try the chain left to right. Move on when the runner reports `UNAVAILABLE` or `TIMEOUT`, or when a native spawn fails to start. `FAILED` with output is a result, not a fallback: read it.
2. `parent` always works, so a seat is never empty. When even `parent` cannot do the job (the host has no delegation), the seat is BLOCKED and the report says so. BLOCKED is not a pass.
3. Every fallback appears in the reply, one line each: `reviewer B: codex unavailable (429), ran on parent`. A silent downgrade is fabricated evidence.
4. When a panel seat falls back onto a model family another seat already uses, say so and weight agreement between those seats as one family, not two.
5. Do not retry an `UNAVAILABLE` runner inside the same task. Note it and move on. `setup-astack` re-probes on demand.
6. The author of a diff never fills a seat that judges it, on any host.
