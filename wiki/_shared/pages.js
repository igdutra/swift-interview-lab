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
//
// ORDERING RULE — walkthroughs:
//   Always insert new walkthrough entries in ascending LC number order.
//   The nav bar renders entries in the order they appear here — a
//   misordered entry produces a misordered nav. No exceptions.
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
  // ── Walkthroughs — CUSTOM problems first, then ascending LC number order ─
  {
    cat: "walkthrough",
    path: "walkthroughs/CUSTOM1_Relay_Handoff_Coverage_master.html",
    nav: "CUSTOM 1",
    title: "CUSTOM 1 — Relay Handoff Coverage",
    topics: ["Intervals", "Prefix-Suffix", "Arrays"],
    difficulty: "M",
    blurb: "Split/handoff coverage with raw day sets (Variant 8.5). Prefix-suffix precompute reduces pair-checking from O(t²·d) to O(t·d). Covers the ≤ vs == valid-pair condition gotcha.",
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
    path: "walkthroughs/LC56_master.html",
    nav: "LC 56",
    title: "LC 56 — Merge Intervals",
    topics: ["Intervals", "Sorting", "Arrays"],
    difficulty: "M",
    blurb: "Sort + sweep merge (Variant 8.1). The sort-once invariant that lets every step look only at result.last, the ≤ vs < overlap gotcha, and the in-place end-extension pattern.",
  },
  {
    cat: "walkthrough",
    path: "walkthroughs/LC57_master.html",
    nav: "LC 57",
    title: "LC 57 — Insert Interval",
    topics: ["Intervals", "Arrays"],
    difficulty: "M",
    blurb: "Three-region split (Variant 8.3). The only O(n) interval variant — before / overlapping / after regions, the strict vs non-strict boundary gotcha, and the must-not-forget Region 3 tail.",
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
    cat: "walkthrough",
    path: "walkthroughs/LC227_master.html",
    nav: "LC 227",
    title: "LC 227 — Basic Calculator II",
    topics: ["Strings", "Stack", "Parsing"],
    difficulty: "M",
    blurb: "Stack-based expression parse — deferred operator trick. Push for +/−, apply to stack top for ×/÷, flush the last operand at the final index. O(n) time, O(n) space.",
  },
  {
    cat: "walkthrough",
    path: "walkthroughs/LC759_master.html",
    nav: "LC 759",
    title: "LC 759 — Employee Free Time",
    topics: ["Intervals", "Sorting", "Arrays"],
    difficulty: "H",
    blurb: "Flatten + merge + gap-find (Variant 8.4). Free time = complement of the merged union. Recognizing the two-phase reduction is the whole problem; the gap formula and off-by-one pitfalls covered in full.",
  },
  {
    cat: "walkthrough",
    path: "walkthroughs/LC986_master.html",
    nav: "LC 986",
    title: "LC 986 — Interval List Intersections",
    topics: ["Intervals", "Two Pointers", "Arrays"],
    difficulty: "M",
    blurb: "Two-pointer interval overlap (Variant 8.2). Walk two sorted lists simultaneously — the overlap formula, why advancing the smaller-end pointer is the only correct move, and full dry run.",
  },
  {
    cat: "walkthrough",
    path: "walkthroughs/LC1041_master.html",
    nav: "LC 1041",
    title: "LC 1041 — Robot Bounded In Circle",
    topics: ["Strings", "Simulation", "State Machine"],
    difficulty: "M",
    blurb: "State-machine simulation — one cycle proves boundedness. Direction table + mod-4 turns + the bounded-iff-(origin-or-rotated) insight. No multi-cycle simulation needed.",
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
