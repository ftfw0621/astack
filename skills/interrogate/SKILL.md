---
name: interrogate
description: Adversarial multi-model review of a diff. Use for /interrogate, "review this", "tear this apart", "find blind spots", or before shipping a contested or risky change. Reviewers on different models try to break it; a lead sorts the findings.
---

# Interrogate

Spawn one reviewer per model and have each try to break the change from the same prompt and rubric. The signal comes from model diversity, not assigned personas. The deliverable is a synthesized verdict. Do not auto-apply changes.

## 1. Scope

Use the files or diff the user points at. On a branch, `git diff <base>...HEAD`. Package the diff plus the surrounding files a reviewer needs.

## 2. Intent

Write one paragraph stating what the change is for, derived from the user's message, commit messages, the PR body, and the code. If unsure, ask before spawning.

## 3. Spawn reviewers

One reviewer per seat of the `adversarial` role (default seats: `claude:opus`, `codex:gpt-6-astra@xhigh`, `mini:deepseek-flash@max`). Launch them all at once. A native seat is a read-only delegate spawned as the router's `references/hosts.md` says. An external seat runs through `scripts/runner.sh` with the filled prompt in a file, the diff's worktree as `cwd`, and the seat's model and effort. A seat whose runner is unavailable falls through its chain per `references/runners.md`, and the verdict names the fallback.

Never include the model that wrote the diff. When only one model family remains, still run two reviewers on different models and say so in the verdict.

Build each prompt from `references/reviewer-prompt.md` with the intent, the diff, `references/rubric.md`, and the body of the `code-quality` skill as the code-quality lens. Every reviewer gets the same filled prompt.

## 4. Synthesize

Parse all findings. Findings raised independently by two or more reviewers are highest signal. Deduplicate findings described differently. Note explicit disagreements.

## 5. Lead judgment

You are the lead reviewer, a pragmatic senior engineer, not an aggregator. Read `references/lead-judgment.md`. Sort every finding:

- **Act on.** Real correctness, security, or maintainability issues given the goals. Would block a real PR.
- **Consider.** Legitimate, but the cost of addressing it now is unclear.
- **Noted.** Valid but not actionable now.
- **Dismissed.** Wrong, nitpicky, or missing context, with a one-line reason.

More than five items under Act on means you are not filtering. Dismissals are a trust mechanism, not busywork.

**Reply:** Intent, Reviewers (model and finding count each), Act on, Consider, Noted, Dismissed, and an Agreement map saying where reviewers agreed and diverged and what that pattern tells you.
