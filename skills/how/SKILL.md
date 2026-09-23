---
name: how
description: Explain how a subsystem works, as a senior engineer onboarding. Use for "how does X work", a walkthrough before changing something, or placement and ownership questions ("where should this live").
---

# How

Explore the codebase to answer "how does X work?" at the level a senior engineer needs to start working in the area: a working mental model, not annotated source. Companion to `why` (motivation) and `blast-radius` (what a change breaks).

## 1. Assess complexity

State your interpretation of the scope if it is ambiguous, then explore. The user can redirect.

- **Simple** (one module, one function, a narrow question): one explainer explores and explains in a single pass. Go to 2b.
- **Complex** (a subsystem across files or services, a cross-cutting feature, an architectural overview): parallel explorers first, then an explainer. Go to 2a.

When in doubt, take the simple path.

## 2a. Explore (complex only)

Decompose the question into two to four angles, each a distinct slice. Spawn all explorers at once as read-only delegates on the explore role (the router's `references/hosts.md`). Each gets `references/explorer-prompt.md` with its angle filled in. Then go to 3.

## 2b. Direct explain (simple only)

Spawn one read-only delegate on the judgment role with `references/explainer-prompt.md` minus the explorer-findings section. Go to 4.

## 3. Synthesize (complex only)

Once every explorer returns, spawn one read-only delegate on the judgment role with `references/explainer-prompt.md` and every explorer's findings filled in. Read only.

## 4. Present

Present the explainer's output. Light edits for context are fine. Do not rewrite it.

**Reply:** Overview, Key concepts, How it works, Where things live, Gotchas. Drop a section that does not apply. Every file and symbol named is one you or an explorer read.
