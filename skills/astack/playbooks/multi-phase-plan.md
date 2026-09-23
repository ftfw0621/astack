### Multi-phase or multi-PR plan

**You own the plan, not the code. The plan is a checklist an owner runs box by box and a reviewer audits from the evidence.** The plan is the deliverable. Do not implement.

1. When the change is one or two files with an obvious approach, skip the plan. Say so and stop.
2. Settle open questions by prototype before you write (Prototype playbook). Keep the branch, the SHA, and the evidence for Appendix A. Ask the user only about a product or preference call no run can settle.
3. Explore in explore-role subagents. Each returns file pointers, conventions, test commands, entry points. No inlined dumps.
4. Copy the skeleton below into the plan file (under the scratchpad or a path the user names) and fill every placeholder. One section per PR. One PR is one change with its own evidence (`sequence-verifiable-units`).
5. Write it with `technical-writing` (how-to mode in the body, explanation in the appendices), then `unslop`.
6. Run `node scripts/check-plan.mjs <plan.md>` from the astack repo and fix every line it prints.
7. Hand back the plan path and the script's output, then stop. Execution starts on the user's explicit go.

**Verification rule.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Every Verify block opens with that sentence. Live means driving the real surface (a running service, the CLI, the UI). Perf, when it applies, names the metric, the probe run at base and head, the baseline first, and the number that fails.

````markdown
# <Program> plan

<Under ten lines. What changes, for whom, the rule the program enforces, the PR ids in order.>

## How to read this

One box is one unit of work. Every box names the evidence that checks it. Check a box only when its evidence exists: a file, a log line, a screenshot, a test run, a SHA. The body is a how-to. The appendices explain and record.

Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

- [ ] Follow this dependency graph. <PR id> and <PR id> are independent and first. <PR id> after <PR id>.
- [ ] Hold the file boundaries. <PR id> touches only `<glob>`.
- [ ] For every PR run Opening a PR, then Babysit in `check` mode.

## <Task as a verb phrase> (<PR id>)

**Depends on.** <PR id, or None.>

**Files.**

- [ ] Edit `<path>`.

**Build.**

- [ ] <One change. Name the symbol and the file.>

**You see.**

- [ ] <One observable result, with the exact log line or screen state.>

**Verify.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Unit. <Test file and the case it gains.> Run `<command>`.
- [ ] Live. <Scenario on the real surface.> Pass when <predicate>.
- [ ] Perf. <Metric, probe, baseline, failing number, or n/a with the reason.>

**Merge.**

- [ ] Clean-diff checklist from Opening a PR passes at the head SHA.
- [ ] Bot review triage done.

## Close the program

- [ ] Every box above is checked with its evidence.

## Appendix A. Prototype evidence

<Each open question a prototype answered, with branch, SHA, artifacts. Each question still unproven.>

## Appendix B. Alternatives rejected

## Appendix C. Risks
````

**Reply:** the plan path, the PR ids with their dependencies, what the prototypes proved and what stays unproven, and the check script's output.
