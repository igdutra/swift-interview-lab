# WIKI CSS STYLE RESEARCH

An actionable design specification for the `docs/` study wiki CSS system,
covering every design primitive defined in `THEORY_MASTERFILE_STANDARD.md` and
`WALKTHROUGH_MASTERFILE_STANDARD.md`. Every value below is concrete — hex
codes, px sizes, CSS properties — so the system can be implemented from this
document alone.

**Audience constraint.** These pages are rendered and maintained by an AI
model, not a frontend team. The spec therefore uses: a fixed, small class
vocabulary; CSS custom properties as the single source of truth; no
gradients, no animations, no JavaScript-dependent effects; nothing that
breaks when a maintainer adds one more block of the same kind. Delight comes
from typography, a confident palette, and hierarchy — not motion.

---

## 0 — Research findings that drive the decisions

- **Wikipedia / MediaWiki typography**: serif headings (`Linux Libertine,
  Georgia, serif`) over sans body tested best for long-form reference
  reading; body text color `#252525`-class near-black; grey text lighter
  than `#777777` on white is prohibited (WCAG AA floor); justified text is
  explicitly avoided (rivers/moire); navigation type is set 1–3px smaller
  than article type so chrome recedes.
- **Wikimedia readability research**: eye-tracking shows readability and
  comprehension rise with font size (16px minimum, 18px better for leads);
  line spacing multipliers of 1.2–1.4 read faster than tighter spacing;
  users *prefer* shorter line lengths even when longer ones measure fine —
  so cap the prose measure.
- **Vector 2022**: the TOC sits beside the article, always visible, because
  it is "a critical reading element" — keep the sticky left TOC.
- **MDN notecards**: callouts are a closed set (`note`, `warning`,
  `callout`) with a bold localized label prefix — a fixed vocabulary an AI
  maintainer cannot misuse. Blue = note, yellow = warning.
- **Section 508 / WCAG**: color must never be the only signal — every
  callout needs a text label AND a border treatment; text contrast ≥ 4.5:1.
- **MkDocs Material admonitions**: the `border-left: 4px solid` + tinted
  background pattern is the industry-standard admonition shape; adopted.
- **GitBook / Notion / Obsidian Publish**: their edge over Wikipedia is
  distraction-free whitespace, a restrained accent palette, and card-style
  cross-links that feel like navigation, not prose links. Adopted for the
  cross-reference panels.
- **Xcode Classic Light**: the repo's existing syntax token colors
  (`#9b2393` keywords, `#c41a16` strings) match Xcode's authentic light
  theme. Swift code should look like Xcode; keep them.

Sources: [Skin:Vector/2022 Design documentation](https://www.mediawiki.org/wiki/Skin:Vector/2022/Design_documentation),
[MediaWiki Design/Typography](https://www.mediawiki.org/wiki/Design/Typography),
[Wikimedia readability research](http://design.wikimedia.org/uxr/projects/readability-on-wp/),
[MDN: How to write in Markdown (notecards)](https://developer.mozilla.org/en-US/docs/MDN/Writing_guidelines/Howto/Markdown_in_MDN),
[Section 508: accessible color usage](https://www.section508.gov/create/making-color-usage-accessible/),
[WebAIM: contrast requirements](https://webaim.org/articles/contrast/),
[MkDocs Material admonitions guide](https://albrittonanalytics.com/features/admonitions/),
[GitBook customization](https://www.gitbook.com/comparison/gitbook-vs-notion),
[Xcode default theme colors](https://github.com/smockle-archive/xcode-default-theme).

---

## 1 — Design primitive inventory (derived from the two standards)

From **THEORY_MASTERFILE_STANDARD.md** (§1–§15) and
**WALKTHROUGH_MASTERFILE_STANDARD.md** (§1–§16), deduplicated:

**Page chrome**: page title + meta line · sticky numbered TOC · section
`h2/h3/h4` hierarchy · wiki horizontal rule · page footer.

**Reference furniture**: right-floating infobox ("At a Glance" / "Problem at
a Glance") · lead paragraph block.

**Code & traces**: pseudocode block · Swift code block · dry-run/trace block
(state table per step) · ASCII diagram block + caption.

**Tables**: terminology decoder · recognition-signal / clue table · versus
(comparison) table · complexity table with "why" column · cheat-sheet table ·
edge-case inventory · question → code map.

**Callout family**: key-idea ("big idea") · insight (why-it-works) · note /
caution · tip / approach · pitfall / danger · when-to-use box.

**Catalog blocks**: pattern/variant block with header + pills · solution
block (A.1 headers) with approach box.

**Interview primitives** (walkthrough only): clarifying Q&A pairs ·
say-out-loud monologue script · follow-up question bank · graduated-hints
spoiler block.

**Navigation primitives**: cross-reference panel (theory → walkthroughs) ·
back-reference panel (walkthrough → parent theory) · inline wiki-links ·
solo-problem box with checklist.

Every one of these gets a treatment in §7.

---

## 2 — Typography system

| Role | Stack | Size | Weight | Line height |
|---|---|---|---|---|
| Display headings (h1, h2) | `'Linux Libertine O', Georgia, 'Times New Roman', serif` | h1 30px / h2 24px | 400 | 1.25 |
| Sub-headings (h3) | `'Source Sans 3', -apple-system, sans-serif` | 18px | 700 | 1.3 |
| Kicker headings (h4) | `'Source Sans 3', sans-serif`, uppercase, `letter-spacing: 0.05em` | 13px | 700 | 1.3 |
| Lead paragraph | `'Linux Libertine O', Georgia, serif` | 18px | 400 | 1.6 |
| Body prose | `'Source Sans 3', -apple-system, sans-serif` | 16px | 400 | 1.65 |
| Tables, lists, callouts | `'Source Sans 3', sans-serif` | 14px | 400 | 1.55 |
| Code (all blocks + inline) | `'Source Code Pro', 'SF Mono', Menlo, monospace` | 13.5px | 400 | 1.7 |
| Captions, code descriptions | `'Source Sans 3', sans-serif` | 12.5px, italic for captions | 400 | 1.5 |
| UI chrome (TOC, pills, labels) | `'Source Sans 3', sans-serif` | 13px (TOC), 11px (pills/labels) | 600–700 | 1.4 |

Rules:

- **Serif for identity, sans for work.** Serif appears in exactly three
  places: h1/h2, and the lead block. Everything the reader *works* through
  (body, tables, callouts) is Source Sans 3 at 16px — per the Wikimedia
  finding that ≥16px measurably improves comprehension, and per MediaWiki's
  serif-headings/sans-body split. This replaces the current site's
  serif-by-default body, which today gets overridden ad hoc by nearly every
  component anyway.
- `html { font-size: 16px; }` and never set sizes in `em` chains — px
  everywhere, so an AI maintainer can't compound a scale accidentally.
- `text-align: left` always. Never `justify` (MediaWiki: rivers/moire).
- Headings: `h2 { border-bottom: 1px solid #c8ccd1; padding-bottom: 4px;
  margin: 48px 0 16px; }` — the Wikipedia section rule. `h3 { margin: 32px
  0 12px; }`. All sections get `scroll-margin-top: 16px` so TOC anchors
  land cleanly.
- Prose measure: `p, ul, ol { max-width: 72ch; }` — research says readers
  prefer shorter measures; tables and code may run the full column.

## 3 — Color palette

All tokens live in `:root` of `_shared/wiki.css`. Text-on-tint pairs below
are all ≥ 4.5:1 (WCAG AA); no text color lighter than `#72777d` ever sits on
white (MediaWiki's `#777` floor).

### Neutrals (Wikimedia Base palette — keep)

| Token | Hex | Use |
|---|---|---|
| `--text` | `#202122` | Body text (Wikipedia's article color) |
| `--text2` | `#54595d` | Secondary text, table body |
| `--text3` | `#72777d` | Captions, meta, TOC numbers — the lightest legal grey |
| `--page-bg` | `#f8f9fa` | Page background behind the content sheet |
| `--surface` | `#ffffff` | The content sheet, infobox rows, cards |
| `--border` | `#a2a9b1` | h1 underline, infobox outer border |
| `--border-lt` | `#c8ccd1` | h2 underline, block borders |
| `--border-xlt` | `#eaecf0` | Hairlines, table cell borders, block headers bg |

### Link colors

| Token | Hex | Use |
|---|---|---|
| `--link` | `#3366cc` | All links (Wikipedia blue — instantly reads as "wiki") |
| `--link-visited` | `#6b4ba1` | Visited wiki-links only (cross-ref panels), so a reader sees which walkthroughs they've already studied |

### Semantic accents (one hue = one meaning, sitewide)

| Meaning | Text/border | Tint bg | Used by |
|---|---|---|---|
| Info / structure | `#3366cc` | `#eaf3fb` | when-to-use boxes, note cards, cross-ref accent |
| Success / tip | `#14866d` | `#d5fdf4` | approach boxes, tip callouts, space-complexity values |
| Caution | `#ac6600` | `#fef6e7` | note/caution boxes, solo-problem box, Swift label |
| Danger / pitfall | `#b32424` | `#fee7e6` | pitfall boxes, wrong-approach markers, clue-table keys |
| Insight / theory | `#5b3ea8` | `#f3effe` | key-insight boxes, pseudocode identity, back-ref accent |
| Key idea | `#b08000` | `#fffbe6` (border `#f0c030`) | the one "big idea" block per page |

These are the site's existing hues — they are Wikimedia-adjacent, AA-clean,
and already consistent across 17 files. **Keep them**; the change is
codifying "one hue = one meaning" so amber is never decorative.

### Code block backgrounds (tinted canvases, one per language identity)

| Block | Background | Border |
|---|---|---|
| Pseudocode | `#f0f0ff` | `#d4c5f9` |
| Swift | `#fff8f0` | `#f5d9a8` |
| Dry-run / trace | `#f4f8ff` | `#c8ddf0` |
| ASCII diagram | `#f0f8f0` | `#b3e8d8` |

The tint *is* the label's color family, so a reader can identify the block
type from across the room — but every block still carries a text label
(Section 508: never color alone).

### Syntax tokens (Xcode Classic Light — keep, verified authentic)

| Token | Hex | Token | Hex |
|---|---|---|---|
| `.kw` keyword | `#9b2393` (w600) | `.st` string | `#c41a16` |
| `.fn` function | `#2d5bb9` | `.nm` number/name | `#1c63b7` |
| `.tp` type | `#2e7d32` | `.cm` comment | `#707070` italic |
| `.pk` pseudo-keyword | `#5b3ea8` (w700) | `.pc` pseudo-comment | `#555555` italic |

## 4 — Spacing & layout system

- **Spacing scale**: 4 / 8 / 12 / 16 / 24 / 32 / 48 px. No other values.
  Section gap 48px, block gap 24px, intra-block padding 16–20px, label gaps
  4–8px.
- **Layout**: `body { display: flex; }` with two zones:
  - TOC column: `width: 240px; flex-shrink: 0; padding: 32px 0 32px 24px;`
  - Content sheet: `flex: 1; max-width: 880px; padding: 32px 48px 64px
    40px; background: var(--surface); border-left/right: 1px solid
    var(--border-xlt);` — the white sheet on the grey `--page-bg` is the
    Wikipedia "article on desk" effect; keep it.
- 880px sheet minus padding gives a ~790px line for tables/code and a 72ch
  (~640px) measure for prose — inside research-backed comfort.
- `hr.wiki-hr { border: none; border-top: 1px solid var(--border-xlt);
  margin: 48px 0; }` between every numbered section.
- Page footer: `margin-top: 48px; padding-top: 16px; border-top: 1px solid
  var(--border-lt); font: 12.5px 'Source Sans 3'; color: var(--text3);`.

## 5 — TOC sidebar

- **Sticky**: `position: sticky; top: 0; height: 100vh; overflow-y: auto;`
  (Vector 2022: the TOC must stay visible — it is a critical reading
  element).
- Inner card: `background: #f8f9fa; border: 1px solid #c8ccd1;
  border-radius: 4px; padding: 12px 16px; font: 13px 'Source Sans 3'`.
- Entries: top-level 600 weight, `color: var(--link)`; sub-entries 400
  weight 12px `color: var(--text2)`, indented 12px; section numbers in
  `var(--text3)`. Hover: `text-decoration: underline` — no transitions.
- **Active state without JavaScript**: highlight is *per-page*, not
  scroll-spy (scroll-spy needs JS — excluded by constraint). The TOC title
  block shows the page's category (THEORY or WALKTHROUGH, 11px uppercase
  letter-spaced, in the category accent color: blue for walkthrough, purple
  for theory). Anchor landing is handled by `scroll-margin-top` on targets.
- **Mobile** (`@media (max-width: 1100px)`): the column unsticks and drops
  to `position: static; width: auto; height: auto;` rendered above the
  content; wrap the list in `<details><summary>Contents</summary>…</details>`
  — collapsible with zero JS. Infobox unfloats at the same breakpoint.

## 6 — Infobox / metadata panel

- Placement: `float: right; clear: right; width: 280px; margin: 0 0 16px
  24px;` inside section 1, before the lead — Wikipedia's exact pattern.
- Skin: `background: #f8f9fa; border: 1px solid #a2a9b1; border-radius:
  3px; font: 13px 'Source Sans 3'`. Title bar: `background: #cee0f2;
  text-align: center; font-weight: 700; padding: 6px 10px;` — the powder
  blue is the one "branded" surface on the page; keep it.
- Rows: flex, `border-top: 1px solid var(--border-xlt)`; key cell 110px
  min-width, 600 weight, `var(--text2)`; value cell `var(--text)`.
- **Standardized title**: theory pages say "At a Glance", walkthroughs say
  "Problem at a Glance" — two strings, never invented per page.
- **Required final row** (both page types): "Theory" / "Walkthroughs" —
  the inter-file links, in mono 12px. The infobox is the fastest route to
  the paired file; this row is what makes the pairing visible at a glance.
- Difficulty pills: `tag-E` `#14866d` on `#d5fdf4`; `tag-M` `#ac6600` on
  `#fef6e7`; `tag-H` `#b32424` on `#fee7e6` — 11px, 700, `padding: 1px
  7px; border-radius: 3px`.

## 7 — Section-by-section visual treatment

Every primitive from §1. Format: background · border · label convention ·
typography.

**Lead block** — no box, no border. 18px serif, first phrase of first
sentence `<strong>`. The only unboxed "special" text on the page; its
quietness is the design.

**Pseudocode block** — `pre.pseudo`: bg `#f0f0ff`, `border: 1px solid
#d4c5f9; border-radius: 3px; padding: 16px 20px;`. Label chip above:
`PSEUDOCODE`, 11px 700 uppercase, purple `#5b3ea8` on `#f0f0ff`, 1px
`#d4c5f9` border, with an optional 12.5px grey description beside it.
Pseudo-keywords `.pk` purple 700; structure reads as *idea*, not language.

**Swift block** — `pre.swift`: bg `#fff8f0`, border `#f5d9a8`. Label chip
`SWIFT` in amber `#ac6600`. Full Xcode Classic Light tokens (§3). The warm
paper + Xcode colors says "this is real, compilable code" against the cool
purple of pseudocode — the two must never share a tint.

**Dry-run / trace block** — `pre.dry`: bg `#f4f8ff`, border `#c8ddf0`,
12.5px, `line-height: 1.85`. Label chip `TRACE` in blue. Inside: state
variables `#3366cc` 700, accepted steps `#14866d` 600, rejected/illegal
steps `#b32424` 600, highlighted aha-steps `#ac6600` 700. The four trace
colors reuse the semantic hues exactly.

**ASCII diagram** — `.graph-diagram`: bg `#f0f8f0`, border `#b3e8d8`,
mono 13px, `line-height: 1.9; white-space: pre;`. Always followed by
`.graph-caption`: 12.5px italic `var(--text3)`.

**Table family** — one shared base: `border-collapse: collapse; font: 14px
'Source Sans 3'; th { background: #eaecf0; border: 1px solid #c8ccd1;
font-size: 11px; uppercase; letter-spacing: 0.05em; color: #54595d; padding:
6px 12px; } td { border: 1px solid #eaecf0; padding: 8px 12px; }`.
Row hover: `background: #f8f9fa` (a static color swap, allowed).
Variants differ only in the first column:
- *Terminology decoder*: term cell 600 weight.
- *Clue / signal table*: trigger cell mono 12px `#b32424` on `#fee7e6` —
  the "when you see this" key reads as an alarm.
- *Versus table*: first column 700; no other decoration.
- *Complexity table*: time values mono 12px `#3366cc` 700; space values
  mono `#14866d` 700; mandatory "why" column in body color. A final
  "Bottleneck" row gets `background: #fef6e7`.
- *Edge-case inventory*: first column mono 12px (the literal input), last
  column ("handled by") mono 12px `var(--text3)`.
- *Question → code map*: left cell italic (the spoken question), right
  cell mono 12px (the code it became).

**Callout family** — one shape for all: `border-left: 4px solid <hue>;
background: <tint>; border-radius: 0 3px 3px 0; padding: 10px 16px; font:
14px 'Source Sans 3';` plus a bold colored lead-in label. Never an icon
font, never an emoji — text labels only (Section 508; and labels are
something an AI maintainer reproduces perfectly):
- *Key idea* (max one per page): bg `#fffbe6`, `border: 2px solid #f0c030`
  on all sides (the only four-sided callout), label `THE ONE IDEA` `#b08000`.
- *Insight*: left bar `#5b3ea8`, bg `#f3effe`, label `Why it works:`.
- *Note / caution*: left bar `#ac6600`, bg `#fef6e7`, label `Note:`.
- *Tip / approach*: left bar `#14866d`, bg `#d5fdf4`, label `Tip:`.
- *Pitfall*: left bar `#b32424`, bg `#fee7e6`, label `PITFALLS` as a 12px
  uppercase header; entries are `▸`-bulleted 13px rows.
- *When-to-use*: left bar `#3366cc`, bg `#eaf3fb`, label `When to use:`.

**Pattern / variant catalog block** — `.pattern-block`: `border: 1px solid
#c8ccd1; border-radius: 4px; overflow: hidden;`. Header strip: `background:
#eaecf0; padding: 10px 16px;` with kicker number (11px uppercase grey),
name (16px 700), and complexity pills right-aligned (mono 11px: time pill
blue on `#eaf3fb`, space pill green on `#d5fdf4`). Body padding 20px 24px.

**Solution block** — same skeleton as pattern block, but the header carries
a mono badge (`A.1`) blue on `#eaf3fb` and, when multiple solutions exist, a
ranking tag ("Understand this first"). First element of the body is always
the green *approach box* (label `PLAN`), then pseudocode, then Swift.

**Interview simulation** — must *feel* like a different register: the page
stops documenting and starts rehearsing. Container: `border: 1px solid
#c8ccd1; border-left: 4px solid #3366cc; border-radius: 4px;` with header
strip `INTERVIEW SIMULATION — SAY THIS OUT LOUD` (11px uppercase, white on
`#3366cc` — the only inverted header on the page, which is what sets the
section apart).
- *Clarifying Q&A*: question line 14px 600 `#3366cc`, prefixed `Q:`;
  answer line 14px `var(--text)`, prefixed `A:`, left-padded 16px, with
  the design consequence after a `→` in 600 weight. Pairs separated by
  12px.
- *Say-out-loud monologue*: the one place serif body returns —
  `font: italic 16px/1.8 Georgia, serif; background: #fffdf7; border: 1px
  solid #eaecf0; border-radius: 3px; padding: 16px 20px;` with a kicker
  `THE PLAN, SPOKEN` 11px uppercase `#3366cc`. Spoken words look like
  speech, not documentation.

**Follow-up question bank** — definition-list rhythm: each follow-up is a
14px 700 line prefixed with `Follow-up:` in `#5b3ea8`, answer paragraph
14px below, optional wiki-link to the sibling walkthrough. No box; a 1px
`#eaecf0` rule between entries.

**Graduated hints (spoiler)** — native `<details>` (zero JS):
`details.hint { border: 1px dashed #ac6600; background: #fef6e7;
border-radius: 3px; padding: 8px 14px; margin-bottom: 8px; }
summary { cursor: pointer; font: 600 13px 'Source Sans 3'; color: #ac6600; }`
Summaries are numbered "Hint 1 — constraint", "Hint 2 — pattern", "Hint 3 —
structure".

**Solo-problem box** — keep the current treatment, it is distinctive and
correct: `border: 2px dashed #ac6600; background: #fef6e7; border-radius:
4px; padding: 16px 20px;` banner `SOLO PROBLEM — NO SOLUTION ON THIS PAGE`,
checklist items with `☐` pseudo-element bullets in amber.

**Page footer** — per §4; must contain the back/cross links again as plain
links (the footer is where a finished reader looks for "where next").

## 8 — Cross-reference & back-reference panels

These must read as *wiki navigation*, not prose hyperlinks — the
Obsidian/GitBook lesson. Card grid, not a link list:

- Container: `display: grid; grid-template-columns: 1fr 1fr; gap: 12px;`
  (single column under 700px).
- Card: `display: block; border: 1px solid #c8ccd1; border-left: 4px solid
  var(--accent); border-radius: 4px; padding: 12px 16px; background:
  #ffffff; text-decoration: none;` Hover: `background: #eaf3fb` — color
  swap only. Visited: title color `#6b4ba1`, so studied files are visibly
  "done".
- `--accent` is **blue `#3366cc` on cross-reference cards** (theory →
  walkthrough: "go practice") and **purple `#5b3ea8` on back-reference
  cards** (walkthrough → theory: "go generalize"). Direction is legible
  from color before reading a word.
- Card anatomy, top to bottom: filename in mono 12px `var(--text3)`
  (`LC721_master.html`); title 15px 700 `var(--link)` ("Accounts Merge —
  Union-Find in practice"); one-line 13px description of *what the reader
  lands on*, e.g. "Theory Decoder maps each solution line back to §8
  Union-Find" — both standards require this description, so the card
  template has a dedicated slot for it.
- Section header for the panel: theory pages `Demonstrated in practice`,
  walkthroughs `Parent theory` — fixed strings.
- Inline wiki-links inside prose stay ordinary `#3366cc` links — panels are
  for the dedicated sections only.

## 9 — Keep / discard from the current design

**Keep** (verified good, already loved):
- The entire neutral + semantic palette (§3) — Wikimedia-grade, AA-clean.
- Serif h1/h2 over sans content; white sheet on `#f8f9fa`; powder-blue
  infobox title; sticky left TOC; numbered sections.
- Xcode Classic Light syntax tokens and the four tinted code canvases.
- Pattern/solution block skeleton, pill system, dashed solo box.

**Discard entirely**:
- **Per-file inline `<style>` blocks** (~230–380 duplicated lines × 17
  files, already drifted). Everything in this spec lives once in
  `_shared/wiki.css`; pages keep at most a 10-line override block. This is
  the single highest-leverage change for an AI maintainer.
- **Serif as the default body font** — body becomes 16px Source Sans 3;
  serif is reserved for h1/h2, lead, and the spoken monologue.
- **Emoji icons in headers** (🔍 📌 🧠 ⚠️ 🔑) — replaced by the text-label
  convention (§7); emojis render inconsistently and invite drift.
- **14px body in callouts/tables as de facto body size** — body prose is
  16px; 14px is for furniture only.
- **Ad hoc infobox titles, mixed section lettering, one-off table classes**
  — the fixed vocabularies in §6/§7 replace them.
- Anything not expressible as: token + one class + plain CSS. No new
  colors, no new fonts, no per-page inventions.

## 10 — Implementation notes

- Single file: `_shared/wiki.css`, organized in the order of this spec
  (tokens → typography → layout → TOC → infobox → components → nav panels),
  with one comment line per section naming the spec section it implements.
- All colors referenced **only** via `var(--token)` in component rules, so
  a future palette change is a 20-line edit.
- Class vocabulary is closed: `pseudo swift dry ascii` (code) · `co-idea
  co-insight co-note co-tip co-pitfall co-when` (callouts) · `t-decoder
  t-clue t-versus t-cmx t-edge t-qmap` (tables) · `pattern-block
  solution-block sim-block speech hint solo-box` (blocks) · `xref-card
  backref-card` (nav). A maintainer composing a new page picks from this
  list; nothing else exists.
- The three wiring tags from `STANDARDS.md` are unchanged: `wiki.css`
  link, `data-category`, `nav.js` script include.
