### Opening a PR

Invoked at the end of every code playbook.

**Worktree.** Work from a git worktree off the base branch. Delegates get their own worktrees. A dirty branch with unrelated work: patch out, fresh worktree, apply.

**Commits.** Commit liberally, then rebase into small ordered commits before opening. Each commit lands on its own and the sequence tells the story: failing test, then fix; subtraction, then reshape; scaffold, then feature.

**Clean the diff.** Before the first push, run this checklist against `git diff <base>...HEAD`:

- `scripts/code-smells.sh --base <base>` prints nothing you cannot justify in the PR body.
- The `no-comments` skill has run and its accepted flags are fixed.
- No defensive guard without a reproduced failure. No dead compatibility path. No unrelated edits. No `any`, cast, or `interface{}` away from a boundary.
- `scripts/test-smells.sh --base <base>` prints nothing.
- The repo's own format, lint, and test commands are green on the committed head. A hook pass is not proof.

**Title.** Conventional Commits, `type(scope): subject`. Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`. The repo's own ticket convention, when it has one, goes where the repo puts it (for example `feat(APP-1234): subject`). Imperative, short, no trailing period.

**Body.** A briefing, not a lab notebook. Write it with the `unslop` skill. Sections in order; drop a section with nothing to say:

- `## Why`. Intent and approach in one or two short paragraphs.
- `## Scope`. Bullets naming real symbols and paths. Both sides of a rename.
- `## Tradeoffs`. Only rejected alternatives a reviewer would ask about.
- `## Blast radius`. One to three sentences: who or what it touches and why it is safe or risky.
- `## Verification`. Each real run path and its outcome. A perf change reports one number as `before → after` with its unit.

No SHA lists, no file-by-file essay, no `## Summary` or `## Test plan` boilerplate. Screenshots or a recording when they prove a claim.

**Open it.** `gh pr create --head <branch> --base <base>`, never a draft. Run `gh pr view <number>` before you refer to its status. Post the URL and keep building. Opening a PR does not start a babysit.

**Reply:** the PR link as `https://github.com/<owner>/<repo>/pull/<number>`, the clean-diff checklist results, and the verification section verbatim.
