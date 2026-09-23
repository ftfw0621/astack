# Source control

What it holds: commit messages and diffs, PR bodies and review threads, inline comments and TODOs, ADRs under `docs/`, tests whose names encode edge cases, co-changed files, changelogs, ticket IDs in messages. The most trustworthy source, tied to the code.

Search it:

```bash
git log --follow --oneline -- <file>          # history through renames
git log -S '<exact string>' -- <file>          # commits that added or removed this text
git log -G '<regex>' -- <file>
git blame -L <start>,<end> <file>
git show <hash>
git log -1 --format=%B <hash>                  # PR number and ticket IDs
gh pr view <n> --json title,body,author,createdAt,mergedAt,labels,closingIssuesReferences,comments,reviews,files
rg -n -C2 '(TODO|FIXME|HACK|XXX|NOTE)' <file>
rg -l '<symbol>' --glob '*test*'
rg -l -i 'decision' docs/ --glob '*.md'
```

Good evidence: a PR body that states the problem, not just the change. A review thread where alternatives were debated. An inline comment naming a constraint. A test named after the edge case. A commit that cites a ticket or incident.

Pitfalls: squash merges flatten branch history, so read the PR body and comments. "Small refactor" can hide a behavior change, so read the diff. A copied pattern may carry no intent, so find where the pattern first appeared. Bot commits carry no motivation. The code itself is not evidence of its intent.

Return every commit, PR, or comment that bears on the question: exact text quoted, hash or PR number or `file:line`, author and date, direct or circumstantial.
