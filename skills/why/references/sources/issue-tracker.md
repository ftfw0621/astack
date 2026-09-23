# Issue tracker

What it holds: the product or business forcing function. Issue descriptions, comments recording decisions, parent issues that name the initiative, attached specs, labels (`customer-request`, `incident-followup`, `compliance`, `perf`), status changes that explain scope shifts, linked PRs.

Search it with the tracker's MCP tools (Linear, Jira, GitHub Issues):

1. Fetch every ticket the anchor cites first. Read the full issue and all comments.
2. Search by keyword: feature name, key symbol, business term. Try several phrasings.
3. Walk up the tree. Sub-issues are tactical. Parents carry the why.
4. Read project documents and attachments. Specs live there.
5. Read labels and milestones. They hint at the category of motivation and the deadline behind it.

Good evidence: a description stating the business problem ("Customer X needs this for their audit"). A comment recording a decision and the rejected alternative. A parent titled like an initiative. An attached spec.

Pitfalls: a ticket closed and reopened with a different scope, so read the whole history. Template "Why" sections filled with boilerplate. Stale tickets that describe a plan that changed, so check dates against the ship date. Duplicate chains, so follow them to the canonical ticket. A ticket you cannot access is a gap, not a guess.

Return for each relevant ticket: ID and title, the motivation quoted verbatim, labels, parent, project, author and dates, link.
