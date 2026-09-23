---
name: why
description: Find out why code is the way it is. Use for "why does X work this way", "why did we pick Y", design rationale, regressions, postmortems, or where a threshold came from. Searches every evidence source in parallel and returns a cited, confidence-labeled answer.
---

# Why

Investigate the motivation behind code. Companion to `how`, which explains what the code does. `why` explains what forces gave it its shape.

Operate as a careful, precise investigator. Say what you know, what you infer, and what you could not find. `references/epistemics.md` is the confidence framework. The synthesizer must follow it.

## 1. Target and question

The target is a chunk of code, a pattern, a feature, or a named decision. The question is a rationale, a tradeoff, an edge case, an external constraint, dead code, or a history sweep. If the target is vague, state your interpretation from context and proceed.

## 2. Code anchor

Before spawning anything, anchor in concrete code: file paths and line ranges, key symbols, the last commits touching the target (`git log --oneline -20 -- <file>`, `git blame -L`), PR numbers from merge subjects (`(#1234)`), ticket IDs from commit and PR bodies. Pull PR bodies and reviews with `gh pr view <n> --json title,body,comments,reviews,closingIssuesReferences`. This is the seed every investigator gets.

## 3. Discover sources and spawn investigators

List the MCP servers in this session (tools named `mcp__<server>__*`; deferred ones appear through ToolSearch) plus any CLI the repo documents for a data system. Map each to one category:

| category | playbook | examples |
|---|---|---|
| source control | `references/sources/code-archaeology.md` | git, `gh`; always available |
| issue tracker | `references/sources/issue-tracker.md` | Linear, Jira, GitHub Issues |
| long-form docs | `references/sources/docs.md` | Claude Docs, Google Drive, Confluence, Notion, `docs/` in the repo |
| team chat | `references/sources/chat.md` | Slack, Teams, Discord |
| observability | `references/sources/observability.md` | Grafana, Chronosphere, Datadog, Loki |
| error tracking | `references/sources/error-tracking.md` | Sentry, Rollbar |
| analytics warehouse | `references/sources/analytics.md` | Databricks, StarRocks, BigQuery, Snowflake |

Spawn one read-only delegate per category that has a source, all at once, on the explore role (the router's `references/hosts.md`). Each gets `references/investigator-prompt.md` filled with the question, the anchor, and its single category playbook, plus `references/sources/incident-postmortem.md` when the target looks defensive (null checks, retries, timeouts, rate limits, feature flags). Investigators read and query only. They never write.

Skip a category only with a written reason in Sources consulted: no source exists in this environment (a gap), or the source is provably irrelevant (a build-time script has no runtime errors). Answer inline without investigators only when the PR body already contains the complete answer and every other search would be redundant, and say so.

## 4. Synthesize

Spawn one synthesizer delegate on the judgment role with `references/synthesizer-prompt.md`, every investigator's findings including nulls and skips, the anchor, the question, and the epistemics framework. It spot-checks citations and writes the answer in tiers: Direct, Supported, Inferred, Speculative, Unknown.

## 5. Present

Present the synthesizer's output with light edits. Do not rewrite the confidence language. If the question precedes a code change, add a Preserve / Change / Avoid / Risk constraint list.

**Reply:** The question, The code in question, What we found, What we can reasonably infer, Competing hypotheses, What we don't know, Sources consulted (one line per category, including skipped ones with the reason), Confidence summary.
