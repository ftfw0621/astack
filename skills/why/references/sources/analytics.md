# Analytics warehouse

What it holds: the product and data view. Product events (feature invocations, accepts and rejects, client-reported errors), usage and billing events, experiment and feature-flag exposures, query history, pipeline lineage. Answers "where did this number come from" and "did this feature launch or die".

Search it with the warehouse MCP or CLI (Databricks, StarRocks, BigQuery, Snowflake) using read-only SQL.

Orient before querying. Schemas are company-specific, so probe with `SHOW TABLES ... LIKE '%keyword%'` and `DESCRIBE TABLE` before trusting a name. Time-bound every query to a window around the ship date. Prefer typed, deduplicated models over raw event tables.

Patterns that pay off:

1. Event usage trajectory: daily counts across a window around the merge. A step from zero within a day or two of the merge suggests the PR launched the feature. A decay to zero suggests a deprecation.
2. Guard-rail origin: the distribution (median, p99, max) of the relevant column in the weeks before the PR. A p99 matching the code's threshold suggests the number came from data.
3. Experiment lookup: exposure counts by variant for the flag key near the PR date.
4. Query history filtered by table or symbol with a tight time window, sorted by duration or bytes read, for migrations and perf rewrites.
5. Lineage: if the target reads or writes a model, that model's own git history carries the rationale. Hand that lead to the source-control investigator.

Good evidence: an error-classifying event's count dropping to near zero after a defensive-code PR. An exposure row naming the target's flag with a decision near the ship date.

Pitfalls: instrumented is not caused. A step in volume may be new instrumentation, not new behavior, so check for instrumentation PRs in the window. Schema drift. Refresh lag on derived models. A table you never confirmed exists. A window before the table's retention or creation is a gap, not a null. Notebooks are usually not queryable, so name them as a gap.

Return for each finding: type, fully qualified table and the exact query, time window, a compact numeric summary (never raw rows), the correlation with the ship date, and strength (direct, circumstantial, weak).
