---
name: interrogate
description: Adversarial multi-model review of a diff on three axes: the originating spec, the repo's documented standards, and everything else. Use for /interrogate, "review this", "tear this apart", "find blind spots", or before shipping a contested or risky change.
---

# Interrogate

Spawn one reviewer per model and have each try to break the change from the same prompt and rubric. The signal comes from model diversity, not assigned personas. The deliverable is a synthesized verdict. Do not auto-apply changes.

## 1. Scope

Use the files or diff the user points at. On a branch, `git diff <base>...HEAD`. Package the diff plus the surrounding files a reviewer needs.

## 2. Intent, spec, standards

Write one paragraph stating what the change is for, derived from the user's message, commit messages, the PR body, and the code. If unsure, ask before spawning.

Find the originating spec, in this order: ticket or issue IDs in the commit messages and PR body (fetch them), a path the user passed, a spec under `docs/` or `specs/` matching the branch. Nothing found: ask once. The user says there is none: the Spec axis reports `no spec available`.

Collect the repo's documented standards: every `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, or `CODING_STANDARDS.md` on the path from the repo root to each changed directory. A rule tooling already enforces is skipped.

## 3. Spawn reviewers

One reviewer per seat of the `adversarial` role (default seats: `claude:opus-5-5@max`, `codex:gpt-6-astra@xhigh`). Launch them all at once. A native seat is a read-only delegate spawned as the router's `references/hosts.md` says. An external seat runs through `scripts/runner.sh` with the filled prompt in a file, the diff's worktree as `cwd`, and the seat's model and effort. A seat whose runner is unavailable falls through its chain per `references/runners.md`, and the verdict names the fallback.

Never include the model that wrote the diff. When only one model family remains, still run two reviewers on different models and say so in the verdict.

Build each prompt from `references/reviewer-prompt.md` with the intent, the spec, the standards files, the diff, `references/rubric.md`, and the body of the `code-quality` skill as the code-quality lens. Every reviewer gets the same filled prompt.

## 4. Synthesize

Parse all findings. Findings raised independently by two or more reviewers are highest signal. Deduplicate findings described differently. Note explicit disagreements. Keep the three axes apart: a change can meet every standard and build the wrong thing, or do exactly what the ticket asked and break the repo's conventions, and merging the lists lets one axis hide the other. Never rerank across axes.

## 5. Lead judgment

You are the lead reviewer, a pragmatic senior engineer, not an aggregator. Read `references/lead-judgment.md`. Sort every finding:

- **Act on.** Real correctness, security, or maintainability issues given the goals. Would block a real PR.
- **Consider.** Legitimate, but the cost of addressing it now is unclear.
- **Noted.** Valid but not actionable now.
- **Dismissed.** Wrong, nitpicky, or missing context, with a one-line reason.

More than five items under Act on means you are not filtering. Dismissals are a trust mechanism, not busywork.

**Reply:** Intent, the spec and standards sources used, Reviewers (model and finding count each), then Act on, Consider, Noted, Dismissed, each split by axis (Spec, Standards, Other), and an Agreement map saying where reviewers agreed and diverged and what that pattern tells you.
