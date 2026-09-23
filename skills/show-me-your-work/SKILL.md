---
name: show-me-your-work
description: A reviewable decision trail for long or unattended work, one TSV row per decision with evidence. Use for autonomous runs, multi-phase work, or anything a human reviews after stepping away.
---

# Show me your work

Keep one canonical log.

## The format

A single TSV, one row per decision, cells single-line, evidence as a pointer not prose. Copy `references/decision-log-template.tsv` to start. Columns:

- **ts.** ISO 8601 timestamp.
- **phase.** The phase or workstream.
- **decision.** What was chosen or done, one line.
- **why.** The reason in plain words.
- **evidence.** A commit SHA, PR number, `file:line`, or artifact path. Never a paragraph.
- **result.** `tests green`, `reverted`, `diff 0`, `INCONCLUSIVE`, `open`.

```
ts	phase	decision	why	evidence	result
2026-05-24T09:40:00Z	harness	captured baseline screenshots before changing anything	so old and new can be diffed	scripts/snapshot.sh, baseline/	120 reference screenshots saved
2026-05-24T12:30:00Z	widget	threw out a delegate's work because its screenshots were blank	checked the real files instead of its summary	worktree reset	reverted, tightened the brief
```

## Logging a row

Use `scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>` from the astack repo. It stamps `ts`, writes the header on first use, strips stray tabs and newlines, and prefixes a cell starting with `=`, `+`, `-`, or `@` with a quote so a spreadsheet never executes it.

Log decision points and checkpoints, not every action: a fork chosen, a unit completed with its result, a pivot or revert with its trigger, a blocker, a gate fixed. One row per iteration in a loop. Write rows through the `unslop` skill.

## Where it lives

`decisions.tsv` in the work directory, or `.audit/<task-slug>.tsv` when several efforts share one. Out of git by default. Commit it only when a reviewer needs the trail to trust the result.

## Rules

Append-only. A wrong call gets a new row that supersedes it. Prefer evidence produced by committed scripts over one-off hand checks (`encode-lessons-in-structure`).

## Audit the log before handing back

Read this run's transcript under `~/.claude/projects/<slug>/` (the workspace path with `/` replaced by `-`). Only this workspace's transcripts. Walk the log against what happened: every row maps to a real action, every evidence pointer resolves, every fork or revert that shaped the work is logged, padding is cut. Fix the log, not the story.

Then spawn a reviewer on a model different from the one that did the work to read the trail and the transcript and flag what the user should look at: decisions with weak evidence, verification claimed without proof, choices that look risky in hindsight, gaps a skim would miss.

**Reply:** ends with an Attention section, first line `reviewed by <model>`, then each flag pointing at a row or moment. "No flags" is valid. The model name is not.
