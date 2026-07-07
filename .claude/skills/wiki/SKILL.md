---
name: wiki
description: Architecture, page formats, and workflow for this repo's static study wiki (wiki/). Use this skill BEFORE creating or editing ANY file under wiki/ — theory masterfiles, LeetCode walkthroughs, hub pages, reference pages, CSS, or the TypeScript engine in wiki/engine/. Also use it when the user mentions the wiki's nav, TOC, manifest, hub cards, page metadata, wiki styling/classes, adding a new study domain or page type, or running/serving/validating the wiki. Even a one-line edit to a wiki page should go through this skill — the validator enforces rules that are easy to break blind.
---

# Study Wiki

A static, hand-authored HTML wiki driven by a **zero-dependency TypeScript engine** (`wiki/engine/`, run directly by Node 24 — never `npm install` anything). Disk is the source of truth: every page carries its own metadata block, and everything else (nav, hub grids, TOC, manifest) is generated from the files.

## Layout — four things at the wiki root

```
wiki/
  wiki.config.ts    the ONE file you edit to shape the wiki: page types, domains, categories, sections
  content/          the actual pages (index.html, theory/, walkthroughs/, reference/) — the web root
  static/           everything a page loads: wiki.css (authored) + generated/{manifest,nav,toc}.js
  engine/           the black box — copy it verbatim to reuse; never edit to add content
    commands/       build.ts  check.ts  serve.ts  new-page.ts   (the 4 commands you run)
    lib/            engine internals incl. paths.ts (the single source of truth for every path)
    browser/        nav.ts + toc.ts, compiled to static/generated/*.js
```

To stand up a wiki on a new topic in a fresh repo: **copy `engine/` + `static/wiki.css`, write a new `wiki.config.ts`, run build.** No engine edits.

## The four commands

```bash
node wiki/engine/commands/build.ts    # regenerate static/generated/manifest.js from the pages
node wiki/engine/commands/check.ts    # validate everything — MUST exit green before committing
node wiki/engine/commands/serve.ts    # serve at http://localhost:5050
tsc -p wiki/engine/browser            # recompile static/generated/nav.js + toc.js after editing browser/*.ts
```

Warnings print to **stderr** (`2>&1` to see them). Any page edit → run `build.ts` then `check.ts`; the freshness check fails if the committed manifest is stale. Generated files (`static/generated/{manifest,nav,toc}.js`) are committed.

## How a page works

```html
<head>
  <title>{meta.title} · {pageType.metaLabel}</title>
  <script type="application/json" data-page-meta>
  { "title": "...", "nav": "...", "topics": ["..."], "blurb": "...",
    "difficulty": "E|M|H",   // categories that requireDifficulty (walkthroughs) — forbidden elsewhere
    "order": 1 }             // optional within-group ordering
  </script>
  <link rel="stylesheet" href="{../ per depth}static/wiki.css">  <!-- + Google Fonts link -->
</head>
<body data-category="theory|walkthrough|reference|hub">
<nav id="topnav" class="topnav"></nav>            <!-- filled by nav.js -->
<div class="page">
  <main class="content"> <section id="…" data-toc-label="…"> … </section> … </main>
</div>
<script src="…static/generated/manifest.js"></script>   <!-- this exact order -->
<script src="…static/generated/nav.js"></script>
<script src="…static/generated/toc.js"></script>
```

Depth prefixes: pages served from `content/` as the web root, so `content/index.html` → `/` (no prefix), `content/theory/arrays/x.html` → `/theory/arrays/x.html` (`../../`). Category and section come from the folder; role from the filename (`index.html` = hub, `*_overview_master.html` = overview, `LC{n}_master.html` = walkthrough). The TOC is generated at runtime from `section[id]` + `data-toc-label` (fallback: the section's `h2` text; flat/reference pages use bare `h2[id]`). Never hand-write a `toc-col`. Hub pages use `class="content content-centered"`, no TOC, and a `<div data-hub-grid></div>` that renders their card grid from the manifest.

## Add a page

1. Scaffold: `node wiki/engine/commands/new-page.ts theory <section> <file>_master.html` or `node wiki/engine/commands/new-page.ts walkthroughs LC{n}_master.html`. Run it with no args to see the usage built from the current config.
2. Fill the `data-page-meta` block and write the sections — read the format reference first:
   - Theory page → `references/theory-format.md`
   - Walkthrough → `references/walkthrough-format.md`
3. Close the loop (cross-links both ways — the validator warns if missing):
   - Walkthrough §15 backref-card → parent theory page; theory §13 xref-card → the walkthrough; theory infobox `Walkthroughs` row → live link (replace any `(coming)` text).
   - Cards to walkthroughs that don't exist yet: `<span class="xref-card xref-coming">…</span>` (non-link), never a dead `<a href>`.
4. `node wiki/engine/commands/build.ts && node wiki/engine/commands/check.ts` — fix until green. The page appears in the nav and hub grids automatically; there is no registry to edit.

## Rules digest

- **Closed class vocabulary** — every class must exist in `wiki/static/wiki.css`; **no inline `style=""` ever** (validator error). Need a new visual? Extend `wiki.css` first. Full list + when-to-use: `references/css-vocabulary.md`.
- Solutions are **iterative-only** in the main section; recursion only as appendix contrast.
- No single-letter or abbreviated variable names anywhere (Swift, pseudocode, TS).
- Section `id`s must be unique; fragment links must resolve (validated).
- One `co-idea` callout per page maximum. Blue `xref-card` = "go practice"; purple `backref-card` = "go generalize".
- Walkthrough §11 code dry run follows the `/code-dry-run` trace format; the §6b spoken plan follows the six-pillar structure defined in the leetcode skill's `references/plan-comments.md`.

## Toolchain / scaling

`wiki/wiki.config.ts` is the only file naming **page types, domains, categories, and sections** — the engine (`lib/`, `browser/`) knows none of these names, it iterates the config:

- **New study domain** (e.g. design systems) = one `domains[]` entry + a folder under `content/`. Nav, hubs, and validation adapt automatically.
- **New page type** (e.g. an electrical-engineering topic with its own sections) = one `pageTypes[]` entry declaring its `layout` + section skeleton, then point a category at it via `pageType: "…"`. No engine code changes — the scaffolder reads the skeleton from config.

The engine must stay content-agnostic and dependency-free (erasable-syntax TS, `.ts` import extensions, hand-written Node typings in `lib/node-shims.d.ts`). Every filesystem path and browser-URL prefix lives in `engine/lib/paths.ts` — change a folder name there and the whole toolchain (plus the `<head>` wiring the validator enforces) follows. Deep dive: `references/architecture.md`.
