# Long-form documents

What it holds: specs, RFCs, PRDs, ADRs, design-review notes, postmortems, runbooks that explain defensive code, strategy pages. Where the why is written before it becomes code.

Search it with the docs MCP (Claude Docs, Google Drive, Confluence, Notion) and the repo's own `docs/` and `docs/decisions/` directories.

1. Keyword searches: the feature name, key symbols, error strings, the author's name, a time window around the ship date.
2. Read the full document, not the preview. Rationale sits mid-document.
3. Follow links and child pages. Alternatives and appendices hang off the main doc.
4. Search meeting notes for the decision date.

Good evidence: a "Problem" or "Motivation" section matching the target. An "Alternatives considered" section. A postmortem naming the target as the fix. Meeting notes recording "we decided X because Y" near the PR date. A filled-in ADR.

Pitfalls: specs written before implementation and never updated, so cross-check against the PR and flag divergence. Boilerplate "Why" sections. Several drafts, so find the finalized or most recent one. Unlinked docs, so search broadly. A page you cannot open is a gap.

Return for each relevant document: title and URL, authors and last-updated date, the motivation text quoted with its section, linked pages, finalized or draft.
