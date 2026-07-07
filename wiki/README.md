# Study Wiki

Static, hand-authored HTML wiki: algorithm theory masterfiles, LeetCode
walkthrough masterfiles, and interview reference pages. No framework, no
`npm install` — a zero-dependency TypeScript toolchain run directly by
Node 24 builds, validates, and serves everything.

> Editing a page from a Claude Code session? Load the repo-local `wiki`
> skill (`.claude/skills/wiki/`) first — it carries the page formats,
> class vocabulary, and add-a-page workflow in detail.

## Commands

```bash
node wiki/tools/build.ts      # regenerate _shared/manifest.js from the pages
node wiki/tools/check.ts      # validate everything — must be green before committing
node wiki/tools/serve.ts      # http://localhost:5050
node wiki/tools/new-page.ts   # scaffold a page (run with no args for usage)
tsc -p wiki/tools/browser     # recompile _shared/nav.js + toc.js after editing browser/*.ts
```

Validator warnings go to stderr — run `node wiki/tools/check.ts 2>&1` to see them.

## Layout

| Path | What it is |
| --- | --- |
| `theory/`, `walkthroughs/`, `reference/` | Content pages (authored HTML) |
| `index.html` | Root hub (authored shell; card grid rendered at runtime) |
| `_shared/wiki.css` | **Authored** — the closed class vocabulary, single stylesheet |
| `_shared/manifest.js` | **Generated** by `build.ts` — the site manifest (committed) |
| `_shared/nav.js`, `_shared/toc.js` | **Generated** by `tsc` from `tools/browser/*.ts` (committed) |
| `tools/` | Toolchain: build, check, serve, scaffolder, config, templates |

`_shared/` intentionally holds both authored and generated assets: it is
"everything a page loads in the browser". The generated files carry a
`GENERATED` banner — edit their sources, never the outputs.

## How it works — disk is truth

Every page embeds its own metadata:

```html
<script type="application/json" data-page-meta>
{ "title": "…", "nav": "…", "topics": ["…"], "blurb": "…" }
</script>
```

Category, section, and role are derived from the file's location and name
(`index.html` = hub, `*_overview_master.html` = overview,
`LC{n}_master.html` = walkthrough). `build.ts` scans the pages and writes
`_shared/manifest.js`; at runtime `nav.js` renders the top nav and hub card
grids from that manifest, and `toc.js` generates the sticky table of
contents from the page's own `section[id]` / `h2[id]` anchors. There is no
hand-maintained registry, nav, TOC, or hub grid anywhere.

`wiki/tools/wiki.config.ts` is the only file naming domains, categories,
and sections — a new knowledge domain is one config entry plus a folder.

## Add a page

1. `node wiki/tools/new-page.ts theory <section> <file>_master.html`
   (or `walkthroughs LC{n}_master.html`, or `reference <file>.html`)
2. Fill the `data-page-meta` block and write the sections — formats live in
   `.claude/skills/wiki/references/`.
3. Cross-link both ways (walkthrough ↔ parent theory); the validator warns
   about unclosed loops.
4. `node wiki/tools/build.ts && node wiki/tools/check.ts` — must be green.

The page appears in the nav and hub grids automatically.
