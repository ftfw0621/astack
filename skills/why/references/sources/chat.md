# Team chat

What it holds: real-time deliberation that never reached a doc. Incident channels, design threads, questions answered by a senior engineer, post-merge discussion of why something was revisited. Often where the real decision happened, and the most ephemeral source.

Search it with the chat MCP (Slack, Teams, Discord). Check the tool schema first. If authentication fails, stop and report the gap.

1. Author-bounded: messages from the PR author around the merge date.
2. Keyword: feature name, key symbols, casual phrasings and misspellings.
3. PR URL or `/pull/<number>`.
4. Error strings the code handles. Incident threads surface this way.
5. Likely channels: engineering, project, incident or sev, the owning team, design review.
6. Fetch whole threads. The decision lives in the replies.

Good evidence: a thread debating tradeoffs ("I was going to use A but B is better because"). An incident message describing the bug the code prevents. A reviewer's question with an authoritative answer. A product manager explaining a customer ask.

Pitfalls: retention cliffs, so note the earliest searchable date. DMs are unsearchable, a known gap. A joke is not a decision. A single message without its thread reads differently, so always fetch the thread.

Return for each relevant thread: channel, permalink, participants, date range, key quotes verbatim with attribution, and what the thread was part of.
