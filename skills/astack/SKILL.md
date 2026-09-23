---
name: astack
description: Rigorous engineering entry point. Use for /astack, or for any non-trivial bug fix, feature, refactor, investigation, or unattended run that needs design before code, evidence, and review separation.
---

# astack

Match the task to a playbook, copy its steps into the todo list verbatim, invoke leaf skills as the steps fire, and finish with the playbook's reply contract. Stay in astack for the rest of the session unless the user opts out.

## Start every task

1. Name the host you are on per `references/hosts.md` (Claude Code, Codex, mini-agent). Every "spawn a delegate", "wake", and "transcript" below means what that table says.
2. Read the `principles` skill index. Cite in the reply only principles whose reference file you read this session, each with the decision it changed.
3. Read `~/.config/astack/models.md` and `~/.config/astack/runners.md` if they exist. Otherwise use the defaults below. `references/runners.md` defines the syntax, the fallback rules, and how external runners are invoked.
4. Match one playbook from the table at the end. Open `playbooks/<name>.md` and copy its numbered steps into the todo list before any task-specific todos. A step you choose not to do stays in the list with `skip: <reason>`.
5. State the host, the task, the playbook, and the done predicate in one line before working.

## Roles

A role is a seat filled by a runner chain, tried left to right. `parent` is the host's own model and is always last.

| role | default chain | used for |
|---|---|---|
| judgment | `claude:opus-5-5@max > codex:gpt-6-astra@xhigh > parent` | design pick, review verdict on every delegate diff, dismissals, synthesis of a panel |
| hardest | `claude:opus-5-5@xhigh > parent` | investigation before the cause is confirmed, the `how` explainer and `why` synthesizer, the hardest code: cross-cutting design, concurrency, subtle algorithms |
| code | `codex:gpt-6-astra@high > claude:sonnet-5 > parent` | delegate edits once shape, usage, and acceptance are written; bug fixes once the cause is confirmed and the fix is planned |
| explore | `claude:haiku-4-5 > codex:gpt-6-astra@low > parent` | read-only fan-out |
| chore | `mini:deepseek-flash@max > claude:haiku-4-5 > parent` | ad hoc tasks: who last touched this file, a PR deleting or renaming a file, a version bump, run a script and report |
| adversarial | `claude:opus-5-5@max, codex:gpt-6-astra@xhigh` | interrogate seats, cross-judges, one reviewer per seat |

The code role never receives a task whose cause or shape is still open. That work is `hardest` until the brief can be filled. A chore has a one-paragraph spec, a mechanical done-check (a command's output, a PR URL, a file gone), and nothing decided by reading code. Anything that needs the code understood is `explore` or higher.

A runner that is unavailable (quota, auth, capacity, timeout) falls through to the next. Every fallback is named in the reply. The author of a diff never fills a seat that judges it.

## Triggers

- Nontrivial change, architecture decision, or "are we sure?" → the `how` skill first. A motivation question ("why is it like this") → the `why` skill.
- Any code → name the data shape and its organizing structure before logic (`model-the-domain`).
- Code crossing a function boundary → the `architect` skill.
- Several valid shapes for the same change → the `arena` skill.
- Contested design, or a risky diff before the PR → the `interrogate` skill.
- Concurrency, retries, distributed state, money arithmetic, or compliance-critical decisions → the `formal-verification` skill's triage before the design is fixed. Its outcome (tests, TLA+, Lean) becomes a step in the playbook.
- Editing `.go`, `.py`, `.ts`, or `.tsx` → the matching `go-practices`, `python-practices`, or `typescript-practices` skill loads on its own. Cite its rule names in review.
- Every new or changed test → the `test-quality` skill, then `scripts/test-smells.sh` on the test files.
- Before review → the `no-comments` skill, then `scripts/code-smells.sh` on the diff.
- Any prose surface (your reply, a PR body, a commit message) → the `unslop` skill. Docs, PR bodies, and commit messages also go through the `technical-writing` skill first.
- A fork that running something would settle (behavior, timing, output) → the Prototype playbook, not a question. Ask the user only for a product or preference call no experiment can settle.
- Long, unattended, or multi-phase work → a decision trail via the `show-me-your-work` skill.
- A broken skill mid-task → fix it in its own PR. Do not work around it silently.

## Autonomy

Reversible work proceeds without asking. Always pause for force-push to shared branches, deploys, data deletion, external messages, and any write to production. "Going to bed", "run until done", and "be fully autonomous" mean keep going. No is an acceptable answer: decline, push back, or say "this does not earn its place" when true.

## Delegates

Spawn delegates as `references/hosts.md` says for your host. Every code delegate gets `references/brief-template.md` filled in, never a bare sentence, and its own worktree. A read-only delegate is read-only by mechanism where the host has one and by instruction everywhere. An external runner (`codex`, `mini`) gets a self-contained prompt with absolute paths, run through `scripts/runner.sh` (`--write` for a seat that edits files), and its status line (`OK`, `UNAVAILABLE`, `FAILED`, `TIMEOUT`) decides whether the chain moves on.

You own every delegate's work. Read its diff and write your own summary. Do not pass through what it said. A fresh delegate with consolidated scope beats resuming one whose directives drifted.

## Writing the reply

- Short declarative sentences. No em dashes. A colon only before a list.
- Name who the work is for and what changes for them, then what the next maintainer inherits.
- Every claim carries its evidence or its label in the same sentence: measured, inferred, or guess.
- Never fabricate a link, citation, or transcript reference.
- Every item the playbook's reply contract names is present, plus one line per runner fallback.

## Comments

Keep a comment only for a non-obvious why the code cannot show. No phase narration, no banners, no commented-out code. This applies to delegate diffs too.

## Playbooks

| playbook | for | file |
|---|---|---|
| Investigation | a read-only question: how does X work, why Y, are we sure about Z | `playbooks/investigation.md` |
| Bug fix | a defect to reproduce, root-cause, and fix with runtime evidence | `playbooks/bug-fix.md` |
| Feature | new or changed behavior, built from a named data shape | `playbooks/feature.md` |
| Refactoring | a behavior-preserving change to structure | `playbooks/refactoring.md` |
| Prototype | a throwaway sketch that settles a design or behavioral fork | `playbooks/prototype.md` |
| Perf issue | a measured slowness to trace and fix against a baseline | `playbooks/perf-issue.md` |
| Hillclimb | sustained improvement of one metric, one hypothesis per iteration | `playbooks/hillclimb.md` |
| Autonomous run | a long task driven to a predicate without stopping | `playbooks/autonomous-run.md` |
| Babysit | drive a PR to merge-ready: conflicts, threads, CI, bot triage | `playbooks/babysit.md` |
| Multi-phase plan | work spanning several PRs, delivered as an evidence checklist | `playbooks/multi-phase-plan.md` |
| Session pickup | resume or take over a prior agent's in-flight work | `playbooks/session-pickup.md` |
| Pause safely | suspend cleanly so a cold-start agent can resume | `playbooks/pause-safely.md` |
| Worktree cleanup | reclaim disk from merged or abandoned worktrees, safety-gated | `playbooks/worktree-cleanup.md` |
| Authoring a skill | writing or editing a SKILL.md in this stack | `playbooks/authoring-a-skill.md` |
| Opening a PR | invoked at the end of every code playbook | `playbooks/opening-a-pr.md` |

A large or cross-cutting effort, or work the user steps away from to trust later, routes to the `figure-it-out` skill even when a narrower playbook fits. A task no playbook fits also goes there.
