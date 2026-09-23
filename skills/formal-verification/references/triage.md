# Formal verification triage

Fill this for the code in question. Answer each question with yes or no and one line of evidence. Score at the end.

## The code

- Files and symbols:
- What it decides or guarantees, in one sentence:
- Who or what depends on that guarantee (money, compliance, data integrity, availability, nothing external):

## Cost of a wrong answer

1. Does a wrong result lose money, corrupt data, break a compliance rule, or lock out users? (yes = 3)
2. Has this area had a production incident or a reverted fix? (yes = 2)
3. Is a failure silent, meaning nothing would alert until harm was done? (yes = 2)

## Size of the space

4. Do two or more actors (replicas, goroutines, workers, clients) touch shared state, with crashes or retries possible between steps? (yes = 3)
5. Is correctness a property over all inputs of an unbounded domain (any string, any integer, any sequence), not a finite list of cases? (yes = 2)
6. Would a test need more than about twenty hand-written cases to feel convincing? (yes = 1)

## Can a test cover it

7. Can you name the specific interleaving or input that would break it, and write that test today? (yes = subtract 2)
8. Is the logic already isolated in a pure function or a single state machine, so a model or proof maps onto it cleanly? (no = subtract 1, and consider isolating it first)

## Score and outcome

Sum the points.

- Under 4: **tests suffice.** Write behavior tests. Add property-based tests when question 5 was yes.
- 4 to 6: **property-based tests plus a written invariant.** State the invariant in the code's doc comment and assert it in a property test. Revisit if the area gains actors or an incident.
- 7 or more with question 4 yes: **TLA+.**
- 7 or more with question 5 yes and question 4 no: **Lean.**
- 7 or more with both yes: **both.**

## Properties

List every property as one falsifiable sentence. These become invariants or theorems verbatim.

1.
2.

## Decision record

Outcome, score, the two strongest reasons, and who reviewed the property list.
