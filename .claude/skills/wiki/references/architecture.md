# Engine architecture

Zero-dependency TypeScript, run directly by Node 24 type stripping. Hard constraints: **no npm packages ever**; erasable-syntax-only TS (no enums/namespaces/parameter properties); imports between engine files use explicit `.ts` extensions; no single-letter/abbreviated identifiers. Node typings are hand-written in `lib/node-shims.d.ts` — extend that file if a new Node API is needed, don't install @types/node.

## The four wiki-root folders

```
wiki/
  wiki.config.ts   the ONLY file naming page types / domains / categories / sections (array order = display order)
  content/         authored pages; served as the web root (so "/theory/…" needs no "/content" prefix)
  static/          wiki.css (authored) + generated/{manifest,nav,toc}.js (build outputs)
  engine/          the black box, copyable verbatim to a new repo
    commands/  build.ts  check.ts  serve.ts  new-page.ts
    lib/  paths.ts types.ts scan.ts extract.ts derive.ts manifest.ts templates.ts node-shims.d.ts
    browser/  nav.ts toc.ts manifest-globals.d.ts tsconfig.json   → compiled to static/generated/*.js
```

`tsc --noEmit -p wiki/engine` type-checks the commands + lib + config; `tsc -p wiki/engine/browser` regenerates `static/generated/nav.js` + `toc.js` (committed, marked GENERATED).

## paths.ts — one source of truth for every path

`engine/lib/paths.ts` defines `WIKI_ROOT`, the folder-name constants (`CONTENT_DIR`, `STATIC_DIR`, `GENERATED_DIR`), the absolute roots (`CONTENT_ROOT`, `STATIC_ROOT`, `GENERATED_ROOT`), the on-disk file paths (`MANIFEST_PATH`, `WIKI_CSS_PATH`), and the browser-URL suffixes a page puts in its `<head>` (`CSS_HREF`, `MANIFEST_SRC`, `NAV_SRC`, `TOC_SRC`). Every command and `templates.ts` imports from here, so the paths the tools use and the paths the validator enforces move in lockstep. The one path it can't own: `NAV_SCRIPT_SUFFIX` in `browser/nav.ts`, because that file compiles to plain browser JS with no module system — it mirrors `NAV_SRC` as a literal; keep the two in sync.

## Page types — body shapes as config, not code

`wiki.config.ts` declares `pageTypes[]`. Each entry = `{ identifier, layout: "sections"|"flat", metaLabel, sections: SectionSkeleton[] }`. A category references one by `pageType: "…"`. `new-page.ts` looks up the type and renders `renderArticleBody` (sections layout) or `renderFlatBody` (flat/h2 layout) from the skeleton — no hardcoded section lists anywhere in the engine. Adding a new kind of page is a config entry, never an engine edit.

## Data flow — disk is truth

1. **Declared** per page (`data-page-meta` JSON in head): `title, nav, topics[], blurb`, `difficulty` (only where the category `requiresDifficulty`), `order` (optional). Unknown keys = error.
2. **Derived** from content-relative location (`lib/derive.ts`): category/section from folders via config; role — `index.html`→hub (root→home), `*_overview_master.html`→overview, else deep-dive/page; `LC(\d+)_`→problemNumber; depth.
3. **Manifest** (`static/generated/manifest.js`, `const WIKI_MANIFEST`): config tree (sections with `hubPath` + ordered `pagePaths`) + path-keyed `pages` map. Sorting: theory sections = overview first, then `order`, then filename; walkthroughs = LC number ascending, CUSTOM last; reference = `order`.
4. **Browser**: `nav.js` derives the wiki root from its own `script.src` (stripping `NAV_SCRIPT_SUFFIX`), finds the current page by exact manifest-key suffix match, renders grouped dropdown nav + `#hub` (root) + `[data-hub-grid]` (hub pages). `toc.js` builds the TOC from `section[id]`/`data-toc-label` (`h2[id]` fallback); opt out with `data-no-toc` on body.

## Serving — two roots, one clean URL space

`serve.ts` serves `content/` at the web root and `static/` under `/static/…`. A request whose first segment is `static` resolves against `WIKI_ROOT`; everything else against `CONTENT_ROOT`. So `/theory/…` and `/static/generated/nav.js` share one origin, exactly matching what a page's relative links (`../../static/…`) expect.

## Validator checks (check.ts)

Errors: exactly one parseable meta block with required fields; no unknown keys; difficulty iff the category requires it; `data-category` matches role; folders map to config; each configured section has a hub; walkthrough filename pattern + unique LC numbers; manifest freshness (string-compare regenerated vs committed); link + fragment integrity (both directions, incl. images — links into the `static/` tree are skipped here since the wiring block validates them); ≥2 TOC anchors on non-hub pages, unique ids, sections have h2 or `data-toc-label`; wiring at correct depth (css + manifest/nav/toc order via the `paths.ts` URL constants, topnav placeholder, no pages.js, no legacy `_shared/`, no static toc-col); zero inline styles.
Warnings: classes not in wiki.css; close-the-loop reciprocity (a card A→B needs B to link back to A, or to any page of A's theory section); `<title>` begins with meta title.

## Adding a new domain or page type

- **Domain** (e.g. design systems): add a `domains[]` entry (categories: `folder`, `layout` `"sections"|"flat"`, `pageType`, `pageBodyCategory`, `requiresDifficulty`, sections or flatSort/filenamePattern). Create the folder(s) under `content/` + hub `index.html` per section (thin shell: meta block, lead, `data-hub-grid`). Nav renders domain-label rows automatically once a second domain exists.
- **Page type**: add a `pageTypes[]` entry with its `layout` + section skeleton, then set a category's `pageType` to its identifier.
- Then `build.ts` + `check.ts`. Zero engine changes for either.

To reuse the whole kit in another repo: copy `engine/` + `static/wiki.css`, rewrite `wiki.config.ts`, create `content/`, run build. Done.
