---
name: blast-radius
description: Find what a change could break beyond the diff, and prove the one fact it is safe because of by running real code. Use for "blast radius of X", "what could this break", or a small diff you do not trust.
---

# Blast radius

Find what a change breaks somewhere else, before it ships. Companion to `how` (what the code does) and `why` (why it is shaped that way). Listing the callers is not the job. The job is the breakage grep will not show you.

## Do not trust your own writeup

A blast-radius writeup that sounds right is worthless. It reads as convincing whether or not it is true. Find the one or two facts the whole thing depends on and prove them by running code.

For each fact the change's safety depends on, get it as far down this ladder as is cheap, and say where it stopped:

1. You said so. Worthless on its own.
2. You pointed at the line. A real `file:line`, or the library's own source.
3. You showed the bad case cannot happen. You walked the failure step by step and it does not reach.
4. You ran it. A script or test that calls the real code and fails loud if you are wrong.
5. You reproduced it in the running app.

Step 4 is usually one small script that imports the same library the app ships and calls the exact function you are worried about.

## Steps

1. Read the change: the diff, the symbols it adds, changes, and deletes, and what it now does differently, including the part the diff does not spell out. Pull the PR and commits as the `why` skill's code anchor does.
2. Find the one fact it is safe because of. Most risky-looking changes are safe because of a single fact ("this call only drops already-dead cache entries"). If it holds, most risky cases clear at once. Spend your time here, not on a long list of maybes.
3. Look where grep stops. The library's source at its pinned version and any local patch. When things run: microtasks, teardown, goroutine lifetimes. What a symbol search misses: the JSON an API returns, a DB column, a wire format, another language reading the same bytes, a feature flag, code three hops downstream.
4. Be honest about each risk. A real chance of happening and a real cost if it does. Keep the risks you confirmed. List separately the ones you checked and cleared. Cite a real `file:line`. A search that finds nothing is still an answer. Never invent a caller or an API.
5. Prove the one fact. Write a script or test that runs the real code, run it, and paste what happened (`prove-it-works`, `build-the-lever`).
6. For a big or wide change, run it as an `arena`: several models asked the same question, answers merged. Different models catch different real bugs.

**Reply:** What it does (including the non-obvious part). The one fact it is safe because of, which ladder step it reached, and the proof, or the word unproven. Risks, each with how it breaks, `file:line`, likelihood, cost, and how to check. Cleared, with why. Before you merge: the cheapest test or repro that catches the real bug, including the script you wrote. Written through `unslop`.
