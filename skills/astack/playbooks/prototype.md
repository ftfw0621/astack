### Prototype

**You own the design decision, not the code. The prototype is a throwaway instrument. The real build follows Feature.**

The one playbook where "smallest change" and the verification bar invert. Speed over polish, no tests, no abstractions. The rigor is in picking the right design cheaply.

1. Scope the decision the prototype exists to make: which layout, which interaction, which behavior, which timing. No decision means no prototype. Route to Feature.
2. Build throwaway code in a scratch directory outside the production source. The lightest stack that renders or exercises the question.
3. When comparing alternatives, build them behind one switch, each variant labeled (`exhaust-the-design-space`).
4. Observe the thing you are deciding: screenshot each variant, print the output, log the timing. The observation is the test.
5. Present alternatives, tradeoffs, and a recommendation. Hand the chosen direction to Feature, or to `architect` for the shape.

**Reply:** the variants explored, the evidence, tradeoffs, your recommendation, the scratch path. Say plainly that the prototype is throwaway.
