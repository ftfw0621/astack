# Bot review triage

For comments from automated reviewers (Bugbot, CodeRabbit, Copilot review, security scanners). The goal is not to ignore them. The goal is to stop treating every comment as a required code change.

## Rubric

Classify each thread before acting:

- `fix`: a plausible correctness, security, privacy, data-loss, auth, billing, migration, idempotency, race, or shipped-behavior issue. Fix it in the lowest owning PR, reply with the commit SHA, resolve.
- `dismiss`: the comment matches a documented noisy pattern below and the current code proves no change is needed. Reply with the short disproof, resolve.
- `ask`: novel, high severity, security or data related, or ambiguous. Ask the user instead of guessing.

When in doubt, ask. Skipping a noisy style comment is cheap. Skipping a real data or security bug is not.

## Ask by default

Never auto-dismiss: security, privacy, auth, billing, data retention, permission boundaries; high-severity findings; migration, schema, idempotency, concurrency, cross-system findings; a comment whose suggested fix is small and clearly reduces risk.

## Learned patterns

Add patterns in this shape. `candidate` after one or two examples, `recurring` after several real dismissals, `strong` only when narrow, repeatedly verified, and low-risk.

```markdown
### <pattern name>
- Confidence: candidate | recurring | strong
- Skip when: <conditions that must hold>
- Do not skip when: <risk boundaries>
- Example signal: <phrases or code context>
- Source: <PR or short note>
```

### Usage the bot cannot see

- Confidence: candidate
- Skip when: the bot flags a symbol as unused and a later PR in the stack or a generated consumer uses it, and you verified that use.
- Do not skip when: the symbol is public API or the use cannot be verified.
- Example signal: "exported X is never used".

### Invariant already enforced elsewhere

- Confidence: candidate
- Skip when: the concern is guaranteed by a shared component, type, or single source of truth visible in the diff or nearby code.
- Do not skip when: the invariant is assumed but not enforced, or crosses an async or state boundary.
- Example signal: a nullable check where the local value and the passed value share one source.

### Verify a drift claim by running the test

- Confidence: candidate
- Skip when: never skip the verification. When the bot claims a test no longer matches the code or a doc, run that test on the PR tip before classifying. Red confirms it. Green is the disproof for the dismissal reply.
- Example signal: "the contract test omits", "no longer matches".

### Widening a deliberately narrow error condition

- Confidence: candidate
- Skip when: the finding asks to broaden a specific error code into a catch-all and the narrowness encodes a real distinction ("binary not installed" versus "command failed").
- Do not skip when: the narrow condition misses a case in the same category, or the unhandled path loses data.
- Example signal: "only handles ENOENT".
