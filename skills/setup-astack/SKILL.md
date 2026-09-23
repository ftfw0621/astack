---
name: setup-astack
description: Choose which model astack uses for each role and write ~/.claude/astack-models.md. Use for /setup-astack or "configure astack models".
disable-model-invocation: true
---

# Setup astack

Write `~/.claude/astack-models.md`, the file the `astack` router reads at task start. One line per role. A missing line keeps the default.

## Steps

1. **Detect.** The models the Agent tool accepts in this session (read its `model` parameter), the parent model, and whether `command -v codex` succeeds. Never write a model you have not confirmed.
2. **Load current state.** Read the file if it exists and treat its lines as the current choices. Otherwise start from the defaults.
3. **Ask** with one structured question per role that the user wants to change, offering the detected models plus `parent` (run that role on the parent model). Roles:

   | role | default | used for |
   |---|---|---|
   | judgment | `opus`, else `parent` | design pick, review verdict, dismissals, synthesis |
   | code | `sonnet` | delegate edits |
   | explore | `haiku` | read-only fan-out |
   | adversarial | `opus` plus `codex` when installed | interrogate reviewers, cross-judges |

   A panel role (`adversarial`) takes a list. One reviewer runs per entry.
4. **Validate.** Every model written is in the detected set or is `parent` or `codex`.
5. **Write** the whole file, so re-runs stay idempotent:

   ```
   # astack model roles. One line per role. Delete a line to restore the default.
   judgment: opus
   code: sonnet
   explore: haiku
   adversarial: opus, codex
   ```

6. **Confirm.** Tell the user the file was written and applies from the next task.

**Reply:** the file contents and which roles differ from the defaults.
