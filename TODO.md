- update wiki skill when concurrency and swiftui pages are done

## What the skill update must cover

Running list, appended as each gap is found while authoring the iOS pages.
Do this in ONE pass once the SwiftUI and concurrency pages are all green —
the spec should describe what the pages converged on, not what was predicted.

### `references/ios-topic-format.md`

- **The At a Glance infobox is missing from the spec.** §1 currently says
  "page-title, page-meta, then 1–3 ¶" with no infobox, which is why the
  first page shipped without one. Document the iOS row set:
  `Section` (breadcrumb to the section hub, `index.html`) ·
  `Domain` (breadcrumb to the landing page, `theory/index.html`) ·
  Type · Core idea · Decides · Signal words · Key APIs · Related.
- Note that a `Worked Example` section between Anti-Patterns and Pitfalls
  is allowed — used where a concrete case proves the abstract rule.

### `references/css-vocabulary.md`

- **Syntax highlighting is MANUAL and nothing says so.** The token classes
  are listed but not the rule that an author must wrap tokens by hand:
  `kw` keywords · `tp` types · `fn` function names · `cm` comments ·
  `nm` numbers · `st` strings. Plain text in a `<pre class="swift">`
  renders unhighlighted.
- **`.pitfall` is `display: flex`** — one row per pitfall, a short
  `.pitfall-bullet` marker plus the text in a sibling `<span>`. Nesting
  full-width divs inside one `.pitfall` makes the text overflow the
  callout. Needs a worked snippet.

### `references/architecture.md`

- Stale: describes the pre-refactor derivation rules. Since updated —
  a sections-layout category may now hold its own `index.html` landing
  page, and `manifest.ts` resolves that as the category `hubPath`.

### Already done (do not redo)

- Hub breadcrumbs: documented in `SKILL.md` and enforced by `check.ts`.
- `index.html` / `../index.html` are positional and never resolved:
  documented in `SKILL.md`.
