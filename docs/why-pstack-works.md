# Why pstack produces better code, and where the claim is soft

pstack's author says the stack "helps you write less, but higher quality code". This note names the mechanisms that actually carry that claim, the places where it is hope rather than mechanism, and what astack changes so the same mechanisms work on ordinary models.

The short version. pstack does not make the model smarter. It makes "done" harder to claim and "wrong" cheaper to catch. Quality comes from constraints on the process, not from prose asking for quality.

## The seven mechanisms

1. **Shape before code.** Every code path forces the data shape first (`model-the-domain`), the caller's usage before the types (architect's rationale template writes "Usage (caller's view)" first and derives the type sketch from it), and signatures with `not implemented` bodies before logic. Architect requires at least two structurally distinct candidates before synthesis. This blocks the commonest LLM failure, locking in the first plausible structure and bolting special cases onto it.

2. **Author and judge are different agents.** The feature playbook delegates code to a subagent and has the lead review the diff, with "no skip-with-reason escape". Comment Sicko is a separate agent because an author defends its own comments. Interrogate spawns reviewers on different model families because blind spots differ, and treats a finding two models raise independently as high-signal. Shipping states it plainly: the agent that judges a change is never the one that wrote it. Models are sycophantic toward their own output. Separation is the counter.

3. **Evidence contracts, not self-reports.** `prove-it-works` says trust artifacts, not summaries. Every playbook ends with a reply contract that names the evidence to paste: the failing-then-passing repro output verbatim, the baseline and post-fix numbers with the artifact path. "Inconclusive or wrong-surface is not a pass." Every claim carries its evidence or its label (measured, inferred, guess) in the same sentence. A model that must hand over the artifact cannot hand-wave.

4. **Subtraction is built into every step.** `laziness-protocol`, `subtract-before-you-add`, `minimize-reader-load`, `no-comments`, `deslop`, and the bug-fix rule that a belt-and-suspenders change "that might help" is a hypothesis, not a fix, and does not ship. AI slop is mostly over-generation (defensive guards, comments, wrappers, fallbacks). The stack attacks that failure mode directly.

5. **Verifiable units in order.** Failing test first, then the fix. One change, one measurement, keep or revert. Small ordered commits that read as an argument. Breakage localizes to the unit that caused it, and review gets cheap.

6. **Lessons become structure.** `build-the-lever` is blunt: if you cited it and there is no script, codemod, or generator in the diff, you did not apply it. `check-plan.mjs`, `log.sh`, `worktree-audit.sh`, and `reflect` turn corrections into scripts and skill edits. Quality compounds because the fix lives in a file, not in memory.

7. **Tests have a mechanical oracle.** `test-behavior-not-implementation` gives a rule any model can apply: would this test still pass if every imported function returned `undefined`? It then names five shapes that fail the rule. That is a checklist, not a taste.

## Where the guarantee is soft

- **It is prose.** Apart from three scripts, the whole stack is text the model must follow. The author's own `encode-lessons-in-structure` principle says textual instructions are easy to miss. The stack is about 170 KB of them.
- **It assumes frontier judges.** Defaults are `claude-opus-5-5-max`, `gpt-5.6-sol-max`, and `grok-4.7-xhigh-fast`. Mechanisms 2 and 3 are only as strong as the model in the judge seat.
- **Verification depends on a control skill it does not ship.** "Prove it works on the real surface" needs `control-ui` or `control-cli` from another plugin. Without one, proof degrades to tests.
- **The claim is unmeasured.** The repo ships an eval playbook but no eval results. "Higher quality" is the author's experience, not a measured delta.
- **Context cost is real.** The router alone is 19 KB, plus the principles index read at every task start, plus the matched playbook. Long instruction sets degrade compliance on smaller models.

## What astack changes

- Keep all seven mechanisms. Cut the prose that carries them to what an ordinary model can hold.
- Replace judgment with mechanism where a rule is checkable: `scripts/test-smells.sh`, `scripts/check-skill.sh`, `scripts/log.sh`. More scripts as rules prove recurrent.
- Route by model strength. Generation goes to whatever model is cheap. Judgment (design pick, review verdict, dismissals) goes to the strongest available model. Adversarial review goes to a different family when one is available.
- Give the generating model a brief with the shape, the caller's usage, the acceptance criteria, and the forbidden moves filled in. An ordinary model does not need to judge well. It needs to follow a good brief and be checked by a strong judge and a script.
- Measure. Wave 3 adds a `claude plugin eval` suite so "higher quality" becomes a number, with and without the plugin.
