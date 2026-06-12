# THEORY MASTERFILE STANDARD

What a canonical theory masterfile in `docs/` must contain. Based on (a) a full
inventory and critique of the five existing theory files, and (b) how Wikipedia,
MDN, cp-algorithms, and CLRS structure reference articles.

Files audited:

- `Graphs/graphs.html`
- `DynamicProgramming/dynamic_programming_topdown.html`
- `Greddy/greedy_master.html`
- `SlidingWindow/sliding_window.html`
- `Design/design–stateful–modeling.html`

---

## Part 1 — Inventory of the existing five files

| Section | graphs | dp_topdown | greedy | sliding_window | design |
|---|---|---|---|---|---|
| Sticky numbered TOC | ✓ | ✓ | ✓ | ✓ | ✓ |
| Lead paragraph + infobox | ✓ | ✓ | ✓ | ✓ | ✓ |
| Terminology / vocabulary section | ✓ (§2.1 table) | — | — | — | — |
| Mental model / core idea | ✓ | ✓ | ✓ | ✓ | ✓ (5 concepts) |
| Pseudocode | ✓ | partial | ✓ (shapes) | ✓ (§4.1) | — |
| Iterative (non-recursive) code | ✓ (§4.4) | — (recursion only) | ✓ | ✓ | ✓ |
| Swift translation | ✓ | ✓ | ✓ | ✓ (§4.2) | ✓ |
| Complexity analysis | ✓ (§12 table) | ✓ (§9, excellent) | ✓ (§D) | ✓ (§5, excellent) | ✓ (§6.4) |
| Common pitfalls | ✓ (inline boxes) | ✓ (§10) | **—** | ✓ (§7) | — |
| Recognition signals | ✓ (§10) | ✓ (§8 clue table) | ✓ (§C) | ✓ (§8) | ✓ (§6.1) |
| Edge cases | ✓ (§11) | — | — | ✓ (§9) | ✓ (§5) |
| Cheat sheet | ✓ (§12) | — | — | — | ✓ (§6) |
| Solo / practice problem | ✓ (§13) | — | — | — | ✓ (§4) |
| Links to LC walkthrough masterfiles | **none** | **none** | **none** | **none** | **none** |

## Part 2 — Critical evaluation

**Done well.** The shared visual identity (Wikipedia-style serif lead,
right-floating infobox, numbered TOC, color-coded pseudocode/Swift blocks) is
genuinely good and matches how Wikipedia structures a lead: definition first,
context second, notability third. The DP file's complexity section ("states ×
work per state") and sliding window's "why the nested while is still O(n)" are
the strongest analytical writing in the wiki. Pitfall boxes, where they exist,
are concrete and earned from real mistakes rather than generic.

**Inconsistent.** Section numbering is chaos: graphs runs 1–13, DP 1–10, greedy
mixes 1–3 with A–E, sliding window mixes 1–9 with appendices A/B. Page-meta
taglines differ ("Tech Companies Study" vs "Tech Companies Interview Prep").
File naming violates `STANDARDS.md` (`graphs.html` and `sliding_window.html`
lack the `_master` suffix; the Design file uses en-dashes in its filename; the
folder is misspelled "Greddy"). Each file duplicates ~250–380 lines of inline
CSS that has already drifted between files. The Design file is titled "Monday —
… Master File v3" with a "4.5–5.5 hours" time budget — a session plan
masquerading as a timeless reference — and it embeds ~500 lines of full
LC 346/348/341 solutions that belong in walkthrough files.

**Missing or wrong.** The single biggest gap, confirmed by grep: **not one
theory file contains a single hyperlink to any `LC*_master.html` walkthrough**.
Problems are name-dropped as plain text ("LC 638", "see LC 1235") even when the
walkthrough file exists one folder away — the DP footer literally says "Sibling
files: LC 638, LC 1235" without linking either. Greedy has **no pitfalls
section at all**, the only file missing one. The DP file presents top-down DP
exclusively through recursion and shows no runnable iterative (bottom-up)
counterpart — only a comparison table. Only graphs has a terminology table.
cp-algorithms ends every article with linked practice problems; MDN mandates a
"See also" section; this wiki has neither, anywhere.

## Part 3 — Required sections (canonical order)

### 1. Title block & infobox

The `page-title`, a consistent `page-meta` line, and a right-floating "At a
Glance" infobox carrying type, core idea, complexity, signal words, and the
linked worked examples — Wikipedia's infobox pattern applied to algorithms. It
lets a reader returning before an interview re-load the topic in ten seconds
without reading prose.

> *Existing files: handled **well** in all five visually, but inconsistently in
> content — only sliding window puts signal words in it, and only DP names its
> worked example.*

### 2. Wikipedia-style opening definition (lead)

One to three paragraphs before any heading: first sentence is a concise formal
definition, then context and why the technique matters, per Wikipedia's
lead-section rule that the lead must stand alone as a summary. No teasing, no
"in this file you will…" framing.

> *Handled **well** in graphs, DP, greedy, and sliding window; **poorly** in
> design, whose lead is welded to a "Monday" session plan rather than a
> timeless definition.*

### 3. Recognition signals — when to reach for it

A table mapping problem-statement phrases ("longest substring…", "merge
accounts that share…") to the technique, placed early because recognizing the
pattern is the skill being trained. This is the wiki's equivalent of MDN's
"use this when" guidance.

> *Handled **well** in all five (graphs §10, DP §8 clue table, greedy §C,
> sliding window §8, design §6.1), but its position wanders from early to dead
> last — it should be standardized near the top.*

### 4. Terminology decoder

A two-or-three-column table defining every term of art the page uses (vertex,
memoization, amortized, invariant, window validity…) in plain language with a
concrete example, so the reader never has to leave the page to parse a
sentence. Graphs §2.1 "Vocabulary you must know cold" is the model.

> *Handled **well** in graphs only; **not at all** in the other four — DP uses
> "optimal substructure," "state space," and "recurrence" with definitions
> scattered in prose, and sliding window never defines "validity" in one
> place.*

### 5. Mental model with a worked trace

The core idea explained through an analogy plus an ASCII diagram or
step-by-step trace of a tiny input, before any code. Wikipedia calls this
establishing context; cp-algorithms does it with its "fire spreading" BFS
metaphor.

> *Handled **well** in all five — this is the wiki's greatest strength (graphs'
> visited-set trace, greedy's coin-change counterexample, sliding window's
> three-variant blocks).*

### 6. Pseudocode primer

Language-neutral pseudocode of the canonical algorithm in a `pre.pseudo`
block, CLRS-style: the recurrence or loop structure stripped of Swift noise,
so the shape can be memorized independently of syntax.

> *Handled **well** in sliding window (§4.1) and graphs; **partially** in
> greedy (per-shape snippets, no single canonical primer); **poorly** in DP
> (the skeleton is Swift, not pseudocode); **not at all** in design.*

### 7. Iterative-only solution pattern

The canonical algorithm expressed with explicit loops and explicit
stacks/queues/tables — no recursion — because recursion hides the data
structure and risks stack overflow. For a DP page this means a runnable
bottom-up table-filling version; for graphs it means stack-based DFS as a
first-class citizen, not an afterthought.

> *Handled **well** in sliding window, greedy, and design (inherently
> iterative); **partially** in graphs (iterative DFS §4.4 exists but recursion
> leads); **not at all** in DP, which is recursion-only with bottom-up
> relegated to a comparison table with no code.*

### 8. Swift code translation

The same algorithm as compilable, idiomatic Swift with descriptive names and
inline comments explaining Swift-specific costs (`Array(s)` for O(1) indexing,
`removeFirst()` being O(n), dictionaries as memo keys). This is the MDN
"Syntax + Examples" pair: pseudocode defines, Swift demonstrates.

> *Handled **well** in all five — the annotated Swift template in sliding
> window §4.2 is the model.*

### 9. Variant / shape catalog

An enumerated breakdown of the technique's sub-patterns (fixed vs variable
window; the five greedy shapes; DFS vs BFS vs Union-Find), each with its own
when-to-use box. This is what turns one worked example into a transferable
family.

> *Handled **well** in greedy (§A, the best catalog), sliding window (§3), and
> graphs (§4–9); **well** in DP via the §8 problem-family table; **partially**
> in design (the five concepts serve this role but mix theory with the
> catalog).*

### 10. Complexity analysis

Not just big-O labels but the argument: why the nested loop is amortized
O(n), why memoized time = distinct states × per-state work, plus a reference
table per variant. CLRS treats analysis as inseparable from the algorithm; so
should these pages.

> *Handled **well** in DP (§9) and sliding window (§5) — the two best sections
> in the wiki; **adequately** as tables-without-argument in graphs (§12),
> greedy (§D), and design (§6.4).*

### 11. Common pitfalls

A red-boxed list of the specific bugs this technique invites (missing state
dimension, off-by-one on window shrink, forgetting the visited set), each with
the symptom and the fix. These are the highest-value lines in the wiki because
they encode the author's actual mistakes.

> *Handled **well** in DP (§10), sliding window (§7), and graphs (inline
> per-section boxes, though never aggregated); **not at all** in greedy — the
> only file with no pitfalls section — and design.*

### 12. Edge cases to verbalize

A checklist of inputs to name out loud before coding (empty input, single
element, all-same, disconnected node, k larger than n), derived from typical
constraints. Distinct from pitfalls: pitfalls are bugs in the code, edge cases
are gaps in the input space.

> *Handled **well** in graphs (§11), sliding window (§9), and design (§5);
> **not at all** in DP and greedy.*

### 13. Cheat sheet

A closing quick-reference: complexity table, decision guide ("see X → use Y"),
and a copy-paste Swift starting template. It serves the second visit — the
night-before-interview skim — the way an MDN compatibility table serves a
returning developer.

> *Handled **well** in graphs (§12) and design (§6); **not at all** in DP,
> greedy, and sliding window.*

### 14. Cross-reference section — linked LC walkthrough masterfiles

A "Demonstrated in practice" section that hyperlinks **by name** to the
specific walkthrough masterfiles applying this theory:

- `graphs.html` must link `LC721_master.html` (Accounts Merge — Union-Find /
  DFS components), `LC1257_master.html` (Smallest Common Region — parent-map
  ancestry), `LC1298_master.html` and `LC1928_master.html` (BFS / Dijkstra
  traversals).
- The DP page must link `LC638_master.html` and `LC1235_master.html`.

Crucially, those walkthrough files are **not free-form** — they follow their
own fixed standard (Overview · Reading the Problem · Mental Model · Solution ·
Theory Decoder · Complexity · Interview Notes, per `docs/STANDARDS.md`) — so
each link must say what the reader will find on arrival. Example:

> `LC721_master.html` — a constraint-driven walkthrough whose Theory Decoder
> section maps each line of the solution back to §8 Union-Find of this page.

This mirrors cp-algorithms' practice-problems footer and MDN's mandatory
"See also" section.

> *Handled **not at all** — the defining gap. Zero hyperlinks from any theory
> file to any walkthrough file exist today; the DP footer even names its
> siblings ("LC 638, LC 1235") as dead text.*

### 15. Solo practice problem (no solution)

One spoiler-free problem with hints and a self-check list, forcing retrieval
practice instead of recognition. The design file's "LC 251 — no solution
provided, here's why" treatment is the model.

> *Handled **well** in graphs (§13) and design (§4); **not at all** in DP,
> greedy, and sliding window.*

## Explicitly excluded from the standard

- **Embedded full walkthrough solutions.** Design's §3 and sliding window's
  Appendix A duplicate what walkthrough masterfiles are for — theory pages
  should link, not inline.
- **Session-scoped framing.** Day-of-week titles, time budgets, "v3" suffixes.
  Theory files are timeless references.

## Sources

- [Wikipedia: Manual of Style/Lead section](https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style/Lead_section)
- [Wikipedia: Manual of Style/Layout](https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style/Layout)
- [MDN Writing guidelines: Page structures](https://developer.mozilla.org/en-US/docs/MDN/Writing_guidelines/Page_structures)
- [MDN: Page types](https://developer.mozilla.org/en-US/docs/MDN/Writing_guidelines/Page_structures/Page_types)
- [MDN: Syntax sections](https://developer.mozilla.org/en-US/docs/MDN/Writing_guidelines/Page_structures/Syntax_sections)
- [cp-algorithms: Breadth-first search](https://cp-algorithms.com/graph/breadth-first-search.html)
