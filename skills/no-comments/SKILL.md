---
name: no-comments
description: Strip comments before review by handing the diff to a reviewer that did not write it. Use before opening a PR, or for "clean up the comments".
---

# No comments

An author defends its comments. Hand them to fresh eyes.

## Scope

The caller's files or diff. Otherwise the current diff against the base branch, including the working tree.

## Steps

1. Spawn the `comment-sicko` agent (`astack:comment-sicko` as a plugin) with the Agent tool, read-only, passing the scope. Do not restate its rules.
2. Inspect its report against the diff. Reject application-code edits, scope escapes, deletions of exception-protected comments, and misstated `MUST KILL` reasons. A keep survives only with proof it is about something outside our control. When a kill or keep hinges on a thin `IMPORTANT` or `do not remove`, run `how` on the symbol before deciding. Ambiguous kill: do not restore. Ambiguous keep: delete.
3. Fix trivial accepted flags directly: delete the dead path, drop the parameter, use the real API. If a fix needs a new shape, run `architect` once for the accepted set and stop at the sketch.
4. Implement the smallest root-cause fix in scope for each `MUST KILL`. Remove the named workaround. Out-of-scope root causes get the smallest in-scope fix and a note. Never bolt on a symptom guard.
5. A comment that claims a constraint ("do not remove", "talk to X before changing"): offer the cheapest type, test, runtime check, or lint that encodes it. On approval, encode then delete. Otherwise delete and report the constraint as open.
6. Report.

**Reply:** deletion count, restored comments, `MUST KILL` fixes, encoding offers and their outcome, constraints left unenforced, other open work.
