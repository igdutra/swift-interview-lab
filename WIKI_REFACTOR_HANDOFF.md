# Wiki v2 refactor — handoff (2026-07-06)

Full plan: `~/.claude/plans/claude-how-s-it-going-luminous-bunny.md`.
State: **committed green** through `96264ee`. `node wiki/tools/check.ts` passes with 0 errors / 0 warnings on 71 pages. Delete this file when everything below is done.

## Architecture (already live)

- **Zero-dependency TypeScript toolchain** in `wiki/tools/`, run by Node 24 directly (no npm installs, ever). Browser scripts compiled with global `tsc`.
  - `node wiki/tools/build.ts` — scans `wiki/**/*.html`, reads each page's `data-page-meta` JSON block, generates `wiki/_shared/manifest.js` (committed).
  - `node wiki/tools/check.ts` — validator: meta presence/shape, category/role consistency, wiring at correct depth, link + fragment integrity, TOC-ability, no inline styles, no `pages.js`, class vocabulary vs `wiki.css`, close-the-loop reciprocity, manifest freshness. Errors exit 1.
  - `node wiki/tools/serve.ts` — static server on :5050. `node wiki/tools/new-page.ts` — scaffolder.
  - `tsc -p wiki/tools/browser` — recompiles `_shared/nav.js` + `_shared/toc.js` from `wiki/tools/browser/*.ts`. `tsc --noEmit -p wiki/tools` type-checks the tools.
  - `wiki/tools/wiki.config.ts` is the ONLY file naming domains/categories/sections. New domain (e.g. design systems) = one config entry + folder.
- **Disk is truth**: each page carries `<script type="application/json" data-page-meta>` (title, nav, topics, blurb, difficulty for walkthroughs, optional order). Path/category/section/role/LC-number are derived from location. `pages.js` is deleted.
- **Nav v2**: grouped dropdowns (one per theory section + Walkthroughs + Reference), all 19 formerly-orphaned theory deep-dives now reachable. Current-page = exact manifest-key match. Root prefix derived from `nav.js`'s own script src.
- **TOC generated client-side** (`toc.js`) from `section[id]` + `data-toc-label` (h2[id] fallback for reference pages). 62 hand-written TOCs deleted.
- **Hub grids generated**: root `#hub` and every hub page's `<div data-hub-grid>` render from the manifest. `theory/intervals/index.html` hub created (was missing). Cards to not-yet-written walkthroughs use `<span class="xref-card xref-coming">` (non-link, dashed).
- All 126 inline `style=""` replaced by classes (`§11 utilities` block in `wiki.css`); drifted classes renamed to the closed vocabulary.

## Remaining work (in order)

1. **Browser verification** (plan §8 — curl-level checks passed; visual pass pending):
   serve, open root, `/theory/arrays/`, `/theory/graphs/bfs_deep_dive_master.html`, `/theory/intervals/`, one walkthrough, `/reference/cheatsheet.html` (h2-fallback TOC). Console must be error-free; nav dropdowns show every page; exactly one `.current`; TOC links scroll correctly.
2. **Standards → skill** (plan §7). Use the **skill-creator skill** to create repo-local `.claude/skills/wiki/` (NOT global):
   - `SKILL.md` (~120–150 lines): when-to-use, architecture in ten lines (the 4 commands above), add-a-page workflow (new-page.ts → fill meta+sections → build+check green), rules digest, reference index.
   - `references/theory-format.md` (condense `wiki/_standards/THEORY_MASTERFILE_STANDARD.md`, 14 sections — see `wiki/tools/lib/templates.ts` THEORY_SECTIONS for canonical ids/labels).
   - `references/walkthrough-format.md` (condense `WALKTHROUGH_MASTERFILE_STANDARD.md`, 15 sections — WALKTHROUGH_SECTIONS in templates.ts; §6b six-pillar plan should LINK to the leetcode skill's plan-comments reference instead of duplicating).
   - `references/css-vocabulary.md` (closed class list from `WIKI_CSS_STYLE_RESEARCH.md` §10 + the new classes: nav-group/nav-menu/nav-trigger, content-centered, sec-num, sim-subheader, xref-coming, u-* utilities, fig/fig-img).
   - `references/architecture.md` (meta schema, manifest shape, config, validator checks, "disk is truth", how to add a domain).
   - Move `wiki/_standards/PLAN_COMMENT_STANDARD.md` → `.claude/skills/leetcode/references/plan-comments.md` + one pointer line in the leetcode SKILL.md.
   - Delete `wiki/_standards/` entirely.
   - Rewrite the CLAUDE.md wiki section (replace the mandatory-3-docs rule): wiki is built by `wiki/tools/` (the 4 commands), and **before creating or editing any wiki page, load the `wiki` skill**.
   - Commit: `docs(wiki): replace _standards with local wiki skill and update CLAUDE.md`
3. **Cleanup**: delete `wiki/tools/migrate.ts` (one-time script, already run), final `build + check` green, scaffolder smoke test (create dummy walkthrough via new-page.ts, build, check, see it in nav, delete it, rebuild).
   Commit: `chore(wiki): remove one-time migration script`
4. Delete this handoff file in the final commit.

## Gotchas for the next session

- Warnings from `console.warn` go to **stderr**; run `node wiki/tools/check.ts 2>&1` to see them.
- Node prints an ExperimentalWarning for type stripping — harmless, filter with `rg -v Experimental`.
- Tools TS must stay **erasable-syntax-only** (no enums/namespaces); imports use explicit `.ts` extensions; minimal Node typings are hand-written in `wiki/tools/lib/node-shims.d.ts` (no @types/node, on purpose).
- After editing any page meta or adding a page: `node wiki/tools/build.ts` then `check.ts` (freshness check fails otherwise). After editing `browser/*.ts`: `tsc -p wiki/tools/browser` and commit the regenerated `_shared/*.js`.
- Repo rule: single-line Conventional Commits + `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` trailer; no descriptive variable-name abbreviations anywhere.
