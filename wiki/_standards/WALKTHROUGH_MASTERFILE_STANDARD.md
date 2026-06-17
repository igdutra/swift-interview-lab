# WALKTHROUGH MASTERFILE STANDARD

What a canonical LeetCode walkthrough masterfile (`LC{number}_master.html`) in
`wiki/walkthroughs/` must contain. Based on (a) a full inventory and
critique of the twelve existing walkthrough files, (b) coherence with the
companion `THEORY_MASTERFILE_STANDARD.md` — the two standards are a linked
pair, and (c) how LeetCode official editorials, NeetCode, AlgoMonster, and
cp-algorithms structure per-problem explainers.

**The pairing rule.** The theory standard (§14) requires every theory page to
hyperlink, by filename, to the walkthroughs demonstrating it. This standard
(§16) requires the reciprocal: every walkthrough must hyperlink back to its
parent theory page and describe what the reader lands on. A reader must be
able to navigate theory → walkthrough → theory without ever using the nav bar.

Files audited:

- `Done/` — `LC251_master.html`, `LC30_hard_problem.html`, `LC341_master.html`, `LC76_hard_problem.html`
- `Graph/` — `LC1257_master.html`, `LC638_master.html`, `LC721_master.html`
- `New/` — `LC1235_master.html`, `LC1298_master.html`, `LC1928_master.html`, `LC631_master.html`, `LC68_master.html`

---

## Part 1 — Inventory of the existing twelve files

Two generations exist. The newer eight (Graph/, New/) follow a tight
`1 Overview · 2 Reading the Problem · 3 Mental Model · A Solutions ·
B Theory Decoder · C Complexity · (D Interview Notes)` template. The older
four (Done/) predate it and freelance.

| Section | Done/ ×4 | Graph/ ×3 | New/ ×5 |
|---|---|---|---|
| Infobox + plain-language overview | ✓ | ✓ | ✓ |
| Reading the Problem (constraint insights) | ✓ (3 of 4; LC251 skips it) | ✓ | ✓ |
| Mental model | ✓ (ad hoc) | ✓ | ✓ |
| Interview Simulation (clarifying Qs) | ✓ (all 4) | — | — |
| Say-out-loud pre-code plan (monologue) | — | — | — |
| Edge case inventory | — | — | — |
| Try-it-yourself / graduated hints | — | — | ✓ (LC1298 only) |
| Pseudocode + dry-run trace | ✓ (strong; LC76 §7 full trace) | ✓ (pseudocode, thin traces) | partial (LC1928: none) |
| Swift solution (iterative) | ✓ | ✓ | ✓ |
| Question → Code Map | ✓ (LC76 only) | — | — |
| Theory / Vocabulary Decoder | — (LC341 §7 comes close) | ✓ | ✓ |
| Complexity table | ✓ (LC30 deep dive is the model) | ✓ | ✓ |
| Interview Notes ("what to say out loud") | — | — | ✓ (D section) |
| Follow-up question bank | — (LC341 §6 bridge is the embryo) | — | — |
| Link back to parent theory file | **none** | **none** | **none** |

## Part 2 — Critical evaluation

**Consistent and good.** The newer template's spine (Overview → Reading the
Problem → Mental Model → Solutions → Theory Decoder → Complexity) is sound and
matches LeetCode's editorial canon (Intuition → Algorithm → Implementation →
Complexity Analysis, per approach). "Reading the Problem — Insights from the
Constraints" is the house's best invention: every phrase of the statement
becomes a named design decision with a clue table (LC721's "transitively =
connected components" is the model). Solutions consistently pair pseudocode
with iterative, idiomatic Swift (LC721's stack DFS with "mark before pushing"
commentary; LC1928's hand-rolled min-heap). Complexity sections explain *why*,
not just the big-O (LC721's "the sort is unavoidable" bottleneck row; LC30's
per-solution deep dive with pinned variable definitions).

**Inconsistent.** Section lettering wobbles (1-2-3 + A-D, with Done/ files
inventing 4–8); the decoder is "Theory Decoder" in six files and "Vocabulary
Decoder" in LC638; the infobox is titled "Problem at a Glance" in five files
and "Quick Reference" in seven; the D "Interview Notes" section exists only in
New/ files — the Graph/ trio has no interview-facing content at all; file
naming splits between `_master.html` and `_hard_problem.html`; the status
folders conflate status (Done, New) with topic (Graph). Dry-run depth swings
from LC76's exhaustive character-by-character trace to LC1928's zero traces.

**Missing.** Four gaps recur across all twelve files. (1) **No back-reference
links**: grep confirms zero `href`s to any theory file — LC721 never links
`graphs.html` even while using its Union-Find section wholesale. (2) **No
edge case inventory**: edge cases get 0–1 passing mentions per file, despite
the theory standard requiring an "Edge Cases to Verbalize" section in every
theory page. (3) **No say-out-loud plan**: the Done/ files' Interview
Simulation is excellent Q&A but never delivers the pre-code monologue (pattern
named → data structures named → steps walked → complexity stated upfront);
the New/ files' "Interview Notes" are post-hoc tips, not a practiced script.
(4) **No follow-up question bank**: nothing anticipates the interviewer's
"now make it O(1) space" second act.

**Redundant.** LC341 embeds three full solutions plus a long "Bridge to
LC 251" section that duplicates LC251_master.html's job — bridges should be
links, not inlined content. Done/ files re-teach sliding-window theory inline
(LC76 §6 "The Same Family") that belongs in — and now duplicates —
`sliding_window.html`. Every file carries ~230–370 lines of duplicated inline
CSS that has already drifted between generations.

## Part 3 — Required sections (canonical order)

### 1. Title block & infobox

The `page-title` (`LC {number} — {Problem Name}`), a consistent `page-meta`
line, and a right-floating **"Problem at a Glance"** infobox: difficulty,
pattern, tools, key insight in one sentence, and a link to the parent theory
file. It is the ten-second re-load for a reader returning before an interview.

**Required infobox rows (in order):** Difficulty · Pattern · Tools · Key insight · Time / Space · Theory.

The **Theory row is mandatory and must be a clickable hyperlink** — not plain text. It is the fastest navigation path back to the parent theory page and the first thing a reader sees on reload. Format:

```html
<div class="infobox-row">
  <div class="infobox-k">Theory</div>
  <div class="infobox-v mono">
    <a href="../theory/{folder}/{filename}.html">{filename}.html</a>
  </div>
</div>
```

This is the reciprocal of the theory page's **Walkthroughs infobox row**, which must also be clickable links (not plain text). Together they form the fastest bidirectional entry point between theory and walkthrough — visible before the reader scrolls at all.

> *Existing files: handled **well** visually in all twelve, but the title is
> inconsistent ("Problem at a Glance" ×5 vs "Quick Reference" ×7) and no
> infobox links its parent theory page.*

### 2. Problem restatement (plain language)

One paragraph restating the problem in the author's own words — never copied
from LeetCode — followed immediately by a `t-example` I/O table (at least two
rows; three when a "no answer" edge case is meaningful), then the one twist
sentence that defines the problem's difficulty. Wikipedia's lead-section rule
applies: it must stand alone.

**I/O table format** (`class="t-example"`):

| Input | Output | Why |
|-------|--------|-----|
| `exact input` | `exact output` | one-line explanation of which rule produces it |

Include at least: the canonical example, a minimal/degenerate case, and (where
applicable) the "no answer" case. The table lives between the opening prose and
the twist sentence — not after it.

> *Updated standard — all four active walkthrough files now carry the I/O
> table. The CSS class `t-example` is defined in `wiki/_shared/wiki.css`.*

### 3. Reading the Problem — insights from the constraints

Per-phrase insight blocks ("'transitively' → connected components") closing
with a clue table mapping every statement phrase and constraint bound to the
design decision it forces. This is the house's signature section and the
skill the wiki exists to train: constraint → decision.

> *Handled **well** in eleven of twelve (the model is LC721; LC1928's
> "maxTime ≤ 1000 → state expansion is tractable" shows constraint-bounds
> reasoning); **not at all** in LC251, which jumps straight to architecture.*

### 4. Edge case inventory

A dedicated table of boundary inputs derived from the constraints — empty
input, single element, duplicates, disconnected pieces, already-optimal input
— each with the expected behavior and which line of the solution handles it.
Distinct from pitfalls: these are gaps in the input space, not bugs in code,
and they feed directly into the clarifying questions of §6a.

> *Handled **not at all** — the single most uniform gap; edge cases get 0–1
> passing mentions per file across all twelve.*

### 5. Try It Yourself First — graduated hints

A spoiler-guarded ladder of hints (constraint hint → pattern hint → structure
hint) inviting an attempt before the solution is visible, mirroring the theory
standard's solo-problem section (§15 there). NeetCode's "draw it out, look
after 15–20 minutes" doctrine: retrieval beats recognition.

> *Handled **well** in LC1298 only ("⚠️ Try It Yourself First" with graduated
> hints); **not at all** in the other eleven.*

### 6. Interview Simulation

A first-person script practiced out loud, mimicking the real tech-company
interview flow. The interviewer has already stated the problem — the script
starts at the candidate's first words. Two mandatory subsections, in order:

**6a. Clarifying Questions.** The exact questions asked before touching
anything: input constraints, edge cases (drawn from §4), expected output
format, time-vs-space priorities, and assumptions needing confirmation —
written as natural spoken questions with the interviewer's likely answers and
the design consequence of each answer ("→ so a set is not enough, I need
counts").

**6b. Say-Out-Loud Plan.** The verbal plan delivered before writing a single
line of code, as a natural spoken monologue — not pseudocode, not a checklist.
Five pillars, in strict order:

1. **Pattern** — name the pattern recognized and why it fits this problem.
2. **Conditions** — pin the governing conditions before naming any data
   structure (see rule below).
3. **Data structures** — name each structure and justify it in terms of the
   conditions just stated ("I need matchedCount *because* comparing maps each
   step would be O(k)").
4. **Walk** — step through the approach at high level, referencing the
   conditions by name.
5. **Complexity** — state expected time and space upfront.

**The conditions come before the data structures and the walk — mandatory.**
The conditions determine what you need to track and how the loop runs, so
stating them first lets every subsequent sentence be motivated rather than
asserted. State them as precisely as they will be coded:

- the validity condition — what "valid" means for this problem, stated as
  exactly as it will appear in code — "the window contains every character of
  t at its required multiplicity";
- the invalid condition — "the window goes invalid the instant a count drops
  below its requirement";
- the loop's direction and the record placement that the conditions force —
  "the loop runs *while valid*, record *inside* it before each eviction";
- the invariant the loop structure maintains — "every pass through that loop
  holds a valid window";
- any transition/stop condition between phases or inputs — "I stop scanning
  the first array and jump to the second when ⟨condition⟩".

A plan that names the pattern and then jumps to data structures before stating
its conditions is incomplete: the validity condition, the invalid condition,
and the invariant are where sliding-window, stack, and two-array problems are
actually won or lost — and they are what justify the structures chosen.

> *Handled **well (half of it)** in the four Done/ files — LC76's "Step 1
> Clarifying questions / Step 2 Framework questions" is the model for 6a, with
> each answer annotated with its design consequence. But **no file anywhere
> contains 6b**: the say-out-loud monologue does not exist; the New/ files'
> "D — Interview Notes" are post-hoc talking points, and the Graph/ trio
> (LC1257, LC638, LC721) has no interview-facing section at all.*

### 7. Approach selection rationale

Why this pattern and not its neighbors: a short versus-comparison naming the
plausible alternatives (DFS vs Union-Find; DP vs greedy; window vs prefix
sums), why each loses or ties here, and what signal in the problem decides it.
AlgoMonster's "when and why, not just how" applied per problem.

> *Handled **well** where multiple solutions exist (LC721's DFS-vs-Union-Find
> table with an "interview fit" row is the model; LC341's three-solution
> comparison); **partially** elsewhere — single-solution files assert the
> pattern without naming what it beat.*

### 8. Data structure choice and justification

For each structure in the solution: what it stores, why this structure and not
the weaker one (map-with-counts, not set; min-heap keyed by fee, not by time),
and its cost profile in Swift specifically (`removeFirst()` is O(n);
`Array(s)` for O(1) indexing). The interviewer's "why a dictionary?" must
already be answered on the page.

> *Handled **partially** everywhere — the justifications exist but are
> scattered through insight blocks (LC76's "a set is not enough", LC1928's
> heap-keying discussion) rather than collected in one place; never a
> dedicated section.*

### 9. Pseudocode dry run

Language-neutral pseudocode of the chosen approach, then a step-by-step trace
on one concrete small input — a state table per iteration showing pointers,
counters, and structures evolving, with the aha-moment steps highlighted. This
is the LeetCode-editorial "Algorithm" section plus cp-algorithms' worked
mechanics.

> *Handled **well** in the Done/ generation (LC76 §7's character-by-character
> trace with matchedCount evolution is the model; LC30 and LC341 carry dry
> runs in appendices); **poorly** in the newer files — pseudocode is present
> but traces are thin, and LC1928 has no trace at all.*

### 10. Swift solution — iterative only

The full compilable solution in idiomatic Swift: explicit stacks/queues/tables
instead of recursion, descriptive production-quality names (no `l`, `r`,
`res`), and comments stating invariants rather than narrating lines. One
primary solution; alternates live in a Solutions appendix in the same format.

> *Handled **well** in all twelve — iterative discipline is real (LC721's
> stack DFS with "mark before pushing, not after popping"; LC1928's
> hand-rolled min-heap struct) and naming is consistently descriptive.*

### 11. Code dry run — the Swift solution, traced

Immediately **after** the Swift solution: a full, debugger-level execution
trace of the final Swift code — the real variable names, the real branches —
on the problem's canonical example input, in the format of the
`/code-dry-run` skill (`.claude/skills/code-dry-run/SKILL.md`). It is distinct
from §9 by design: the pseudocode dry run before the solution compresses to
milestone steps to teach the idea; this section is exhaustive and verifies the
code the reader just saw. The canonical input must be small enough that the
exhaustive trace stays readable; long gotcha-free stretches are handled by
the repeat cap below, never by ad-hoc skipping.

The format contract, extracted from the skill:

- **Header block** fenced by 32-dash dividers (`────────────────────────────────`)
  carrying three lines: `/code-dry-run`, `Problem: LC {n} — {name}`,
  `Input: {exact input}`.
- **Initialization block**: the function name, then every variable with its
  starting value, one per line, `=` signs aligned within the block.
- **One divider-fenced block per loop iteration**, headed by the loop state
  (e.g. `right=5  rightCharacter="C"`), tracing every variable mutation as it
  happens and showing full collection states after each mutation.
- **Condition checks** on one line as
  `<check with values inline>? YES/NO → <branch taken>` —
  e.g. `windowCounts["A"](1) == required(1)? YES → matchedCount = 1`.
- **Nested loop iterations** (e.g. shrink steps) indented one level, each
  labeled (`SHRINK ITERATION 2`).
- **`↑` inline annotations** for non-obvious behavior: why a no-op happened,
  why validity broke, why a removal was free. No-ops are traced explicitly or
  absorbed into a repeat-cap block — never silently dropped.
- **Repeat cap**: 3+ consecutive gotcha-free no-op iterations (same branches,
  no tracked-variable changes) collapse into one divider-fenced block — the
  header names the skipped range (`right=6 … right=8`), the shared reasoning
  appears once, and the block ends with an explicit
  `… continue this until <condition>` line. Allowed only once the pattern's
  first occurrence has been traced in full; never across a variable mutation,
  an inner-loop entry/exit, or anything worth a `↑` note.
- **`State:` snapshot** after each eventful iteration showing the key
  variables (window contents, counters, pointers, best-so-far).
- **Closing divider-fenced `RESULT` block** with the final values and the
  exact return.

In the page, the entire trace is one plain-text `<pre class="dry">` block
(introduced by the usual `code-label` header); no syntax-highlighting spans
inside — the structure of the trace *is* the formatting.

> *Handled **well** in LC76 §10, which is the model; previously the section
> did not exist anywhere.*

### 12. Question → Code Map

A two-column table tying each clarifying/framework question from §6 to the
exact line or construct it became in the solution ("Do I shrink on VALID or
INVALID?" → `while matchedCount == required.count`). It is the bridge between
the spoken plan and the implementation, and it makes the simulation auditable.

> *Handled **well** in LC76 only — its §4 is the single best section in any
> walkthrough file; **not at all** in the other eleven.*

### 13. Complexity table

Time and space per solution variant, with a "why" column carrying the
argument, plus a bottleneck row naming the irreducible cost (LC721: "the
mandatory output sort dominates — no algorithm can avoid it"). Matches the
theory standard's rule: the argument, not just the big-O label.

> *Handled **well** in all twelve — the C-section tables are uniformly
> present; LC30's per-solution deep dive with pinned variable definitions and
> LC721's bottleneck row are the models.*

### 14. Follow-up question bank

The interviewer's second act: 3–6 realistic follow-ups, each with a
two-to-four-sentence spoken answer and, where the follow-up is itself a known
problem, a link to that walkthrough. LC341's "Bridge to LC 251" shows the
instinct; it should be a standard section, not an inlined essay.

**Ordering rule — optimization first, always.** The first follow-up must be
phrased as: *"Before you push this to production — can you see any improvements
you'd make?"* This is the interviewer's most reliable first move after a
working solution: a nudge toward constant-factor or asymptotic optimizations
("drop the dictionary for a fixed-size array", "reduce to O(1) space", "avoid
the second pass"). Framing it as a production-readiness question rather than
an abstract "make it faster" prompt is more realistic and trains the reflex of
immediately scanning for space/time tradeoffs once correctness is reached.
Subsequent follow-ups may then address constraint changes, generalization, and
alternate techniques in any order.

> *Handled **not at all** as a section — zero files have one; LC341 §6 is the
> only embryo and it duplicates LC251's file instead of linking it.*

### 15. Theory Decoder

The problem-specific instantiation of the general theory: each concept the
solution borrowed (Union-Find, path compression, augmented-state Dijkstra)
explained *as used here*, with the general form deferred to the parent theory
page via link. It answers "what theory did I just use?" without re-teaching
the theory file.

> *Handled **well** in the eight newer files (LC721's decoder — Union-Find
> ops table, the email-graph modeling insight, the DFS-vs-UF comparison — is
> the model, though it currently re-teaches rather than links); **not at
> all** as a section in the Done/ four (LC341 §7 "What Algorithm Is Each
> Solution Using?" is the nearest equivalent).*

### 16. Back-reference — parent theory masterfile

A closing "Parent theory" section that hyperlinks **by filename** to the
theory masterfile this problem demonstrates — `LC721_master.html` →
`../../Graphs/graphs.html`, `LC638_master.html` and `LC1235_master.html` →
`../../DynamicProgramming/dynamic_programming_topdown.html`, `LC76_hard_problem.html`
→ `../../SlidingWindow/sliding_window.html` — and, where useful, to the
specific numbered section used (graphs.html §8 Union-Find).

The theory file is **not free-form**: it follows the THEORY MASTERFILE
STANDARD (15 numbered sections), so the back-reference must say what the
reader lands on — e.g. "graphs.html is the canonical graph-theory reference;
following this link you'll find the terminology decoder (§4), the iterative
DFS/BFS patterns this solution instantiates (§7), the complexity arguments
(§10), and the cheat sheet (§13). Its own cross-reference section (§14) links
back to this walkthrough." This is the reciprocal of theory standard §14 and
the other half of the theory ↔ walkthrough navigation loop.

> *Handled **not at all** — the defining gap, mirroring the theory files:
> grep confirms zero hyperlinks from any walkthrough to any theory file; the
> walkthroughs name-drop their theory ("Union-Find", "Dijkstra") while the
> reference sits one folder away, unlinked.*

## Explicitly excluded from the standard

- **Inlined sibling-problem content.** Bridges to related problems (LC341 →
  LC251) become a follow-up-bank entry or a See-also link, never an embedded
  mini-walkthrough.
- **Re-taught general theory.** The Theory Decoder instantiates; the parent
  theory file teaches. A decoder block that could be pasted into the theory
  page unchanged is in the wrong file.
- **Recursive solutions as the primary form.** Recursion may appear in an
  appendix for contrast, but the canonical solution is iterative.

## Sources

- [LeetCode Articles (official editorials)](https://leetcode.com/articles/)
- [Unpacking LeetCode Editorials for Deeper Understanding](https://www.oreateai.com/blog/beyond-the-code-unpacking-leetcode-editorials-for-deeper-understanding/7692055abf62001fe89128fb588ad09d)
- [AlgoMonster: structured pattern-based interview prep](https://algo.monster/)
- [AlgoMonster Flowchart: decision tree for LeetCode problems](https://algo.monster/flowchart)
- [NeetCode: How to use NeetCode effectively](https://neetcode.io/courses/lessons/how-to-use-neetcode-effectively)
- [cp-algorithms: Breadth-first search (practice-problems footer model)](https://cp-algorithms.com/graph/breadth-first-search.html)
- Companion: [`THEORY_MASTERFILE_STANDARD.md`](./THEORY_MASTERFILE_STANDARD.md) (§14 cross-reference ↔ §16 back-reference pairing)
