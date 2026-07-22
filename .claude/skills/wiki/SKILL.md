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
  content/          the actual pages — the web root, nested by domain:
                      index.html
                      leetcode/{theory,walkthroughs,reference}/
                      ios/{swiftui,concurrency}/theory/
  static/           everything a page loads: wiki.css (authored) + generated/{manifest,nav,toc}.js
  engine/           the black box — copy it verbatim to reuse; never edit to add content
    commands/       build.ts  check.ts  serve.ts  new-page.ts   (the 4 commands you run)
    lib/            engine internals incl. paths.ts (the single source of truth for every path)
    browser/        nav.ts + toc.ts, compiled to static/generated/*.js
```

To stand up a wiki on a new topic in a fresh repo: **copy `engine/` + `static/wiki.css`, write a new `wiki.config.ts`, run build.** No engine edits.

## The four commands

Run from `wiki/` (the npm scripts live in `wiki/package.json`):

```bash
npm run build     # regenerate static/generated/manifest.js + resolve every authored link
npm run check     # validate everything — MUST exit green before committing
npm run serve     # serve at http://localhost:5050
npm run browser   # recompile static/generated/nav.js + toc.js after editing browser/*.ts
npm run new       # scaffold a page (see "Add a page")
```

Warnings print to **stderr** (`2>&1` to see them). Any page edit → `npm run build` then `npm run check`; the freshness check fails if the committed manifest is stale. Generated files (`static/generated/{manifest,nav,toc}.js`) are committed.

**Start the server with the Bash tool's `run_in_background: true`** — never detach with `&`, which orphans it to `launchd` where nobody can find it. (Also in the repo's `CLAUDE.md`.)

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
<body data-category="theory|walkthrough|reference|ios-topic|hub">
<nav id="topnav" class="topnav"></nav>            <!-- filled by nav.js -->
<div class="page">
  <main class="content"> <section id="…" data-toc-label="…"> … </section> … </main>
</div>
<script src="…static/generated/manifest.js"></script>   <!-- this exact order -->
<script src="…static/generated/nav.js"></script>
<script src="…static/generated/toc.js"></script>
```

Category and section come from the folder; role from the filename (`index.html` = hub, `*_overview_master.html` = overview, `LC{n}_master.html` = walkthrough). The TOC is generated at runtime from `section[id]` + `data-toc-label` (fallback: the section's `h2` text; flat/reference pages use bare `h2[id]`). Never hand-write a `toc-col`. Hub pages use `class="content content-centered"`, no TOC, and a `<div data-hub-grid></div>` that renders their card grid from the manifest.

## Links carry identity, not paths — read this before writing any `href`

**Write a link as the target's bare filename.** Never write `../`, never write a folder name:

```html
<a href="sliding_window_master.html">Sliding Window</a>          <!-- ✅ -->
<a href="sliding_window_master.html#pitfalls">…</a>              <!-- ✅ fragments fine -->
<a href="../leetcode/theory/arrays/sliding_window_master.html">…</a>  <!-- ❌ never -->
```

`npm run build` rewrites each one into the correct relative path for the page it sits in, by looking the filename up against the real file tree (`engine/lib/links.ts` + `resolve-links.ts`). The same applies to `wiki.css` and the generated scripts — their `../` depth is derived, so scaffolded pages stay correct at any nesting depth.

**Why it matters:** renaming a folder is a one-word edit in `wiki.config.ts` plus `npm run build`. Every affected link updates itself; there is nothing to find and replace. Hardcoding a path silently opts out of that.

Three rules the build enforces:

- **Filenames are globally unique.** If two pages share one, the build fails and prints the shortest qualifying suffix to use instead. Qualify with the *minimum* extra path, never the full one. This bites most on hub links once a second domain exists: `theory/index.html` and `fundamentals/index.html` are ambiguous across `swiftui/` and `concurrency/`, so write `concurrency/theory/index.html`. The build then resolves it to the correct relative path (`../index.html`), and leaves an already-correct relative path alone on later runs.
- **`index.html` is exempt** — it is positional ("the hub beside this page"), not an identity. Leave it bare.
- Resolution is idempotent: re-running the build on already-resolved HTML is a no-op.

## Add a page

1. Scaffold: `npm run new <category> <section> <file>_master.html` (sections-layout) or `npm run new walkthroughs LC{n}_master.html` (flat). Run `npm run new` with no args to see the usage built from the current config — it lists nested categories too (e.g. `swiftui-theory`), and creates the target folder if it doesn't exist.
2. Fill the `data-page-meta` block and write the sections — read the format reference first:
   - LeetCode theory page → `references/theory-format.md`
   - LeetCode walkthrough → `references/walkthrough-format.md`
   - iOS topic page → `references/ios-topic-format.md`
3. Close the loop where the page type calls for it (LeetCode only — see below).
4. `npm run build && npm run check` — fix until green. The page appears in the nav and hub grids automatically; there is no registry to edit.

**Filename → role**, invisible in config and easy to trip over: within a sections-layout category, `*_overview_master.html` becomes role `overview` and everything else `deep-dive`. Hub grids group by that role, so a page only lands under an "Overview" heading if it is named accordingly.

### Hub breadcrumbs (enforced)

Every hub that has a page directly above it **must link up to it**, so a reader can climb the tree without the browser back button. Put the crumb first in the `page-meta` line:

```html
<div class="page-meta">
  <span><a href="../index.html">&larr; SwiftUI Theory</a></span>
  <span>·</span>
  <span>iOS Topic Hub</span>
</div>
```

`check.ts` **errors** when the crumb is missing — but only when the parent folder actually contains an `index.html`. A hub at the top of its domain (nothing above it but the wiki root, reached via the nav) needs no crumb and is not flagged.

A sections-layout category may hold its own `index.html` landing page directly in the category folder, above the section hubs — that is what creates the level worth linking back to.

**`index.html` is positional, never resolved.** `index.html` means "the hub beside this page" and `../index.html` means "the one above it". Both are left exactly as authored; do not try to qualify them with a folder name.

## Rules digest

Wiki-wide:

- **Closed class vocabulary** — every class must exist in `wiki/static/wiki.css`; **no inline `style=""` ever** (validator error). Need a new visual? Extend `wiki.css` first. Full list + when-to-use: `references/css-vocabulary.md`.
- **Links are bare filenames** — see the link-identity section above.
- No single-letter or abbreviated variable names anywhere (Swift, pseudocode, TS).
- Section `id`s must be unique; fragment links must resolve (validated).
- One `co-idea` callout per page maximum. Blue `xref-card` = "go practice"; purple `backref-card` = "go generalize".

**LeetCode domain only** — these do *not* apply to `ios-topic` pages:

- Solutions are **iterative-only** in the main section; recursion only as appendix contrast.
- Difficulty tags (`"difficulty": "E|M|H"`) are required on walkthroughs, forbidden everywhere else.
- Cross-link both ways (the validator warns if missing): walkthrough §15 backref-card → parent theory page; theory §13 xref-card → the walkthrough; theory infobox `Walkthroughs` row → live link (replace any `(coming)` text). Cards to walkthroughs that don't exist yet use `<span class="xref-card xref-coming">…</span>` (non-link), never a dead `<a href>`.
- Walkthrough §11 code dry run follows the `/code-dry-run` trace format; the §6b spoken plan follows the six-pillar structure defined in the leetcode skill's `references/plan-comments.md`.

## Toolchain / scaling

`wiki/wiki.config.ts` is the only file naming **page types, domains, categories, and sections** — the engine (`lib/`, `browser/`) knows none of these names, it iterates the config:

- **New study domain** (e.g. system design) = one `domains[]` entry with its own `folder` + a folder under `content/`. Nav, hubs, and validation adapt automatically.
- **New page type** = one `pageTypes[]` entry declaring its `layout` + section skeleton, plus optional `tocTitle` / `tocAccent` (palette entry name — `insight`, `info`, `tip`, `caution`; omit for a neutral heading), then point a category at it via `pageType: "…"`. No engine code changes, and no CSS unless you want a hue that has no `.toc-accent-*` rule yet.
- **Nesting**: every `folder` is ONE path segment, never a path. The full folder path is built by walking `domain.folder → category.folder → [children…] → section`, so a category nests arbitrarily deep via `children: [...]` (e.g. `ios/swiftui/theory/fundamentals/`). A category holds either pages or `children`, not both.

**Renaming a folder** = change that one `folder` string, move the directory, `npm run build`. Every link follows. Never hand-edit paths in content.

### Current shape

```
leetcode/  theory (7 sections) · walkthroughs (flat) · reference (flat)
ios/       swiftui/theory      (fundamentals · state · screens)
           concurrency/theory  (fundamentals · isolation · patterns)
```

### Navigation model

The top bar renders **one dropdown per domain** — its width tracks domain count, not content volume — and the cascade is **capped at two menu levels**:

```
[Home]  [LeetCode ▾]  [iOS ▾]
             └→ Theory ▸ → Arrays & Hashing   (a section HUB; its pages are one click further)
                Walkthroughs ▸ → LC 3, LC 11, …  (leaf pages; scrolls past 12)
```

A sections-layout category lists its section **hubs**, not every page — that is what keeps the cap. Submenus contain only links, never another submenu. Consequences when touching `browser/nav.ts` or the nav CSS:

- **Bold = leads somewhere further (a hub); regular weight = a destination page.** Driven by `nav-item-hub`, not by which HTML element got rendered.
- `.nav-menu-scroll` belongs on submenus only — on the parent menu its `overflow-y` would clip the fly-outs.
- Submenus open rightward and flip via `.nav-submenu-left`, added at runtime by measuring overflow. CSS cannot decide this; do not reintroduce a static `:last-of-type` flip.

The **root hub** (`content/index.html`) shows one card per category, not one per page — it is an entry point, not a directory.

The engine must stay content-agnostic and dependency-free (erasable-syntax TS, `.ts` import extensions, hand-written Node typings in `lib/node-shims.d.ts`). Every filesystem path and browser-URL prefix lives in `engine/lib/paths.ts` — change a folder name there and the whole toolchain (plus the `<head>` wiring the validator enforces) follows. Deep dive: `references/architecture.md`.
