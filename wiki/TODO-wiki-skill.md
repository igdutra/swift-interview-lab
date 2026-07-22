# TODO — before merging the iOS domain work

Running list of things this branch changed that the `wiki` skill
(`.claude/skills/wiki/`) and the engine still need to catch up on.
Delete this file when the list is empty.

## 1. The `wiki` skill is stale

`SKILL.md` describes a LeetCode-only wiki. It now needs:

- **The two-domain layout.** `content/` now nests by domain:
  `leetcode/{theory,walkthroughs,reference}/` and
  `ios/swiftui/theory/fundamentals/`. Categories nest arbitrarily via
  `children` in `wiki.config.ts`.
- **Links carry identity, not paths — this is the big one.** An authored
  link is the target's *filename*:

      <a href="sliding_window_master.html">

  `build.ts` rewrites it to the correct relative path for whichever page
  it appears in. Never author `../` or a folder name in an href; the
  build owns that. Same for `wiki.css` and the generated scripts, whose
  `../` depth is derived from where the page sits.

  Consequence: **renaming a folder is a config edit plus a rebuild.**
  Change `folder:` in `wiki.config.ts`, move the directory, run build —
  every affected link updates itself. Verified end to end by renaming
  `theory/` to `patterns/` and back (38 files updated each way, check
  green, zero manual edits).

- **Disambiguation.** If two pages share a filename, the build fails and
  names the shortest qualifying suffix to use instead
  (`codingInterview/state_management.html`). `index.html` is exempt — it
  is positional ("the hub beside this page"), not an identity.
- **A format reference for the `ios-topic` page type** —
  `references/ios-topic-format.md`, alongside the existing
  `theory-format.md` and `walkthrough-format.md`.
- **Scoping the rules digest.** Rules currently stated wiki-wide are
  LeetCode-only: "solutions are iterative-only", the §15 backref-card /
  §13 xref-card contract, difficulty tags. None apply to `ios-topic`.
- **The filename → role rule**, which is invisible in config and easy to
  trip over: `nav.ts` groups hub cards by `role`, and `derive.ts` assigns
  role from the filename — `*_overview_master.html` becomes `overview`,
  anything else in a section becomes `deep-dive`. A page only appears
  under an "Overview" heading on its hub if it is named accordingly.

## 2. Engine gaps found while building this

- **`new-page.ts` does not create missing directories.** Scaffolding into
  a new section folder fails with a raw `ENOENT` from `writeFileSync`.
  Should `mkdir -p` the target, or fail with a usable message.
- **`toc.ts` hardcodes content category names** (`theory`, `walkthrough`,
  `reference`, and now `ios-topic`) for TOC titles and colours, which
  breaks the engine's "knows no content names" rule. Move to a
  `tocTitle` field on each page type in `wiki.config.ts` next time the
  config schema changes. Marked with a TODO in the source.

## 3. DONE — top-bar density

The bar now renders **one dropdown per domain**, so its width depends on
how many domains exist, not how much content they hold:

```
[Home]  [LeetCode ▾]  [iOS ▾]
```

Depth is revealed on hover, **capped at two menu levels**:

```
[LeetCode ▾] → Theory      ▸ → Arrays & Hashing   (section hub)
               Walkthroughs ▸ → LC 3, LC 11, …    (scrolls past 12)
               Review & Ref ▸ → Cheat Sheet, …
```

A sections-layout category lists its section **hubs**, not every page —
that is what keeps the cascade at two levels instead of four. The hub
page is the third level, reached by clicking rather than hovering.

Deliberate: submenus contain only links, never another submenu, so the
cap is structural. `.nav-menu-scroll` is applied to submenus only; the
parent menu must never scroll or it would clip the fly-outs.

## 4. DONE — the root index no longer lists everything

The home page rendered a card for every page in every flat category —
52 cards, 37 of them individual walkthroughs. It now shows **one card
per category**, grouped by domain, with a `7 sections · 19 pages`
subtitle: 4 cards total.

Nothing was lost; the walkthrough cards moved to a new
`leetcode/walkthroughs/index.html` hub, which previously did not exist
(its category card had nowhere to point).

Still open: domain triggers in the nav are hover-only `<span>`s because
there is no per-domain landing page (`content/leetcode/index.html`). Add
them if the domains ever need their own overview prose.

## 5. NEXT — import the SwiftUI content

Sources are gitignored in `private-notes/DOCS-TO-ADD-TO-WIKI/`.
`SwiftUI-Reference.md` is 2,453 lines and must split into roughly seven
pages (identity, state ownership, data flow, navigation, lists, layout,
modals) — not one. Delete each source doc only after its pages are green.
