# Walkthrough masterfile format

`walkthroughs/LC{number}_master.html` · `<body data-category="walkthrough">` · `<title>{title} · Walkthrough Masterfile</title>` · meta must declare `difficulty`.
A walkthrough instantiates a theory on one problem. It must let a reader navigate theory → walkthrough → theory without the nav bar (the **pairing rule** with theory §13).

## The 15 sections, in order

Canonical ids/labels: `wiki/wiki.config.ts` (the `walkthrough` entry in `pageTypes[]`). Model file: `content/walkthroughs/LC76_master.html` (fullest) or `LC209_master.html` (cleanest).

| # | id | Section | What belongs there |
|---|----|---------|--------------------|
| 1 | `lead` | Restatement + infobox | **"Problem at a Glance"** infobox rows in order: Difficulty · Pattern · Tools · Key insight · Time/Space · **Theory (clickable link, mandatory)**. Restate the problem in your own words (never copied), then a `t-example` I/O table (canonical case, degenerate case, no-answer case), then the one twist sentence. |
| 2 | `reading` | Reading the problem | Per-phrase `co-insight` blocks ("'transitively' → connected components") closing with a `t-clue` table: phrase/constraint → the design decision it forces. The house's signature section. |
| 3 | `edge-cases` | Edge case inventory | `t-edge` table: boundary input → expected behavior → which line handles it. Feeds §5a's questions. |
| 4 | `hints` | Try it yourself first | `details.hint` ladder: constraint hint → pattern hint → structure hint. |
| 5 | `simulation` | Interview simulation | `sim-block`. **5a Clarifying questions** (`sim-q`/`sim-a`, each answer with its design consequence after →). **5b Say-out-loud plan** (`speech` block): the six pillars in strict order — Pattern, Sequence, State, Conditions/Loops, Walk, Complexity. Sequence before State before Conditions. Pin the validity condition, the invalid condition, loop direction + record placement, and the invariant. Canonical six-pillar definition: leetcode skill `references/plan-comments.md`; canonical example: LC42 §5b. |
| 6 | `approach` | Why this approach | Versus-comparison vs the plausible neighbors (window vs prefix sums…), why each loses, what signal decides. |
| 7 | `structures` | Data structures | Per structure: what it stores, why not the weaker one, Swift cost profile. |
| 8 | `dryrun` | Pseudocode dry run | `pre.pseudo` then a milestone-level trace (`pre.dry`) on a small input. |
| 9 | `swift` | Swift solution | Iterative-only, production-quality names, comments state invariants. Alternates → a solution appendix (`solution-block`). |
| 10 | `code-dry-run` | Code dry run | Debugger-level trace of the real Swift code on the canonical input, in the `/code-dry-run` skill's exact format (32-dash dividers, init block, per-iteration blocks, `YES/NO →` condition lines, `↑` annotations, repeat cap, `State:` snapshots, `RESULT` block). One plain `pre.dry`, no syntax spans. |
| 11 | `qmap` | Question → code map | `t-qmap` table: each §5 question → the exact construct it became. |
| 12 | `complexity` | Complexity | Per-variant table with the argument + a bottleneck row. |
| 13 | `followups` | Follow-up bank | 3–6 `followup` entries with spoken answers. First one is always the production-readiness optimization nudge: "Before you push this to production — any improvements?" |
| 14 | `decoder` | Theory decoder | Each borrowed concept explained *as used here*; the general form stays in the theory page (link, don't re-teach). |
| 15 | `parent` | Parent theory | `backref-card` to the parent theory masterfile, describing what the reader lands on (its numbered sections). Extra relationships (a second theory this problem touches, a sibling problem) = a `u-note-gap` "See also:" line, not another card wall. |

Excluded: inlined sibling-problem content, re-taught theory, recursion as the primary solution.
