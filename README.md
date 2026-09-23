# astack

Rigorous engineering workflows for Claude Code, built so an ordinary model produces code and tests you would ship. Derived from [pstack](https://github.com/cursor/plugins/tree/main/pstack), rebuilt for Claude Code and for models that need structure more than encouragement.

The stack does not make the model smarter. It makes "done" harder to claim and "wrong" cheaper to catch:

- **Shape before code.** Data shape and caller usage are written before logic. Boundary-crossing changes get two competing sketches before one is picked.
- **Author and judge are different agents.** Code is delegated with a filled brief and reviewed by a stronger model. Comments are reviewed by an agent that did not write them. Adversarial review runs on several models.
- **Evidence contracts.** Every playbook ends with a reply contract naming the artifacts to paste. Inconclusive is not a pass.
- **Subtraction everywhere.** Guards need a reproduced failure. Comments need a why the code cannot show. Wrappers need a second caller.
- **Scripts over prose.** `scripts/test-smells.sh` flags tests that observe nothing. `scripts/code-smells.sh` flags type escapes, swallowed errors, commented-out code, files crossing 1000 lines. `scripts/check-skill.sh` keeps the skills themselves honest.

`docs/why-pstack-works.md` explains the mechanisms and their limits. `docs/pstack-audit.md` classifies every pstack file as adopt, adapt, or skip.

## Install

As a Claude Code plugin (recommended, skills appear as `astack:<name>`):

```bash
# try it for one session
claude --plugin-dir ~/workspace/astack

# or keep it on
export CLAUDE_CODE_PLUGIN_DIRS=~/workspace/astack

# or from GitHub
/plugin marketplace add https://github.com/ftfw0621/astack.git
/plugin install astack@astack
```

As plain personal skills (skills appear as `/<name>`; agents need a second symlink):

```bash
for s in ~/workspace/astack/skills/*; do ln -s "$s" ~/.claude/skills/; done
for a in ~/workspace/astack/agents/*.md; do ln -s "$a" ~/.claude/agents/; done
```

With the `skills` CLI:

```bash
npx skills add ftfw0621/astack -g
```

## Use

Start any non-trivial task with the router:

```text
/astack the export writes duplicate rows when a retry lands mid-run. repro first, then fix and verify.
/astack add a --json flag. text output stays byte-identical. verify both.
/astack move parsing into one module, zero behavior change. record the current output first.
/astack how do we dedupe notifications? don't change anything.
```

The router matches a playbook, copies its steps into the todo list, and invokes the other skills as the steps fire. Say the goal and how you will know it is done. Do not enumerate skills.

Reach for a skill directly when you want more or less scrutiny than the default:

| skill | when |
|---|---|
| `how` | a walkthrough of how a subsystem works |
| `architect` | settle usage, types, and boundaries before code |
| `arena` | N parallel attempts, pick a base, graft the rest |
| `interrogate` | several models try to break a diff |
| `code-quality` | the maintainability standard and review lens |
| `tdd` | failing test first |
| `test-quality` | is this test observing behavior? |
| `no-comments` | strip comments with fresh eyes |
| `unslop` | remove AI tells from prose |
| `show-me-your-work` | a decision trail for unattended work |
| `principles` | the 23 principles, indexed by when each applies |
| `bro` | say that again in plain words |

Model roles (judgment, code, explore, adversarial) default to `opus`, `sonnet`, `haiku`, and `opus` plus the `codex` CLI when installed. Override in `~/.claude/astack-models.md`, one line per role.

## Layout

```
skills/<name>/SKILL.md        one skill each; playbooks/ and references/ load on demand
skills/astack/playbooks/      investigation, bug-fix, feature, refactoring, prototype, autonomous-run, authoring-a-skill, opening-a-pr
skills/principles/references/ one file per principle
agents/                       comment-sicko, astack-agent
scripts/                      check-skill.sh, test-smells.sh, code-smells.sh, log.sh
tests/                        run.sh proves the smell scripts on fixtures
docs/                         why-pstack-works, pstack-audit, design, roadmap
```

## Contributing to your own stack

Run `scripts/check-skill.sh` before committing a skill and `tests/run.sh` before committing a script. The rules it enforces are in `docs/design.md`. What ships next is in `docs/roadmap.md`.

## License

MIT. Portions derived from pstack by Lauren Tan, MIT. See `LICENSE`.
