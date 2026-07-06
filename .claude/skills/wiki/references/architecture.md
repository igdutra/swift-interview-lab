# Toolchain architecture

Zero-dependency TypeScript, run directly by Node 24 type stripping. Hard constraints: **no npm packages ever**; erasable-syntax-only TS (no enums/namespaces/parameter properties); imports between tools use explicit `.ts` extensions; no single-letter/abbreviated identifiers. Node typings are hand-written in `lib/node-shims.d.ts` — extend that file if a new Node API is needed, don't install @types/node.

## Layout

```
wiki/tools/
  wiki.config.ts   the ONLY file naming domains/categories/sections (display order = array order)
  build.ts         scan → extract → derive → sort → write _shared/manifest.js
  check.ts         validator (errors exit 1; warnings on stderr)
  new-page.ts      scaffolder            serve.ts   static server :5050 (301s dir→dir/)
  lib/  types.ts scan.ts extract.ts derive.ts manifest.ts templates.ts node-shims.d.ts
  browser/  nav.ts toc.ts manifest-globals.d.ts tsconfig.json   → compiled to _shared/*.js
```

`tsc --noEmit -p wiki/tools` type-checks the tools; `tsc -p wiki/tools/browser` regenerates `_shared/nav.js` + `toc.js` (committed, marked GENERATED).

## Data flow — disk is truth

1. **Declared** per page (`data-page-meta` JSON in head): `title, nav, topics[], blurb`, `difficulty` (walkthroughs only), `order` (optional). Unknown keys = error.
2. **Derived** from location (`lib/derive.ts`): category/section from folders via config; role — `index.html`→hub (root→home), `*_overview_master.html`→overview, else deep-dive/page; `LC(\d+)_`→problemNumber; depth.
3. **Manifest** (`_shared/manifest.js`, `const WIKI_MANIFEST`): config tree (sections with `hubPath` + ordered `pagePaths`) + path-keyed `pages` map. Sorting: theory sections = overview first, then `order`, then filename; walkthroughs = LC number ascending, CUSTOM last; reference = `order`.
4. **Browser**: `nav.js` derives the wiki root from its own `script.src`, finds the current page by exact manifest-key suffix match, renders grouped dropdown nav + `#hub` (root) + `[data-hub-grid]` (hub pages). `toc.js` builds the TOC from `section[id]`/`data-toc-label` (`h2[id]` fallback); opt out with `data-no-toc` on body.

## Validator checks (check.ts)

Errors: exactly one parseable meta block with required fields; no unknown keys; difficulty iff walkthrough; `data-category` matches role; folders map to config; each configured section has a hub; walkthrough filename pattern + unique LC numbers; manifest freshness (string-compare regenerated vs committed); link + fragment integrity (both directions, incl. images); ≥2 TOC anchors on non-hub pages, unique ids, sections have h2 or `data-toc-label`; wiring at correct depth (css + manifest/nav/toc order, topnav placeholder, no pages.js, no static toc-col); zero inline styles.
Warnings: classes not in wiki.css; close-the-loop reciprocity (a card A→B needs B to link back to A, or to any page of A's theory section); `<title>` begins with meta title.

## Adding a new domain (e.g. design systems)

1. Add a `domains[]` entry in `wiki.config.ts` (categories: folder, layout `"sections"|"flat"`, `pageBodyCategory`, `requiresDifficulty`, sections or flatSort/filenamePattern).
2. Create the folder(s) + hub `index.html` per section (thin shell: meta block, lead, `data-hub-grid`).
3. `build.ts` + `check.ts`. Nav renders domain label rows automatically once a second domain exists — zero engine changes.

The whole kit (tools/ + wiki.css + this skill) is copyable to another repo: copy, rewrite `wiki.config.ts`, done.
