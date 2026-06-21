# WALKTHROUGH MASTERFILE STANDARD

What a canonical LeetCode walkthrough masterfile (`LC{number}_master.html`) in
`wiki/walkthroughs/` must contain. Based on (a) coherence with the companion
`THEORY_MASTERFILE_STANDARD.md` — the two standards are a linked pair, and
(b) how LeetCode official editorials, NeetCode, AlgoMonster, and cp-algorithms
structure per-problem explainers.

**The pairing rule.** The theory standard (§14) requires every theory page to
hyperlink, by filename, to the walkthroughs demonstrating it. This standard
(§16) requires the reciprocal: every walkthrough must hyperlink back to its
parent theory page and describe what the reader lands on. A reader must be
able to navigate theory → walkthrough → theory without ever using the nav bar.

---

## Required sections (canonical order)

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

> *The CSS class `t-example` is defined in `wiki/_shared/wiki.css`.*

### 3. Reading the Problem — insights from the constraints

Per-phrase insight blocks ("'transitively' → connected components") closing
with a clue table mapping every statement phrase and constraint bound to the
design decision it forces. This is the house's signature section and the
skill the wiki exists to train: constraint → decision.

> *The model is LC721; LC1928's "maxTime ≤ 1000 → state expansion is tractable"
> shows constraint-bounds reasoning.*

### 4. Edge case inventory

A dedicated table of boundary inputs derived from the constraints — empty
input, single element, duplicates, disconnected pieces, already-optimal input
— each with the expected behavior and which line of the solution handles it.
Distinct from pitfalls: these are gaps in the input space, not bugs in code,
and they feed directly into the clarifying questions of §6a.

### 5. Try It Yourself First — graduated hints

A spoiler-guarded ladder of hints (constraint hint → pattern hint → structure
hint) inviting an attempt before the solution is visible, mirroring the theory
standard's solo-problem section (§15 there). NeetCode's "draw it out, look
after 15–20 minutes" doctrine: retrieval beats recognition.

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
Six pillars, in strict order:

1. **Pattern** — name the technique in one sentence and justify why it fits:
   *"token-based parser — for + if because each character drives one decision."*
2. **Sequence** — draw the algorithm as a mini prose trace: walk the happy
   path step by step before naming any variable. This is where the algorithm
   lives; conditions and state follow from it.
3. **State** — list every variable with its type and role, derived from the
   sequence just stated ("I need `hasSeenEqual` *because* the sequence shows
   the `=` character drives two different behaviors").
4. **Conditions / Loops** — write pseudocode-level if/for skeleton: name the
   loop, name every branch, name every commit point.
5. **Walk** — trace one or two concrete inputs through *your step-4 conditions*
   character by character. This is a bug-catch pass, not an output check — the
   goal is to catch wrong branch ordering before touching real code.
6. **Complexity** — state expected time and space upfront.

**Sequence before State before Conditions — mandatory.**
The sequence (step 2) reveals what needs tracking; State (step 3) names it;
Conditions (step 4) codify it. Jumping to data structures or pseudocode before
the sequence is stated skips the reasoning. Pin conditions as precisely as they
will be coded:

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

**Canonical example — LC42 Trapping Rain Water** (`LC42_master.html` §5b):

> "This is a two-pointer converging problem — left and right pointers closing inward, because water at any position depends on the tallest wall to its left AND the tallest wall to its right simultaneously. That dual dependency rules out sliding window, which only looks in one direction.
>
> The sequence goes like this: I start both pointers at the outer edges. At each step I look at which side has the smaller running max — that side is the bottleneck, so I commit water there, advance that pointer inward, and update its running max. I keep doing that until the pointers meet. That's it — one pass, no arrays.
>
> From that sequence, three pieces of state surface: a left pointer and a right pointer for the two ends, a maxWallLeft and maxWallRight for the running maxima on each side — seeded from the outermost bars because those are walls, not water — and a totalWater accumulator.
>
> The condition that drives every step is: if maxWallLeft is less than maxWallRight, the left wall is the bottleneck. Even if the right side gets taller later, it's already taller now, so it will never be the limiting factor for the left pointer. Commit water at the left pointer — min wall minus current height — advance leftPointer, update maxWallLeft. Otherwise mirror on the right.
>
> Let me walk the canonical example: heights are [0,1,0,2,1,0,1,3,2,1,2,1]. leftPointer=0, rightPointer=11, maxWallLeft=0, maxWallRight=1. maxWallLeft < maxWallRight so advance left: leftPointer=1, maxWallLeft=max(0,1)=1, water += 1−1=0. Now both maxes are equal — go right: rightPointer=10, maxWallRight=max(1,2)=2, water += 2−2=0. Continue… eventually at leftPointer=5, maxWallLeft=2, maxWallRight=3, water += 2−0=2. That matches the expected output of 6.
>
> Time is O(n) — each bar visited at most once. Space is O(1) — four scalar variables, no arrays."

### 7. Approach selection rationale

Why this pattern and not its neighbors: a short versus-comparison naming the
plausible alternatives (DFS vs Union-Find; DP vs greedy; window vs prefix
sums), why each loses or ties here, and what signal in the problem decides it.
AlgoMonster's "when and why, not just how" applied per problem.

> *The model is LC721's DFS-vs-Union-Find table with an "interview fit" row.*

### 8. Data structure choice and justification

For each structure in the solution: what it stores, why this structure and not
the weaker one (map-with-counts, not set; min-heap keyed by fee, not by time),
and its cost profile in Swift specifically (`removeFirst()` is O(n);
`Array(s)` for O(1) indexing). The interviewer's "why a dictionary?" must
already be answered on the page.

### 9. Pseudocode dry run

Language-neutral pseudocode of the chosen approach, then a step-by-step trace
on one concrete small input — a state table per iteration showing pointers,
counters, and structures evolving, with the aha-moment steps highlighted. This
is the LeetCode-editorial "Algorithm" section plus cp-algorithms' worked
mechanics.

> *The model is LC76 §7's character-by-character trace with matchedCount evolution.*

### 10. Swift solution — iterative only

The full compilable solution in idiomatic Swift: explicit stacks/queues/tables
instead of recursion, descriptive production-quality names (no `l`, `r`,
`res`), and comments stating invariants rather than narrating lines. One
primary solution; alternates live in a Solutions appendix in the same format.

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

> *The model is LC76 §10.*

### 12. Question → Code Map

A two-column table tying each clarifying/framework question from §6 to the
exact line or construct it became in the solution ("Do I shrink on VALID or
INVALID?" → `while matchedCount == required.count`). It is the bridge between
the spoken plan and the implementation, and it makes the simulation auditable.

### 13. Complexity table

Time and space per solution variant, with a "why" column carrying the
argument, plus a bottleneck row naming the irreducible cost (LC721: "the
mandatory output sort dominates — no algorithm can avoid it"). Matches the
theory standard's rule: the argument, not just the big-O label.

### 14. Follow-up question bank

The interviewer's second act: 3–6 realistic follow-ups, each with a
two-to-four-sentence spoken answer and, where the follow-up is itself a known
problem, a link to that walkthrough.

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

### 15. Theory Decoder

The problem-specific instantiation of the general theory: each concept the
solution borrowed (Union-Find, path compression, augmented-state Dijkstra)
explained *as used here*, with the general form deferred to the parent theory
page via link. It answers "what theory did I just use?" without re-teaching
the theory file.

> *The model is LC721's decoder — Union-Find ops table, the email-graph
> modeling insight, the DFS-vs-UF comparison.*

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

---

## Explicitly excluded from the standard

- **Inlined sibling-problem content.** Bridges to related problems (LC341 →
  LC251) become a follow-up-bank entry or a See-also link, never an embedded
  mini-walkthrough.
- **Re-taught general theory.** The Theory Decoder instantiates; the parent
  theory file teaches. A decoder block that could be pasted into the theory
  page unchanged is in the wrong file.
- **Recursive solutions as the primary form.** Recursion may appear in an
  appendix for contrast, but the canonical solution is iterative.

---

## Sources

- [LeetCode Articles (official editorials)](https://leetcode.com/articles/)
- [AlgoMonster: structured pattern-based interview prep](https://algo.monster/)
- [AlgoMonster Flowchart: decision tree for LeetCode problems](https://algo.monster/flowchart)
- [NeetCode: How to use NeetCode effectively](https://neetcode.io/courses/lessons/how-to-use-neetcode-effectively)
- [cp-algorithms: Breadth-first search (practice-problems footer model)](https://cp-algorithms.com/graph/breadth-first-search.html)
- [How to Use Pseudocode Effectively in Technical Interviews — AlgoCademy](https://algocademy.com/blog/how-to-use-pseudocode-effectively-in-technical-interviews-a-comprehensive-guide/)
- Companion: [`THEORY_MASTERFILE_STANDARD.md`](./THEORY_MASTERFILE_STANDARD.md) (§14 cross-reference ↔ §16 back-reference pairing)
- Companion: [`PLAN_COMMENT_STANDARD.md`](./PLAN_COMMENT_STANDARD.md)
