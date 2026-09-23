### Authoring or modifying a skill

**You own the skill's voice.** Agent-facing prose has a higher bar than human prose: an unhelpful sentence becomes an instruction a future agent follows.

1. Read `docs/design.md` in the astack repo for the skill shape and the size limits.
2. Write or edit the skill. Numbered steps that each end in a check. Templates over instructions. A script over prose when the rule is checkable. When in doubt, delete. Explain only when the rule is confusing without it.
3. Run `scripts/check-skill.sh` from the repo root and fix every line it prints.
4. Apply the `unslop` skill to every line.
5. If the change is structural, run one real task through the skill before shipping. Record what happened in the PR body.
6. Add the skill's origin and changes to `docs/pstack-audit.md` when it derives from pstack. Run **Opening a PR**.

**Reply:** the skill's summary, key decisions, the check script's output, and what you ran through it.
