# Theory masterfile format

`theory/{section}/{topic}_master.html` · `<body data-category="theory">` · `<title>{title} · Theory Masterfile</title>`.
A theory page is a **timeless, Wikipedia-style reference** for one technique. No session framing (no "Monday", no time budgets, no version suffixes). No embedded full walkthrough solutions — link to walkthroughs instead.

## The 14 sections, in order

Canonical section ids/labels live in `wiki/tools/lib/templates.ts` (`THEORY_SECTIONS`) — the scaffolder emits them. Sequence:

| # | id | Section | What belongs there |
|---|----|---------|--------------------|
| 1 | `lead` | Title block, infobox, lead | `page-title`, `page-meta`, right-floating **"At a Glance"** infobox (type, core idea, complexity, signal words, linked worked examples, and a `Walkthroughs` row with **live links** — never dead text). Lead = 1–3 ¶: first sentence a concise formal definition, then context. Must stand alone. |
| 2 | `signals` | Recognition signals | Table mapping problem-statement phrases → the technique. Early, because recognizing the pattern is the trained skill. |
| 3 | `terminology` | Terminology decoder | `t-decoder` table defining every term of art in plain language with an example. |
| 4 | `mental-model` | Mental model | Analogy + ASCII diagram (`pre.ascii` + `.ascii-caption`) or tiny worked trace, before any code. |
| 5 | `pseudocode` | Pseudocode primer | Language-neutral canonical shape in `pre.pseudo` — memorizable independent of Swift. |
| 6 | `iterative` | Iterative-only pattern | Explicit loops + explicit stacks/queues/tables. No recursion as the primary form. |
| 7 | `swift` | Swift translation | Compilable idiomatic Swift in `pre.swift`, comments on Swift-specific costs (`Array(s)` O(1) indexing, `removeFirst()` O(n)). |
| 8 | `variants` | Variant catalog | `pattern-block` per sub-pattern, each with a when-to-use box. Sub-variants get ids + `data-toc-label` for TOC sub-entries. |
| 9 | `complexity` | Complexity analysis | The **argument**, not just labels: why the nested loop is amortized O(n). `t-cmx` table with why column. |
| 10 | `pitfalls` | Common pitfalls | `co-pitfall` box: specific bugs the technique invites, symptom + fix. |
| 11 | `edge-cases` | Edge cases | `t-edge` checklist of inputs to verbalize (empty, single, all-same, k>n…). Distinct from pitfalls: input-space gaps, not code bugs. |
| 12 | `cheatsheet` | Cheat sheet | Night-before skim: complexity table, "see X → use Y" decision guide, copy-paste Swift template. |
| 13 | `practice` | Demonstrated in practice | One `xref-card` per walkthrough applying this theory, each saying **what the reader lands on**. Planned-but-unwritten targets: `<span class="xref-card xref-coming">`. |
| 14 | `solo` | Solo problem | `solo-box`: one spoiler-free problem with `details.hint` ladder + checklist. No solution on the page. |

## Hub-overview exemption

`*_overview_master.html` files (a hub's decision layer + Swift toolbox) may reorder/merge these sections — a unified decision diagram can replace §2+§4+§8, real-Swift skeletons can replace §5–§7, a closing cheat sheet can absorb §9+§10. Everything else (class vocabulary, no inline styles, one `co-idea`, cross-links) still holds.

Model file: `theory/arrays/sliding_window_master.html`.
