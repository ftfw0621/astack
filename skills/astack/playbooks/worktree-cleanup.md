### Worktree cleanup

**You own the disk and the safety gate.** Prune merged or abandoned git worktrees to reclaim space. Deletion is irreversible, so every step guards against deleting something in use or holding uncommitted work.

1. Snapshot and audit. Record `df -h .`, then run `scripts/worktree-audit.sh` from the astack repo inside the target repository (`build-the-lever`). It reads paths from `git worktree list`, never hand-typed, classifies each worktree by size, age, merge state, uncommitted work, PR state, and the newest Claude Code transcript that touched it, and suggests a bucket.
2. The bucket is advice, not permission. Ask the user which worktrees are pinned or active. A worktree another live session is using is in use even when nothing in the audit says so: check `ps aux` for processes whose working directory is under the worktree root.
3. Verify usage before deleting. For every `verify-recent-chat` row, read the transcript (explore-role subagent) and report whether that session is ongoing.
4. Pause on irreversible loss. `wip:N` means N tracked uncommitted edits: show the diff and get a decision. `scratch:N` is untracked throwaway, safe to drop, but name the files. Clean, merged, and not in use proceeds. `wip` and in-use pause.
5. Prune the confirmed set. Build caches often leave read-only files that make removal fail while looking like it worked, so run `chmod -R u+w <path>` first, then `git worktree remove --force <path>`, then `git worktree prune`. Verify with `ls` on the path, not only `git worktree list`. Tag any detached HEAD that no branch contains (`git tag archive/<topic> <sha>`) before removal so nothing is garbage-collected. Confirm with `df -h .`.
6. Other reclaimers, only caches the user has not said to keep: build sandboxes, package caches, simulator runtimes.

This is the one playbook that deletes user state with no code review to catch a slip. The gates above are the review.

**Reply:** `df -h` before and after with space reclaimed, the worktrees pruned, and a one-line reason for each held back.
