# How to add pages to the wiki

The wiki is wired through **one registry file**: `_shared/pages.js`. Adding a
page = drop the HTML file in the right folder + add one entry to the registry.
The top nav bar (every page) and the hub cards (`index.html`) rebuild
themselves from it. Nothing else to edit for navigation.

## Run locally

```bash
cd wiki && python3 -m http.server 8080
# open http://localhost:8080
```

## The three governing documents (read before writing a page)

| Doc | Governs |
|---|---|
| `THEORY_MASTERFILE_STANDARD.md` | The 15 required sections of a theory page |
| `WALKTHROUGH_MASTERFILE_STANDARD.md` | The 16 required sections of a walkthrough page |
| `WIKI_CSS_STYLE_RESEARCH.md` | The design system — all classes live in `_shared/wiki.css` |

## File placement and naming

| Kind | Folder | Name |
|---|---|---|
| Theory page | `theory/` | `{topic}_master.html` (lowercase snake) |
| Walkthrough | `walkthroughs/` | `LC{number}_master.html` |

## Checklist — add a theory page

1. Copy `theory/sliding_window_master.html` as the skeleton (it has all 15
   standard sections in order — replace the content, keep the structure).
2. Keep the three wiring pieces exactly:
   - `<link rel="stylesheet" href="../_shared/wiki.css">`
   - `<body data-category="theory">` and `<nav id="topnav" class="topnav"></nav>`
   - the two `<script src="../_shared/pages.js|nav.js">` tags before `</body>`
3. **No inline `<style>` blocks.** Every visual need is a class in
   `_shared/wiki.css` (closed vocabulary: `pseudo swift dry ascii` ·
   `co-idea co-insight co-note co-tip co-pitfall co-when` ·
   `t-decoder t-clue t-versus t-cmx t-edge t-qmap` ·
   `pattern-block solution-block sim-block speech hint solo-box` ·
   `xref-card backref-card`). If a page seems to need a new style, the CSS
   spec gets amended first — never the page.
4. Fill the **Demonstrated in Practice** section (§13) with one `xref-card`
   per related walkthrough — filename + title + one line describing what the
   reader lands on.
5. Register it — one line in `_shared/pages.js`, **only after the file exists
   and is finished**. The hub lists done things only; there is no status
   column and no placeholder entries, ever. Real entry currently in the
   registry, as the reference:

   ```js
   { cat: "theory", path: "theory/sliding_window_master.html", nav: "Sliding Window",
     title: "Sliding Window", topics: ["Arrays", "Strings", "Two Pointers"],
     blurb: "Two monotonic pointers over a contiguous range — …" },
   ```

## Checklist — add a walkthrough page

1. Copy `walkthroughs/LC76_master.html` as the skeleton (all 15 standard
   sections, including the Interview Simulation with the spoken plan).
2. Same wiring rules as above, with `data-category="walkthrough"`.
3. Solutions must be **iterative-only** in the main section; recursion only
   as an appendix contrast.
4. Fill the **Parent Theory** section (§14) with a `backref-card` to the
   theory page, describing its numbered sections.
5. Register it — one line in `_shared/pages.js`, **only after the file exists
   and is finished** (done things only). Real entry currently in the
   registry, as the reference (`difficulty` is `"E" | "M" | "H"`):

   ```js
   { cat: "walkthrough", path: "walkthroughs/LC76_master.html", nav: "LC 76",
     title: "LC 76 — Minimum Window Substring", topics: ["Sliding Window", "Hash Map", "Strings"],
     difficulty: "H", blurb: "Shrink-while-valid sliding window with the matchedCount trick. …" },
   ```

## Close the loop (both directions, always)

Every new walkthrough must add itself as an `xref-card` in its parent theory
page's "Demonstrated in Practice" section. Every new theory page must be
back-referenced by its walkthroughs. A page with a missing link direction is
incomplete — the theory ↔ walkthrough navigation loop is the wiki's core
feature.

## Color semantics cheat (from the design spec)

- Blue `xref-card` = "go practice" (theory → walkthrough)
- Purple `backref-card` = "go generalize" (walkthrough → theory)
- Callouts: blue `co-when` (when to use) · purple `co-insight` (why it works)
  · green `co-tip` · amber `co-note` · red `co-pitfall` · gold `co-idea`
  (max one per page)
