# Observability

What it holds: the runtime record. Metrics (a metric's existence means someone thought the number worth watching), alerts and their thresholds (a monitor on `rate_limit_hit > 10/min` is direct evidence the team worried about that threshold), dashboards, traces, logs, formal incidents.

Search it with the observability MCP or CLI (Grafana, Chronosphere, Datadog, Loki). Start broad, then narrow, and time-bound every query to a window around the ship date, about 30 days each side.

1. Find the owning service and its dependencies.
2. Dashboards and alerts first. Their queries and thresholds often answer "why is this clamped at N".
3. Metrics named after the feature or symbol. Correlate the trajectory with the change date: a spike before, stable after, is supporting evidence.
4. Logs: search for symbols, error strings, feature names. Aggregate rather than dump.
5. Traces and spans for timeouts, retries, slow paths, cross-service behavior.
6. Incidents around the time the target was added.

Good evidence: an alert whose threshold matches the constant in the code. A dashboard by the target's author with widgets matching what the code guards. A metric spike immediately before the merge. An incident record citing the target's symbols or error strings.

Pitfalls: correlation is not causation, so check neighboring PRs in the same window. A chart reflects its author's framing. Renamed or expired telemetry is a gap, not a null. Common strings return thousands of log lines, so narrow by service, tag, and time. Instrumented is not caused, so pair with a PR citation.

Return for each item: type, name, identifier or link, owner and dates, the exact condition or query quoted, and how strongly it connects to the target.
