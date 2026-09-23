### Pause safely

**You own a clean stop. Leave a checkpoint a cold-start agent can resume from.** Explicit only. On "keep going" or "do not stop", do not pause.

1. Stop at a safe boundary. Finish the current atomic step or back out of it. Start nothing new. Cancel nested subagents.
2. Take no irreversible action to pause. No PR and no push unless one was already out.
3. Make the work durable. Commit uncommitted edits as one `wip:` commit on the current branch. If the tree is broken, say so in one line of the commit body.
4. Write the resume note off-context: intent, what you were doing, progress and what is verified, current state, next steps, key files, gotchas. Put it at `<scratchpad>/<slug>-resume.md` or point at the existing decision log instead of duplicating it.

**Reply:** where you are in the loop, what is on disk versus still in your head (paths, no diff dumps), the commits made and whether the tree is clean, and the first action on resume. This is a pause, not a final report.
