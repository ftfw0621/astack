# Delegate brief

Fill every field before spawning. A field you cannot fill is a unit you have not scoped yet. Paste the filled brief as the delegate's prompt, followed by the instruction to read the `astack-agent` contract.

```
GOAL        One sentence. The outcome, executable by a stranger with no chat access.
SHAPE       The data shape and its organizing structure (state machine, typed model,
            table or registry, reducer, boundary), chosen before any logic.
USAGE       Two or three call sites written the way the caller will write them.
            The types serve these lines. Reconcile the types to the usage, not the reverse.
SCOPE       Paths you may write. Paths you may not touch. Your worktree or branch.
CONTEXT     File pointers, the `how` summary, the nearest existing tests, the
            conventions of the surrounding code.
ACCEPTANCE  Checkable criteria, one per line. Each names the command or artifact
            that checks it.
TESTS       The failing test(s) to write first. Each calls the code the way a user
            does and asserts a literal expected value. No test that would pass if
            every import returned nothing.
VERIFY      Exact commands to run and what a green run prints.
FORBIDDEN   No abstraction beyond SHAPE. No defensive guard without a reproduced
            failure. No narrating comments. No edits outside SCOPE. No weakened
            assertion. No `any`, cast, or `interface{}` away from a boundary.
            No new dependency. Plus unit-specific bans.
REPORT      Status, branch, head SHA, diff stat, every command you ran with its
            output, deviations from SHAPE or USAGE and why, open questions.
```

Size the brief to the unit. A two-line edit gets the template collapsed to a paragraph that still names GOAL, SCOPE, VERIFY, and REPORT.
