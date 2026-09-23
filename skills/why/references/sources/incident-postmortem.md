# Incident and postmortem angle

Not a separate source. A cross-cutting angle to apply inside your own source when the target looks defensive: null checks, retries, timeouts, rate limits, feature flags, egress guards, memory guards. Incidents motivate defensive code, so hunt for incident history:

- Docs: postmortems naming the target file, feature, or error string.
- Issue tracker: tickets labeled `incident`, `sev`, `postmortem-action-item`, `reliability`.
- Chat: incident and sev channels around the dates the target was added.
- Source control: messages like "fix for incident", "add defensive check", a revert followed by a re-apply.
- Observability: formal incident records, and dashboards or alerts created as action items.
- Error tracking: issues whose first-seen and last-seen bracket the target's ship date, traces through the target.
- Analytics: error-classifying events that spike during the incident window and drop after the PR.

When you find an incident, fetch the full postmortem. Its action items tie directly to code changes. Corroboration across sources (an incident ID in a ticket, in a postmortem, in a thread linking the PR) is the strongest evidence this skill produces. Skip this angle for code that does not look defensive.
