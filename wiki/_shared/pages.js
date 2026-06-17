// ============================================================
// pages.js — THE single registry of wiki pages.
// RULE: only finished, existing files are listed here — the hub
// and nav must never show anything that isn't done.
//
// To add a page: drop the HTML file in the right subfolder
// and add ONE entry here. Top nav and the hub index update
// automatically. Nothing else to edit.
//
// Fields:
//   cat        "theory" | "walkthrough" | "tips"
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
    path: "theory/arrays/index.html",
    nav: "Arrays & Hashing",
    title: "Arrays & Hashing",
    topics: ["Arrays", "Hash Map", "Two Pointers", "Sliding Window"],
    blurb: "Arrays & Hashing hub — overview, hash map, two pointers, and sliding window masterfiles.",
  },
  {
    cat: "theory",
    path: "theory/intervals/intervals_overview_master.html",
    nav: "Intervals",
    title: "Intervals",
    topics: ["Arrays", "Sorting", "Sweep"],
    blurb: "Sort-then-sweep interval technique — merge, overlap, insert, gap-find, and split/handoff coverage variants.",
  },
  {
    cat: "theory",
    path: "theory/strings/index.html",
    nav: "Strings & Simulation",
    title: "Strings & Simulation",
    topics: ["Strings", "Simulation", "Stack", "Parsing"],
    blurb: "Strings & Simulation hub — overview, text-formatting/simulation, and string-parsing masterfiles.",
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
    path: "walkthroughs/LC11_master.html",
    nav: "LC 11",
    title: "LC 11 — Container With Most Water",
    topics: ["Two Pointers", "Arrays"],
    difficulty: "M",
    blurb: "Converging two pointers with min-side steering. Full proof of why moving the taller wall is provably suboptimal, with dry run and interview simulation.",
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
  {
    cat: "walkthrough",
    path: "walkthroughs/LC209_master.html",
    nav: "LC 209",
    title: "LC 209 — Minimum Size Subarray Sum",
    topics: ["Sliding Window", "Arrays"],
    difficulty: "M",
    blurb: "Shrink-while-valid at its simplest — one running sum, no maps. Includes the Int.max init gotcha and full interview simulation.",
  },
  {
    cat: "tips",
    path: "tips/interview_stages.html",
    nav: "Interview Stages",
    title: "Stages of an Interview",
    topics: ["Process", "Soft Skills"],
    blurb: "7-stage breakdown of a technical interview round with a condensed cheat sheet.",
  },
  {
    cat: "tips",
    path: "tips/sort_complexity.html",
    nav: "Sort Complexity",
    title: "Sorting Algorithm Complexity",
    topics: ["Complexity", "Sorting"],
    blurb: "Timsort vs Heapsort vs Counting Sort — when theory and practice diverge.",
  },
  {
    cat: "tips",
    path: "tips/cheatsheet.html",
    nav: "Big-O Cheatsheet",
    title: "Big-O & DS/A Cheatsheet",
    topics: ["Complexity", "DS&A", "Reference"],
    blurb: "Time/space complexity by data structure, input-size heuristics, and the Big-O chart.",
  },
];
