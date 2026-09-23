---
name: swarm
description: Fan out N parallel workers over slices or a race, drain them, and return one report. Use for /swarm, coverage matrices, gauntlets, or "one worker per package, one report".
---

# Swarm

Fan out N parallel workers. They cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report. Distinct from `arena`, which repeats one design brief and grafts the best parts. Swarm partitions or races and declares its selection rule up front.

Open a todo list with one entry per phase: Frame, Fan out, Aggregate, Report.

## A. Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape: partition into slices, race N workers on identical briefs, or mix. For a race, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape.
4. Pick the worker model: the explore role for read-only checks, the code role when workers write. For a model race, name each arm's model.
5. Give each worker its own writable output (`isolation: "worktree"` when it writes code, otherwise its own directory). When workers verify or measure commits, every brief names the exact SHAs and, for a measurement, the method: sample count, what one sample is, order. The worker records both in its result.

## B. Fan out

Spawn all N in one message with the Agent tool, `run_in_background: true`. Every brief stands alone: goal, scope, exact slice or race arm, how to verify, what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first. A worker that drops out proceeds as N-1, noted.

## C. Aggregate

Read every result. Drop a result that does not record the SHAs and method its brief named, and rerun that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the declared selection rule. Do not paste raw worker output.

## D. Report

**Reply:** one consolidated report: a compact result table, one line per evidenced issue, explicit gaps and dropouts, and the race rule when one was used.
