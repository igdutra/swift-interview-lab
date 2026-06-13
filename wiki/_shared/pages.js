// ============================================================
// pages.js — THE single registry of wiki pages.
// RULE: only finished, existing files are listed here — the hub
// and nav must never show anything that isn't done.
//
// To add a page: drop the HTML file in theory/ or walkthroughs/
// and add ONE entry here. Top nav and the hub index update
// automatically. Nothing else to edit.
//
// Fields:
//   cat        "theory" | "walkthrough"
//   path       relative to the wiki/ root
//   nav        short label for the top nav bar
//   title      full title for hub cards
//   topics     short topic list shown on the hub card
//   difficulty "E" | "M" | "H"  (walkthroughs only)
//   blurb      one line for the hub card description
// ============================================================
const WIKI_PAGES = [
  {
    cat: "theory",
    path: "theory/sliding_window_master.html",
    nav: "Sliding Window",
    title: "Sliding Window",
    topics: ["Arrays", "Strings", "Two Pointers"],
    blurb: "Two monotonic pointers over a contiguous range — longest/shortest subarray and substring problems in O(n).",
  },
  {
    cat: "walkthrough",
    path: "walkthroughs/LC3_master.html",
    nav: "LC 3",
    title: "LC 3 — Longest Substring Without Repeating Characters",
    topics: ["Sliding Window", "Hash Map", "Strings"],
    difficulty: "M",
    blurb: "Grow-and-shrink-on-invalid window (variant 8.2). The classic count-map shrink plus the last-seen-index jump optimization.",
  },
  {
    cat: "walkthrough",
    path: "walkthroughs/LC76_master.html",
    nav: "LC 76",
    title: "LC 76 — Minimum Window Substring",
    topics: ["Sliding Window", "Hash Map", "Strings"],
    difficulty: "H",
    blurb: "Shrink-while-valid sliding window with the matchedCount trick. Full interview simulation inside.",
  },
];
