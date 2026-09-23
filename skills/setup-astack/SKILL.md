---
name: setup-astack
description: Detect the host and the available runners, probe each, and write the astack role chains and runner registry under ~/.config/astack/. Use for /setup-astack or "configure astack models".
disable-model-invocation: true
---

# Setup astack

Write `~/.config/astack/models.md` (role chains and budget) and `~/.config/astack/runners.md` (how each runner is invoked). The `astack` router reads both at task start. Syntax and defaults: the router's `references/runners.md`.

## Steps

1. **Detect the host** per the router's `references/hosts.md` and say which it is.
2. **Detect runners.**
   - `claude`: native when the host is Claude Code (list the models its delegate tool accepts).
   - `codex`: `command -v codex` succeeds. Read its default model and effort from `~/.codex/config.toml` (`model`, `model_reasoning_effort` lines only).
   - `mini`: `~/workspace/mini-agent/dist/agent.js` exists, or a `mini-agent` binary is on PATH. Its effort levels for `deepseek-flash` are `none low high max`.
   - `parent`: always.
   Never write a runner you did not detect.
3. **Load current state.** Read both files if they exist and treat their lines as the current choices. Otherwise start from the router's defaults.
4. **Probe each external runner once** with a one-line prompt ("Reply with the single word ready.") through `scripts/runner.sh` in a scratch directory, `--timeout 120`. Record `OK`, `UNAVAILABLE <reason>`, `FAILED`, or `TIMEOUT` per runner. A runner that is not `OK` stays in the registry but the user is told, and chains that start with it will fall through until it recovers.
5. **Ask** the user, one structured question at a time, only for what they want to change: the budget (`unlimited`, `large`, `medium`, `small`) and any of the five role chains (judgment, hardest, code, explore, adversarial). Offer only detected runners plus `parent`. For `adversarial`, the value is a list of seats; one reviewer runs per seat. Do not put the same model family in two seats unless the user asks.
6. **Validate.** Every runner in every chain is detected. Every `@effort` is in that runner's `efforts` list. `parent` closes every chain.
7. **Write both files** in full, so re-runs stay idempotent. Keep the user's runner command overrides; only add blocks for newly detected runners.
8. **Confirm.** Show both files, the probe results, and which roles differ from the defaults. The change applies from the next task.

**Reply:** the host, the probe table (runner, status, latency), both files, and the roles that differ from the defaults.
