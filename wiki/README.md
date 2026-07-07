# Study Wiki

Static, hand-authored HTML wiki: algorithm theory masterfiles, LeetCode
walkthrough masterfiles, and interview reference pages. No framework, no
`npm install` — a zero-dependency TypeScript engine run directly by Node 24
builds, validates, and serves everything.

> Editing a page from a Claude Code session? Load the repo-local `wiki`
> skill (`.claude/skills/wiki/`) first — it carries the page formats,
> class vocabulary, and add-a-page workflow in detail.

## Layout

Four things live at the wiki root, and the split is the whole point:

| Path | What it is |
| --- | --- |
| `wiki.config.ts` | **You edit this.** Declares page types, domains, categories, sections. The only content-aware file. |
| `content/` | The actual pages — `index.html`, `theory/`, `walkthroughs/`, `reference/`. Served as the web root. |
| `static/` | Everything a page loads: `wiki.css` (authored) + `generated/{manifest,nav,toc}.js` (build outputs, `// GENERATED` banner). |
| `engine/` | **The black box.** Copy it verbatim to reuse; never edit it to add content. |

Inside `engine/`: `commands/` (the 4 things you run) · `lib/` (internals, incl.
`paths.ts` — the single source of truth for every path) · `browser/` (`nav.ts`
+ `toc.ts`, compiled to `static/generated/*.js`).

## Commands

```bash
node wiki/engine/commands/build.ts    # regenerate static/generated/manifest.js from the pages
node wiki/engine/commands/check.ts    # validate everything — must be green before committing
node wiki/engine/commands/serve.ts    # http://localhost:5050
node wiki/engine/commands/new-page.ts # scaffold a page (run with no args for usage)
tsc -p wiki/engine/browser            # recompile static/generated/nav.js + toc.js after editing browser/*.ts
```

Validator warnings go to stderr — run `node wiki/engine/commands/check.ts 2>&1` to see them.

## How it works — disk is truth

Every page embeds its own metadata:

```html
<script type="application/json" data-page-meta>
{ "title": "…", "nav": "…", "topics": ["…"], "blurb": "…" }
</script>
```

Category, section, and role are derived from the file's location and name
(`index.html` = hub, `*_overview_master.html` = overview,
`LC{n}_master.html` = walkthrough). `build.ts` scans `content/` and writes
`static/generated/manifest.js`; at runtime `nav.js` renders the top nav and
hub card grids from that manifest, and `toc.js` generates the sticky table
of contents from the page's own `section[id]` / `h2[id]` anchors. There is
no hand-maintained registry, nav, TOC, or hub grid anywhere.

`serve.ts` serves `content/` at the web root and `static/` under `/static/`,
so page URLs stay clean (`/theory/…`) while their `../../static/…` links
still resolve.

## Config — page types and domains

`wiki.config.ts` is the only file naming structure, and the engine iterates it:

- **`pageTypes[]`** — the body shapes a page can take. Each has a `layout`
  (`"sections"` or flat h2) and a section skeleton the scaffolder emits.
  Adding a new kind of page (say, an electrical-engineering topic) is one
  entry here — no engine edit.
- **`domains[]`** — the knowledge trees. A new study domain is one entry plus
  a folder under `content/`. A category points at a page type via `pageType: "…"`.

To stand up a wiki on a new topic in a fresh repo: **copy `engine/` +
`static/wiki.css`, write a new `wiki.config.ts`, create `content/`, run build.**

## Add a page

1. `node wiki/engine/commands/new-page.ts theory <section> <file>_master.html`
   (or `walkthroughs LC{n}_master.html`, or `reference <file>.html`)
2. Fill the `data-page-meta` block and write the sections — formats live in
   `.claude/skills/wiki/references/`.
3. Cross-link both ways (walkthrough ↔ parent theory); the validator warns
   about unclosed loops.
4. `node wiki/engine/commands/build.ts && node wiki/engine/commands/check.ts` — must be green.

The page appears in the nav and hub grids automatically.
