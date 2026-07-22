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

## 3. NEXT UP — top-bar density

Deferred deliberately; this is the next task.

The nav bar renders one dropdown per *section* for sections-layout
categories, so LeetCode Theory alone contributes seven groups:

```
[Home]  LEETCODE: [Arrays & Hashing][Intervals][Strings & Simulation]
        [Stacks & Queues][Object & System Design][Trees][Graphs]
        [Walkthroughs][Review & Reference]
        IOS: [Fundamentals]
```

Two problems:

1. It will not fit on a laptop once the remaining iOS categories and a
   System Design domain land (roughly 16+ groups).
2. The iOS group is labelled **Fundamentals** — the section name — so
   the `SwiftUI · Theory` category label never reaches the bar.

Sketch: make the *category* the dropdown trigger and nest its sections
inside, so each category contributes exactly one group
(`[Theory ▾][Walkthroughs ▾][Reference ▾]  [SwiftUI · Theory ▾]`).

## 4. Then — import the SwiftUI content

Sources are gitignored in `private-notes/DOCS-TO-ADD-TO-WIKI/`.
`SwiftUI-Reference.md` is 2,453 lines and must split into roughly seven
pages (identity, state ownership, data flow, navigation, lists, layout,
modals) — not one. Delete each source doc only after its pages are green.
