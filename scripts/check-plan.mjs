#!/usr/bin/env node
// Validate a multi-phase plan against the template in skills/astack/playbooks/multi-phase-plan.md.
// Usage: node scripts/check-plan.mjs <plan.md>   Exit 1 on any problem.
import fs from "node:fs";
import process from "node:process";

const RULE = "Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.";
const SUB_BLOCKS = ["Depends on.", "Files.", "Build.", "You see.", "Verify.", "Merge."];
const HOW_TO_READ = ["One box is one unit of work", "names the evidence", "Check a box only when its evidence exists", RULE];
const BOX = /^\s*- \[[ x]\] (.*)$/;

const file = process.argv[2];
if (!file) { console.error("Usage: node check-plan.mjs <plan.md>"); process.exit(2); }
const raw = fs.readFileSync(file, "utf8").split(/\r?\n/);
const problems = [];
const fail = (line, msg) => problems.push(`${file}:${line}: ${msg}`);

let start = 0;
if (raw[0] === "---") start = raw.indexOf("---", 1) + 1;
const lines = [];
let fence = false;
for (let i = start; i < raw.length; i++) {
	const text = raw[i];
	if (/^(```|````)/.test(text)) fence = !fence;
	lines.push({ n: i + 1, text, code: fence });
	if (fence) continue;
	const prose = text.replace(/`[^`]*`/g, "`");
	if (/[–—]/.test(prose)) fail(i + 1, "long dash");
	if (/[‘’“”]/.test(prose)) fail(i + 1, "curly quote");
}

const sections = [];
for (const l of lines) {
	if (!l.code && l.text.startsWith("## ")) sections.push({ title: l.text.slice(3).trim(), n: l.n, body: [] });
	else if (sections.length) sections.at(-1).body.push(l);
}
const find = (t) => sections.find((s) => s.title === t);
const bodyText = (s) => s.body.map((l) => l.text).join("\n");
const boxes = (ls) => ls.filter((l) => !l.code && BOX.test(l.text));

if (!lines.some((l) => !l.code && l.text.startsWith("# "))) fail(1, "no H1 title");
const howToRead = find("How to read this");
if (!howToRead) fail(1, 'no "## How to read this" section');
else for (const m of HOW_TO_READ) if (!bodyText(howToRead).includes(m)) fail(howToRead.n, `How to read this lacks "${m}"`);

const program = find("Program checklist");
if (!program) fail(1, 'no "## Program checklist" section');
else if (boxes(program.body).length === 0) fail(program.n, "Program checklist has no box");
const close = find("Close the program");
if (!close) fail(1, 'no "## Close the program" section');

const pi = sections.indexOf(program);
const ci = sections.indexOf(close);
const prs = pi === -1 || ci === -1 ? [] : sections.slice(pi + 1, ci);
if (prs.length === 0) fail(1, "no PR sections between Program checklist and Close the program");

for (const pr of prs) {
	const heads = [];
	for (const l of pr.body) {
		if (l.code) continue;
		const m = l.text.match(/^\*\*([^*]+)\*\*(.*)$/);
		if (m && SUB_BLOCKS.includes(m[1])) heads.push({ name: m[1], n: l.n, rest: m[2].trim(), lines: [] });
		else if (heads.length) heads.at(-1).lines.push(l);
	}
	const names = heads.map((h) => h.name);
	if (names.join("|") !== SUB_BLOCKS.join("|")) fail(pr.n, `${pr.title}: sub-blocks are [${names.join(", ")}], expected [${SUB_BLOCKS.join(", ")}]`);
	const block = (name) => heads.find((h) => h.name === name);
	const dep = block("Depends on.");
	if (dep && dep.rest === "") fail(dep.n, `${pr.title}: Depends on names nothing`);
	for (const name of ["Files.", "Build.", "You see.", "Verify.", "Merge."]) {
		const b = block(name);
		if (b && boxes(b.lines).length === 0) fail(b.n, `${pr.title}: ${name} has no box`);
	}
	const v = block("Verify.");
	if (v) {
		if (!v.rest.startsWith(RULE)) fail(v.n, `${pr.title}: Verify does not open with the rule`);
		const kinds = boxes(v.lines).map((l) => l.text.match(BOX)[1].split(".")[0]);
		for (const k of ["Unit", "Live", "Perf"]) if (!kinds.includes(k)) fail(v.n, `${pr.title}: Verify has no ${k} box`);
	}
	console.log(`${pr.title}  boxes=${boxes(pr.body).length}`);
}
if (ci !== -1) for (const s of sections.slice(ci + 1)) if (!s.title.startsWith("Appendix")) fail(s.n, `"## ${s.title}" after Close the program is not an appendix`);

console.log(`${prs.length} PR sections, ${problems.length} problems`);
for (const p of problems) console.error(p);
process.exit(problems.length ? 1 : 0);
