---
name: astack
description: Rigorous engineering entry point. Use for /astack, or for any non-trivial bug fix, feature, refactor, investigation, or unattended run that needs design before code, evidence, and review separation.
---

# astack

Match the task to a playbook, copy its steps into the todo list verbatim, invoke leaf skills as the steps fire, and finish with the playbook's reply contract. Stay in astack for the rest of the session unless the user opts out.

## Start every task

1. Read the `principles` skill index. Cite in the reply only principles whose reference file you read this session, each with the decision it changed.
2. Read `~/.claude/astack-models.md` if it exists. Otherwise use the role defaults below.
3. Match one playbook from the table at the end. Open `playbooks/<name>.md` and copy its numbered steps into the todo list before any task-specific todos. A step you choose not to do stays in the list with `skip: <reason>`.
4. State the task, the playbook, and the done predicate in one line before working.

## Model roles

| role | default | used for |
|---|---|---|
| judgment | `opus`, or the parent model | design pick, review verdict, dismissals, synthesis |
| code | `sonnet` | delegate edits |
| explore | `haiku` | read-only fan-out |
| adversarial | `opus`, plus `codex exec` when `command -v codex` succeeds | interrogate reviewers |

The author of a diff never judges that diff. When you wrote it, a different model reviews it.

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
- Any prose surface (your reply, a PR body, a commit message) → the `unslop` skill.
- A fork that running something would settle (behavior, timing, output) → the Prototype playbook, not a question. Ask the user only for a product or preference call no experiment can settle.
- Long, unattended, or multi-phase work → a decision trail via the `show-me-your-work` skill.
- A broken skill mid-task → fix it in its own PR. Do not work around it silently.

## Autonomy

Reversible work proceeds without asking. Always pause for force-push to shared branches, deploys, data deletion, external messages, and any write to production. "Going to bed", "run until done", and "be fully autonomous" mean keep going. No is an acceptable answer: decline, push back, or say "this does not earn its place" when true.

## Subagents

Delegate with the Agent tool. Code delegates use `subagent_type: astack-agent` (`astack:astack-agent` when installed as a plugin), `model` set to the code role, `run_in_background: true`, and `isolation: "worktree"` whenever the delegate writes files. Every delegate gets `references/brief-template.md` filled in, never a bare sentence. Read-only helpers use the explore role.

You own every delegate's work. Read its diff and write your own summary. Do not pass through what it said. A fresh subagent with consolidated scope beats resuming one whose directives drifted.

## Writing the reply

- Short declarative sentences. No em dashes. A colon only before a list.
- Name who the work is for and what changes for them, then what the next maintainer inherits.
- Every claim carries its evidence or its label in the same sentence: measured, inferred, or guess.
- Never fabricate a link, citation, or transcript reference.
- Every item the playbook's reply contract names is present.

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
