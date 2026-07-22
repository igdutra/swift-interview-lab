# iOS topic page format

`ios/{framework}/{category}/{section}/{topic}_master.html` · `<body data-category="ios-topic">` · `<title>{title} · iOS Topic</title>`.

An iOS topic page is a **timeless reference for one piece of framework or platform knowledge** — SwiftUI identity, ARC, actor isolation, `URLSession` error handling. It is the framework counterpart to the LeetCode `theory` type, and it exists because framework knowledge is shaped differently from algorithm knowledge:

- it is **API-shaped** — signatures and modifiers matter, so there is a dedicated §4;
- it is **correction-shaped** — the material is naturally "here is the version that looks right and misbehaves, here is why, here is the fix", so anti-patterns get their own §6 rather than being buried in pitfalls;
- it has **no complexity analysis and no solo problem** — those are algorithm concerns.

## Voice

Open with why the **topic** matters, never why a company cares about it. No interview framing ("an interviewer will expect…"), no session framing, no rehearsal scripts. A reader who has never seen this repo, at a different company, a year from now, should find it correct and useful.

## The 9 sections, in order

Canonical ids/labels live in `wiki/wiki.config.ts` (the `ios-topic` entry in `pageTypes[]`) — the scaffolder emits them from that skeleton. Sections that genuinely do not apply may be omitted; do not pad them with filler.

| # | id | Section | What belongs there |
|---|----|---------|--------------------|
| 1 | `lead` | Title block, infobox, lead | `page-title`, `page-meta`, a right-floating **"At a Glance"** infobox (see below), then 1–3 ¶ opening with a concise definition. Must stand alone. At most one `co-idea` callout, carrying the single most important claim. |
| 2 | `mental-model` | Mental model | The one-paragraph intuition to carry away after every API name is forgotten — e.g. *parent proposes a size, child chooses its own, parent positions it*. Analogy or ASCII diagram (`pre.ascii` + `.ascii-caption`) welcome, before any code. |
| 3 | `signals` | When it applies | The recognition layer: the product situations that call for this topic, and the ones that look similar but do not. Table where there is a real mapping. |
| 4 | `api` | The API | Types, initializers, and modifiers with their **real signatures** in `pre.swift`. The section with no `theory`-type equivalent. Note version availability (iOS 16 vs 17+) inline where it differs. |
| 5 | `patterns` | Patterns that work | The recommended shapes, each with a short rationale. Positive guidance only — corrections belong in §6 so a reader can scan for "what should I do" without wading through failures. |
| 6 | `antipatterns` | Anti-patterns — and the fix | Wrong-then-right pairs: the broken version, **why the framework behaves that way**, then the correction. Mark with `// ❌` and `// ✅` inside `pre.swift`. The explanation is the point; a pair without a reason is not worth including. |
| 7 | `pitfalls` | Pitfalls & gotchas | Sharp edges that are not full anti-patterns: silent no-ops, version differences, simulator-vs-device behaviour, facts worth memorizing. `co-pitfall` box. |
| 8 | `related` | Related topics | Cross-links to adjacent pages, each saying what the reader lands on. The source material cross-references heavily (capture lists span language and memory; `@MainActor` spans concurrency and architecture) — keep those connections navigable. Use `xref-card`, or `<span class="xref-card xref-coming">` for pages not yet written. |
| 9 | `sources` | Sources | Provenance, so a claim can be re-verified later. Be honest about how load-bearing a citation is; if a section rests on one blog post, say so. |

## The "At a Glance" infobox

Every topic page opens with one, placed **before** `.lead` inside `§1`. It is
the only in-page way back up the tree, so the first two rows are mandatory:

```html
<div class="infobox">
  <div class="infobox-title">At a Glance</div>
  <div class="infobox-row"><div class="infobox-k">Section</div>
    <div class="infobox-v"><a href="index.html">SwiftUI Fundamentals</a></div></div>
  <div class="infobox-row"><div class="infobox-k">Domain</div>
    <div class="infobox-v"><a href="theory/index.html">SwiftUI Theory</a></div></div>
  …
</div>
```

| Row | Content |
|---|---|
| **Section** (required) | `index.html` — the sibling section hub |
| **Domain** (required) | the category landing page; write it qualified (`theory/index.html`), the build resolves it to `../index.html` |
| Type | what kind of thing this is — "framework model", "screen-level API", "execution model" |
| Core idea | the one-sentence version |
| *(topic-specific)* | e.g. `Decides`, `Two kinds`, `Hard rule`, `The hazard`, `Deprecated` — pick rows that earn their place |
| Signal words | the phrases that should make a reader open this page |
| Key APIs | `mono` class, ` · ` separated |
| Related | plain text or links to adjacent pages |

Do **not** copy the LeetCode theory rows (Time, Space, Requires sorted?,
Walkthroughs) — those are algorithm-shaped and do not apply.

## Optional extra section

A **Worked Example** section may sit between Anti-Patterns (§6) and Pitfalls,
where one concrete case proves the abstract rule. Used on
`view_identity_master.html` for the list-row conditional question. Give it
`id="worked-example"` and renumber the sections after it.

## Differences from the LeetCode `theory` type

These `theory` rules do **not** apply here:

- no iterative-only rule (it governs algorithm solutions);
- no difficulty tag — `requiresDifficulty` is false, and declaring one is a validation error;
- no walkthrough backref contract (§13/§15 cross-link pairing);
- no complexity analysis, no solo practice problem.

Everything wiki-wide still holds: closed class vocabulary, no inline `style=""`, unique section ids, resolving fragment links, one `co-idea` per page, links written as bare filenames.

Model files: `ios/swiftui/theory/fundamentals/view_identity_master.html` (fullest — includes the optional Worked Example) or `ios/concurrency/theory/patterns/cancellation_master.html` (cleanest).
