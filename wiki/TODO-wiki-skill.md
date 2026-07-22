# TODO — before merging the iOS domain work

Running list of things this branch changed that the `wiki` skill
(`.claude/skills/wiki/`) and the engine still need to catch up on.
Delete this file when the list is empty.

## 1. The `wiki` skill is stale

`SKILL.md` describes a LeetCode-only wiki. It now needs:

- **The two-domain layout.** `content/` no longer holds `theory/`,
  `walkthroughs/`, `reference/` at the top level — they are
  `leetcode_theory/`, `leetcode_walkthroughs/`, `leetcode_reference/`,
  plus `ios_swiftui/`.
- **The folder-naming constraint** (the reason for those prefixes):
  `derive.ts` matches the *first* path segment against `category.folder`
  across every domain, so `folder` is a single global namespace, and the
  path grammar is exactly two levels (`folder/section/page.html`). A
  domain cannot own a nested `leetcode/theory/` folder. The domain prefix
  goes in the folder NAME; the grouping lives in `wiki.config.ts`.
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

## 3. Open decision — top-bar density

The nav bar renders one dropdown per *section* for sections-layout
categories, so LeetCode Theory alone contributes seven groups. Current
state is 10 groups:

```
[Home]  LEETCODE: [Arrays & Hashing][Intervals][Strings & Simulation]
        [Stacks & Queues][Object & System Design][Trees][Graphs]
        [Walkthroughs][Review & Reference]
        IOS: [Fundamentals]
```

Two problems:

1. It will not fit on a laptop once the remaining iOS categories and a
   System Design domain land (roughly 16+ groups).
2. The iOS group is labelled **Fundamentals**, not **SwiftUI** — sections
   render directly as top-level groups, so the category name never
   appears. The goal was `ios/swiftui`.

Not fixed on this branch; it is a `nav.ts` change and deserves its own
commit. Sketch: make the *category* the dropdown trigger and nest its
sections inside, so each category contributes exactly one group
(`[Theory ▾][Walkthroughs ▾][Reference ▾]  [SwiftUI ▾]`).
