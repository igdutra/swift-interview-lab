---
name: wiki
description: Architecture, page formats, and workflow for this repo's static study wiki (wiki/). Use this skill BEFORE creating or editing ANY file under wiki/ — theory masterfiles, LeetCode walkthroughs, hub pages, reference pages, CSS, or the TypeScript toolchain in wiki/tools/. Also use it when the user mentions the wiki's nav, TOC, manifest, hub cards, page metadata, wiki styling/classes, adding a new study domain, or running/serving/validating the wiki. Even a one-line edit to a wiki page should go through this skill — the validator enforces rules that are easy to break blind.
---

# Study Wiki

A static, hand-authored HTML wiki (`wiki/`) driven by a **zero-dependency TypeScript toolchain** (`wiki/tools/`, run directly by Node 24 — never `npm install` anything). Disk is the source of truth: every page carries its own metadata block, and everything else (nav, hub grids, TOC, manifest) is generated from the files.

## The four commands

```bash
node wiki/tools/build.ts      # regenerate wiki/_shared/manifest.js from the pages
node wiki/tools/check.ts      # validate everything — MUST exit green before committing
node wiki/tools/serve.ts      # serve at http://localhost:5050
tsc -p wiki/tools/browser     # recompile _shared/nav.js + toc.js after editing browser/*.ts
```

Warnings print to **stderr** (`2>&1` to see them). Any page edit → run `build.ts` then `check.ts`; the freshness check fails if the committed manifest is stale. Generated files (`_shared/manifest.js`, `nav.js`, `toc.js`) are committed.

## How a page works

```html
<head>
  <title>{meta.title} · Theory Masterfile|Walkthrough Masterfile|Study Wiki</title>
  <script type="application/json" data-page-meta>
  { "title": "...", "nav": "...", "topics": ["..."], "blurb": "...",
    "difficulty": "E|M|H",   // walkthroughs only — forbidden elsewhere
    "order": 1 }             // optional within-group ordering
  </script>
  <link rel="stylesheet" href="{../ per depth}_shared/wiki.css">  <!-- + Google Fonts link -->
</head>
<body data-category="theory|walkthrough|reference|hub">
<nav id="topnav" class="topnav"></nav>            <!-- filled by nav.js -->
<div class="page">
  <main class="content"> <section id="…" data-toc-label="…"> … </section> … </main>
</div>
<script src="…_shared/manifest.js"></script>      <!-- this exact order -->
<script src="…_shared/nav.js"></script>
<script src="…_shared/toc.js"></script>
```

Everything else is derived from the file's location: category and section from the folder, role from the filename (`index.html` = hub, `*_overview_master.html` = overview, `LC{n}_master.html` = walkthrough). The TOC is generated at runtime from `section[id]` + `data-toc-label` (fallback: the section's `h2` text; reference pages use bare `h2[id]`). Never hand-write a `toc-col`. Hub pages use `class="content content-centered"`, no TOC, and a `<div data-hub-grid></div>` that renders their card grid from the manifest.

## Add a page

1. Scaffold: `node wiki/tools/new-page.ts theory <section> <file>_master.html` or `node wiki/tools/new-page.ts walkthroughs LC{n}_master.html`
2. Fill the `data-page-meta` block and write the sections — read the format reference first:
   - Theory page → `references/theory-format.md`
   - Walkthrough → `references/walkthrough-format.md`
3. Close the loop (cross-links both ways — the validator warns if missing):
   - Walkthrough §15 backref-card → parent theory page; theory §13 xref-card → the walkthrough; theory infobox `Walkthroughs` row → live link (replace any `(coming)` text).
   - Cards to walkthroughs that don't exist yet: `<span class="xref-card xref-coming">…</span>` (non-link), never a dead `<a href>`.
4. `node wiki/tools/build.ts && node wiki/tools/check.ts` — fix until green. The page appears in the nav and hub grids automatically; there is no registry to edit.

## Rules digest

- **Closed class vocabulary** — every class must exist in `wiki/_shared/wiki.css`; **no inline `style=""` ever** (validator error). Need a new visual? Extend `wiki.css` first. Full list + when-to-use: `references/css-vocabulary.md`.
- Solutions are **iterative-only** in the main section; recursion only as appendix contrast.
- No single-letter or abbreviated variable names anywhere (Swift, pseudocode, TS).
- Section `id`s must be unique; fragment links must resolve (validated).
- One `co-idea` callout per page maximum. Blue `xref-card` = "go practice"; purple `backref-card` = "go generalize".
- Walkthrough §11 code dry run follows the `/code-dry-run` trace format; the §6b spoken plan follows the six-pillar structure defined in the leetcode skill's `references/plan-comments.md`.

## Toolchain / scaling

`wiki/tools/wiki.config.ts` is the only file naming domains/categories/sections — **adding a new knowledge domain (e.g. design systems) = one config entry + a folder**; nav, hubs, and validation adapt automatically. The engine (`lib/`, `browser/`) must stay content-agnostic and dependency-free (erasable-syntax TS, `.ts` import extensions, hand-written Node typings in `lib/node-shims.d.ts`). Deep dive: `references/architecture.md`.
