# Hosts

astack runs under Claude Code, Codex, or mini-agent. Skills use host-neutral words (spawn a delegate, invoke a skill, wake on an event, this session's transcript) and this table says what each means where you are.

## Which host am I on

- You have tools literally named `Agent` and `Skill`: Claude Code.
- Skills are invoked as `$name` and you were started by `codex`: Codex.
- Your tools are `run_bash`, `read_file`, `search`, `task`, `skill`: mini-agent.

State the host in the task's first line, and add "under orca" when `ORCA_RUN` is set (see Under orca). When in doubt, treat the host as `parent`-only: no native delegation, external runners through `scripts/runner.sh`.

## The mapping

| action | Claude Code | Codex | mini-agent |
|---|---|---|---|
| spawn a read-only delegate | Agent tool, `subagent_type: general-purpose` or `Explore`, `model` from the role, `run_in_background: true`, read-only by instruction | `codex exec --sandbox read-only -C <dir>` through `scripts/runner.sh`, or the built-in review delegation | `task` tool with `subAgentModel` from the role, or `scripts/runner.sh` with the `mini` runner |
| spawn a code delegate | Agent tool, `subagent_type: astack-agent` (`astack:astack-agent` as a plugin), `isolation: "worktree"` | `scripts/runner.sh --write` in the worktree (the `codex` runner's `write-command`, `--sandbox workspace-write`), the `astack-agent.md` contract prepended | `spawn_teammate` or `task` in the worktree with `MINI_AGENT_AUTO_APPROVE=1` and a project deny list, contract prepended |
| spawn a chore delegate | Agent tool, `subagent_type: general-purpose`, `model` from the chore role, `isolation: "worktree"` when it writes | `scripts/runner.sh` with the chore role's runner, `--write` when it edits files | same, or `task` with `subAgentModel` from the chore role |
| invoke a skill | Skill tool, `astack:<name>` as a plugin or `<name>` when symlinked | `$<name>` | `skill` tool, or `/skill <name>` |
| run an external runner | `scripts/runner.sh` from Bash | same | same, from `run_bash` |
| wake on an event | `Monitor` for a stream, `ScheduleWakeup` for a heartbeat, `/loop` for a recurring prompt | a shell loop around `gh pr checks --watch` or `sleep`, one wake per iteration | `cron` tool or a background bash loop |
| this session's transcript | `~/.claude/projects/<slug>/*.jsonl`, `<slug>` is the workspace path with `/` replaced by `-` | `~/.codex/sessions/<year>/...` | `.mini-agent/sessions/` in the project |
| the parent runner | the session model | the session model | the configured `model` |
| install the skills | `--plugin-dir ~/workspace/astack`, or symlink `skills/*` into `~/.claude/skills/` and `agents/*.md` into `~/.claude/agents/` | symlink `skills/*` into `~/.codex/skills/` | symlink `skills/*` into `~/.config/mini-agent/skills/` |

## Under orca

[orca](https://github.com/ftfw0621/orca) runs Claude Code, Codex, and mini-agent as long-lived sessions a human can attach to, and gives this skill a task graph. You are under orca when `ORCA_RUN` is set in your environment; you are then the run's brain, and the host table above still says what your own tools are. Under orca, every delegate and every external runner goes through `orca task`, code delegates included. Do not use the host's own delegate tool (the Agent tool on Claude Code, its worktree isolation included) or `scripts/runner.sh`: work done there is invisible to orca, skips its seat rules, and cannot be watched or approved in `orca tui`. Do not edit files yourself either; the brain reads, decides, and approves.

| action | under orca |
|---|---|
| spawn a read-only delegate | `orca task add --role explore --brief <file>` |
| spawn a code delegate | `orca task add --role code --write --brief <file>`; orca makes the worktree |
| spawn a chore delegate | `orca task add --role chore --brief <file>`, with `--write` when it edits files |
| a judging seat | `--judges <task>`; orca keeps that task's author off the seat and runs the judge in its worktree |
| a panel seat | `orca task add --role adversarial --seat <n>`, one task per seat |
| an order between delegates | `--deps <task>,<task>` |
| wait for a delegate | `orca task wait <task>`; it returns within nine minutes, so run it again while it reports `timedOut` |

What `task wait` returns decides the next step:

- `done`: read the file at `report`, then read the delegate's diff in `cwd`. You own its work, as with any delegate.
- `blocked`: the delegate is waiting on a tool approval; `note` says which tool and arguments. Decide as the reviewer of that action: `orca agent approve <agent> allow`, or `deny --reason <why>`. Deny anything outside the brief's SCOPE or FORBIDDEN list.
- `needs_input`: the delegate stopped without a report; `note` is its last reply. Answer it with `orca agent send <agent> --text <answer>` and wait again, or `orca task cancel <task>`.
- `unavailable`: every runner in the role's chain is out of quota or excluded; do the work yourself (the `parent` runner) and say so in the reply.
- `failed`: `note` says why (a dependency did not finish, the directory is not a git repository). Treat it as a result, not a pass.

orca fills seats from the same `models.md` and `runners.md` this skill reads, records every fallback in the task's `attempts`, and never lets a delegate's author fill a seat that judges it. `orca task list` shows the run so far; the human watches it with `orca tui`.

The brain is Claude Code or Codex (`runners.md`, Under orca). A Codex brain is pointed at this skill's `SKILL.md` instead of invoking it, and runs in a sandbox that lets it write to the run's directory without approval; it still edits nothing. When a brain runs out of quota, orca starts the next one with a handover: the goal, why the last brain stopped, and every task with its status, runner, agent, and report. A brain that receives one reads the reports of finished tasks, does not repeat them, waits on the unfinished ones, and decides the blocked ones.

## Rules that hold on every host

- A delegate that writes code gets its own worktree. Two writers never share one.
- A read-only delegate is read-only by mechanism where the host has one (sandbox, permission gate) and by instruction everywhere.
- Skill bodies refer to files relative to their own directory (`playbooks/`, `references/`). A host that hands a skill body to the model without its directory must prepend `Skill directory: <path>` so those references resolve.
- External runners get absolute paths, never skill names (`runners.md`).
