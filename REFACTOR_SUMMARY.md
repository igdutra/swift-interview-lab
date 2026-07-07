# Wiki v2 Refactor — Completion Summary

Date: 2026-07-07. This closes out the refactor tracked in
`WIKI_REFACTOR_HANDOFF.md` (now deleted) and responds point-by-point to
`CODEX-REVIEW.md`.

## What the refactor is

The wiki moved from hand-maintained everything (a `pages.js` registry, 62
hand-written TOCs, manual hub grids, inline styles) to **disk-is-truth**:
each page carries a `data-page-meta` JSON block; a zero-dependency
TypeScript toolchain (`wiki/tools/`, run by Node 24 directly) generates the
manifest, and browser scripts render the nav, hub grids, and TOC from it.
A strict validator (`check.ts`) gates every commit. That core landed in
commits `6f27bce` → `96264ee`; the standards docs became the repo-local
`wiki` skill in `6a0b17f`.

## What this session finished

### 1. Browser verification — and two real bugs it caught

Served the wiki and verified in Chrome (plus a clean-profile headless
render): root, section hubs, theory deep dive, walkthrough, and reference
pages. Nav dropdowns list every page, the sticky "Theory · Contents" TOC
renders with correct labels and scrolls to its anchors, hub grids populate,
and the console is error-free.

- **`nav.js` current-page bug (functional).** The matcher accepted any
  manifest key that was a *suffix* of the URL path, so every hub page
  (`…/index.html`) matched the root home key `index.html` first. Result:
  "Home" was highlighted everywhere and — because the hub-grid renderer
  requires the current record's role to be `hub` — **every section hub
  rendered an empty grid**. Fixed by resolving the pathname relative to the
  wiki root URL and doing an exact manifest lookup (works at any mount
  depth).
- **Dev-server caching (the "missing nav / missing TOC" report).**
  `serve.ts` sent no cache headers, so browsers heuristically kept a stale
  pre-refactor `wiki.css` across sessions; without the new `.nav-group` /
  `.toc-col` rules the dropdown nav collapsed into a wall of inline links
  and the sidebar broke — exactly what the old-instance screenshot
  comparison surfaced. `serve.ts` now sends `Cache-Control: no-store`.
  No functionality had actually been lost: after the fix, the rendered
  `arrays_hashing_overview_master.html` matches the reference screenshot
  (top nav with every LC walkthrough reachable, numbered "THEORY ·
  CONTENTS" sidebar with the same ten entries).

### 2. Migration-era cleanup

- Rewrote the 54 page footers still citing
  `wiki/_standards/*_MASTERFILE_STANDARD.md` to point at the standards' new
  home, `.claude/skills/wiki/references/…`.
- Updated the `wiki.css` header (cited a deleted research doc) and removed
  the dead `_standards` folder exclusion in `scan.ts`.
- Deleted `wiki/tools/migrate.ts` (one-time script, already run).
- Deleted `WIKI_REFACTOR_HANDOFF.md`; its durable content now lives in
  `wiki/README.md` and the `wiki` skill.

### 3. Hardening and gaps closed

- `check.ts` now **errors on banned legacy strings** (`_standards`,
  `MASTERFILE_STANDARD`, `WIKI_CSS_STYLE_RESEARCH`) anywhere in page HTML
  or `wiki.css`, so this class of drift cannot silently return.
- `new-page.ts` scaffolded **reference pages with the theory skeleton**
  (wrong shape). Added `renderReferenceBody` — the flat, h2-driven document
  shape reference pages actually use.
- Added `wiki/README.md` as the stable local entry point (layout,
  authored-vs-generated split, commands, add-a-page workflow).
- Scaffolder smoke test: dummy reference + walkthrough pages created,
  built, validated green (73 pages), visible in the manifest, deleted,
  rebuilt back to 71.

Final state: `tsc --noEmit -p wiki/tools` clean, `build.ts` + `check.ts`
green — 0 errors / 0 warnings on 71 pages.

## Codex review — adopted vs. not, and why

| # | Codex recommendation | Verdict | Reasoning |
| --- | --- | --- | --- |
| 1 | Add `wiki/README.md` | **Adopted** | Cheapest onboarding win; the handoff file was session-specific and is now gone, so the folder needed a durable entry point. |
| 2 | Fix `reference` scaffolding (template over refusal) | **Adopted (template)** | Agreed with Codex's own ranking: a minimal h2-driven template keeps the advertised command honest; refusing would be safer than the old silent-wrong-shape but strictly worse than a correct template. |
| 3 | Validator rule banning `wiki/_standards/` references | **Adopted** | It is a hard architecture invariant, not editorial taste, so it belongs in `check.ts` (not a hypothetical `doctor.ts`). It would have caught the drift this review found. |
| 4 | Remove migration leftovers (footers, CSS header, `migrate.ts`, handoff) | **Adopted** | Done after landing #3, in Codex's recommended order — clean once the check prevents recurrence. |
| 5 | Add a `doctor.ts` for soft editorial audits | **Deferred** | The concrete drift it would have flagged is now either fixed or a hard `check.ts` error. A second audit command today would be surface area with zero findings to report. The `check.ts` = invariants / `doctor.ts` = judgment split is the right shape *when* an editorial-quality need actually appears. |
| 6 | Pre-render nav/hub grids at build time | **Rejected for now** | Codex itself says wait, and I agree with stronger reasons: at 71 pages the manifest is a few KB served locally; pre-rendering would make `build.ts` rewrite page HTML (churn in every diff, riskier builds) to save a runtime cost nobody can perceive. Revisit only at a much larger scale. |
| 7 | Unify stale comments/footers with the new architecture | **Adopted** | Folded into #4 — this was the bulk of the 55-file scrub. |
| 8 | Extract a shared `loadWiki()` for the build/check scan duplication | **Deferred** | Agreed with Codex's own argument: an abstraction guessed from two callers is premature; the duplication is visible and bounded. Extract when a third consumer or a diverging change makes the boundary obvious. |
| 9 | Split authored vs. generated assets out of `_shared/` | **Rejected (documented instead)** | Also Codex's preferred option: `_shared/` has a coherent meaning — "everything a page loads in the browser". A `_generated/` layer would complicate every page's include paths to solve a problem that a README table solves. Now documented bluntly in `wiki/README.md`. |

One note beyond the review: Codex audited the code statically and still
missed the two bugs that mattered most in practice (the current-page
suffix match and the dev-server caching). The browser-verification step
the handoff insisted on is what caught both — worth keeping as a ritual
for future wiki work.
