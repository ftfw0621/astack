# Error tracking

What it holds: the archive of what went wrong. Grouped issues with counts and first-seen and last-seen timestamps, individual events with stack traces, releases, engineer comments on root cause. The strongest thing it offers is temporal correlation: an issue that starts before the target's PR and stops after it.

Search it with the error-tracking MCP (Sentry, Rollbar, Bugsnag).

1. Orient on the project and organization.
2. Search issues by the exception class the target handles, the target's function or file, the error strings it checks.
3. For each suspect issue read first seen, last seen, affected releases, and the frequency curve, and line them up with the target's ship date.
4. Pull a full event. Does the stack trace pass through the target? Do the tags match the conditions it defends against?
5. Find the release that contains the target's commit.
6. Treat any AI root-cause narrative as a hypothesis. Events and timestamps are the evidence.

Good evidence: an issue first seen shortly before the PR and last seen shortly after. A stack trace landing on the target function. A comment from the PR author describing the fix. A PR body citing the issue URL.

Pitfalls: regrouping after a refactor makes an issue "end" while the error continues under a new ID. A release carries many commits, so a stop at release N does not prove the target fixed it. Resolved is a human marker, not proof. Sampling makes low counts unreliable.

Return for each issue: ID and title, project, first and last seen, event count and sampling if known, affected releases, a verbatim stack excerpt showing relevance, the correlation with the ship date, link, author comments.
