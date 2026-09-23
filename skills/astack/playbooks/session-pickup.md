### Session pickup

**You own the resume point. Read the prior trail, do not redo it.**

1. Locate the prior trail: a transcript under `~/.claude/projects/<slug>/` (the workspace path with `/` replaced by `-`; read only this workspace), a decision log, or a pushed branch. Read the last messages first, then scan back for the decision points. Parse a long transcript in an explore-role subagent and keep the reduced timeline in the main thread (`guard-the-context-window`).
2. Reconstruct operational state: branch and worktree, what landed (`git log`, `git diff <base>`), open todos, decisions made. The prior trail is authoritative input. Resist re-deriving it.
3. Diff done versus pending. Name the resume point. Do not re-run the prior repro or redo completed work. A "verify from scratch" pass treats the trail as untrustworthy when it is authoritative.
4. Route the remaining work to its playbook and pick the verdict: continue, ship a finished recommendation, ratify or override a prior conclusion, or postmortem a failed run. This playbook ends here.
5. Verify the inherited claims against the original goal on the real artifact (`prove-it-works`). A prior self-report is not proof.

**Reply:** where the prior agent stopped, what you inherited versus redid (ideally nothing), the resume point, the outcome.
