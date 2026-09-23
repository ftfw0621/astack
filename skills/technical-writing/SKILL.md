---
name: technical-writing
description: Layered technical-writing standard (Diataxis structure, Google developer style, STE instruction rules, Global English) for docs, RFCs, readmes, PR descriptions, and commit messages. Use when writing or reviewing any of them.
---

# Technical writing

The goal is writing a tired engineer understands on the first read. Four layers get you there, one question each: what kind of document is this, how do sentences address the reader, how much does each sentence carry, and can any sentence be read two ways. Apply all four.

Three rules sit above the layers:

- **Cut every word that does no work.** If the sentence survives without a word, the word goes. "In order to" is "to". "It is important to note that" is nothing.
- **Use the short, everyday word.** "Use", not "utilize". "Help", not "facilitate". "Do", not "perform". A long word has to buy its length with precision.
- **When a rule makes a sentence worse, fix the sentence another way or leave it alone.** The rules serve the reader. A sentence that follows every rule and sounds like a machine wrote it has failed.

The codebase is the word list. Write the real symbol, file, flag, or command name, not a synonym or a description of it.

Don't invent jargon. Use the words a developer would say out loud: "move", "delete", "a budget that only decreases", not "evacuate", "ratchet", or "endgame". A named pattern is fine when the doc says what it means the first time. Propose a new offender and its replacement as an addition to the `unslop` skill's abstract-metaphor rule in your reply. Do not edit that skill mid-task.

## Vary the rhythm

The layers decide what a document says and how much each sentence carries. A doc can obey all of them and still read machine-written: every sentence clipped short, no view anywhere, nothing specific.

- Mix sentence lengths on purpose. Short sentences land a point. Longer ones that take their time carry a fact with its condition or consequence.
- One thought per sentence does not mean one length per sentence. Split the sentence that carries two thoughts. Keep the long sentence that carries one.
- Have a view where the mode allows it. Explanation weighs trade-offs, so say what you make of them instead of listing pros and cons. Reference stays dry.
- Be specific over sterile. Not "schema changes can cause issues" but "a column rename fails the build".

## Pick the mode first (Diátaxis)

One document, one mode. Two questions pick it: does the content inform action (doing) or understanding (thinking), and does it serve learning or work?

- Action + learning: **tutorial**.
- Action + work: **how-to**.
- Understanding + work: **reference**.
- Understanding + learning: **explanation**.

Use the compass on a whole document or on one sentence.

**Tutorial: learning by doing.** You are the teacher. The learner's success is your job, not theirs. Open by saying what the learner will build, not what they will "learn". Every step produces a visible result, early and often. Tell them what they should see: the expected output, the prompt change, the log line. Cut explanation to one clause and a link. Teaching pauses break the lesson. Stay concrete. Write as "we", in commands: "First, do x. Now, do y."

**How-to: steps to a goal.** Solve a problem a person has, not an operation the machine can perform. Assume competence. Skip teaching. Action only: no digressions, no background, no completeness for its own sake. Link those instead. Allow forks and judgment: "If you want x, do y." Name the guide by the task: "How to calibrate the radar array", not "Radar array calibration".

**Reference: facts for lookup.** Describe. Only describe. No instruction, no persuasion, no opinion. Be dry, complete, and sure. State facts, options, limits, and errors with no hedging. Mirror the structure of the thing described, so code and docs can be navigated together. Put material where readers expect it. Generate from code where possible, so it stays true.

**Explanation: understanding and why.** One bounded topic, readable away from the product. Each title should tolerate an implicit "About..." in front. Anchor on a real why question. Give context: design decisions, history, constraints, alternatives. Opinion is allowed here and nowhere else.

Don't mix modes: no reference tables inside a tutorial, no tutorial hand-holding inside reference, no arguing inside a how-to. Split and link instead.

Source: diataxis.fr, fetched 2026-07-18.

## The sentence layers

The three sentence-level layers (Google developer style, STE, Global English) are in `references/sentence-layers.md`. Read it before writing more than a paragraph. It ends with a worked before-and-after example. In short: talk to the reader as "you" in the present tense, say who does what, one instruction per sentence, keep the articles, keep "only" and "not" next to the word they change, one name per thing, no semicolons, no slashes, no idioms.

## Voice and repo specifics

- Apply the `unslop` skill to every doc this skill touches. That skill owns the slop-pattern catalog: AI vocabulary, filler, hedging, formatting tells.
- PR descriptions and commit messages are writing too. Every layer except Diátaxis applies to them. A PR body is a briefing that a reviewer can read in under a minute. Do not paste swarm logs, SHA lists, or metric tables. Link them.
- Product UI strings are not documentation. Use your product's copy guidelines for those.
- Indent code snippets with tabs. Write real paths and real symbols. Make every count or tree claim true at the commit that lands it, and include the command that regenerates it.

**Reply:** the document or the review, plus the mode you picked and why, and any proposed additions to the unslop catalog.
