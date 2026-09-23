# Hosts

astack runs under Claude Code, Codex, or mini-agent. Skills use host-neutral words (spawn a delegate, invoke a skill, wake on an event, this session's transcript) and this table says what each means where you are.

## Which host am I on

- You have tools literally named `Agent` and `Skill`: Claude Code.
- Skills are invoked as `$name` and you were started by `codex`: Codex.
- Your tools are `run_bash`, `read_file`, `search`, `task`, `skill`: mini-agent.

State the host in the task's first line. When in doubt, treat the host as `parent`-only: no native delegation, external runners through `scripts/runner.sh`.

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

## Rules that hold on every host

- A delegate that writes code gets its own worktree. Two writers never share one.
- A read-only delegate is read-only by mechanism where the host has one (sandbox, permission gate) and by instruction everywhere.
- Skill bodies refer to files relative to their own directory (`playbooks/`, `references/`). A host that hands a skill body to the model without its directory must prepend `Skill directory: <path>` so those references resolve.
- External runners get absolute paths, never skill names (`runners.md`).
