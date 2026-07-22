// ============================================================
// wiki.config.ts — THIS wiki's structure, in one place.
//
// The engine (engine/, its lib/, the browser nav) knows nothing
// about "theory", "arrays", or "walkthrough" — it iterates this
// file. To stand up a wiki on a new topic you rewrite ONLY this
// file: declare your page types, your categories, your sections.
//
//   • pageTypes — the shapes a page can take (its section skeleton).
//     Adding an "electrical-engineering topic" type is one entry here.
//   • domains   — the knowledge domains, each a tree of categories.
//   • sections  — order below = display order in nav and hub grids.
// ============================================================

import type { WikiConfiguration } from "./engine/lib/types.ts";

export const wikiConfiguration: WikiConfiguration = {
  siteTitle: "Study Wiki",
  serverPort: 5050,

  // ---- page types: the reusable body shapes ----
  pageTypes: [
    {
      identifier: "theory",
      layout: "sections",
      metaLabel: "Theory Masterfile",
      tocTitle: "Theory · Contents",
      tocAccent: "insight",
      sections: [
        { id: "lead", tocLabel: "Definition", heading: null },
        { id: "signals", tocLabel: "Recognition Signals", heading: "Recognition Signals — when to reach for it" },
        { id: "terminology", tocLabel: "Terminology Decoder", heading: "Terminology Decoder" },
        { id: "mental-model", tocLabel: "Mental Model", heading: "Mental Model" },
        { id: "pseudocode", tocLabel: "Pseudocode Primer", heading: "Pseudocode Primer" },
        { id: "iterative", tocLabel: "Iterative-Only Pattern", heading: "Iterative-Only Solution Pattern" },
        { id: "swift", tocLabel: "Swift Translation", heading: "Swift Translation" },
        { id: "variants", tocLabel: "Variant Catalog", heading: "Variant Catalog" },
        { id: "complexity", tocLabel: "Complexity Analysis", heading: "Complexity Analysis" },
        { id: "pitfalls", tocLabel: "Common Pitfalls", heading: "Common Pitfalls" },
        { id: "edge-cases", tocLabel: "Edge Cases", heading: "Edge Cases to Verbalize" },
        { id: "cheatsheet", tocLabel: "Cheat Sheet", heading: "Cheat Sheet" },
        { id: "practice", tocLabel: "Demonstrated in Practice", heading: "Demonstrated in Practice" },
        { id: "solo", tocLabel: "Solo Problem", heading: "Solo Practice Problem" },
      ],
    },
    {
      identifier: "walkthrough",
      layout: "sections",
      metaLabel: "Walkthrough Masterfile",
      tocTitle: "Walkthrough · Contents",
      tocAccent: "info",
      sections: [
        { id: "lead", tocLabel: "The Problem", heading: null },
        { id: "reading", tocLabel: "Reading the Problem", heading: "Reading the Problem — insights from the statement" },
        { id: "edge-cases", tocLabel: "Edge Case Inventory", heading: "Edge Case Inventory" },
        { id: "hints", tocLabel: "Try It Yourself First", heading: "Try It Yourself First" },
        { id: "simulation", tocLabel: "Interview Simulation", heading: "Interview Simulation" },
        { id: "approach", tocLabel: "Why This Approach", heading: "Why This Approach" },
        { id: "structures", tocLabel: "Data Structures", heading: "Data Structure Choice" },
        { id: "dryrun", tocLabel: "Pseudocode Dry Run", heading: "Pseudocode Dry Run" },
        { id: "swift", tocLabel: "Swift Solution", heading: "Swift Solution — iterative" },
        { id: "code-dry-run", tocLabel: "Code Dry Run", heading: "Code Dry Run — the Swift solution, traced" },
        { id: "qmap", tocLabel: "Question → Code Map", heading: "Question → Code Map" },
        { id: "complexity", tocLabel: "Complexity", heading: "Complexity" },
        { id: "followups", tocLabel: "Follow-Up Bank", heading: "Follow-Up Question Bank" },
        { id: "decoder", tocLabel: "Theory Decoder", heading: "Theory Decoder" },
        { id: "parent", tocLabel: "Parent Theory", heading: "Parent Theory" },
      ],
    },
    {
      identifier: "reference",
      layout: "flat",
      metaLabel: "Reference",
      tocTitle: "Reference · Contents",
      sections: [
        { id: "lead", tocLabel: "Overview", heading: null },
        { id: "topic-1", tocLabel: "First Topic", heading: "TODO First Topic" },
        { id: "topic-2", tocLabel: "Second Topic", heading: "TODO Second Topic" },
      ],
    },
    {
      // Framework/platform knowledge, as opposed to the algorithm-shaped
      // "theory" type: no complexity analysis, no solo problem. Built around
      // the wrong-then-right shape the source references already use.
      identifier: "ios-topic",
      layout: "sections",
      metaLabel: "iOS Topic",
      tocTitle: "iOS Topic · Contents",
      tocAccent: "tip",
      sections: [
        { id: "lead", tocLabel: "Definition", heading: null },
        { id: "mental-model", tocLabel: "Mental Model", heading: "Mental Model — how to think about it" },
        { id: "signals", tocLabel: "When It Applies", heading: "When It Applies" },
        { id: "api", tocLabel: "The API", heading: "The API — types, modifiers, signatures" },
        { id: "patterns", tocLabel: "Patterns", heading: "Patterns That Work" },
        { id: "antipatterns", tocLabel: "Anti-Patterns", heading: "Anti-Patterns — and the fix" },
        { id: "pitfalls", tocLabel: "Pitfalls", heading: "Pitfalls & Gotchas" },
        { id: "related", tocLabel: "Related Topics", heading: "Related Topics" },
        { id: "sources", tocLabel: "Sources", heading: "Sources" },
      ],
    },
  ],

  // ---- domains: the knowledge trees ----
  //
  // Each `folder` below is ONE path segment, not a path. The full folder
  // path is built by walking this tree, so every folder name is written
  // exactly once — renaming one is a single-word edit here, and every
  // generated link follows on the next build. Authored links never contain
  // folder names at all (see engine/lib/links.ts).
  domains: [
    {
      identifier: "leetcode",
      label: "LeetCode",
      folder: "leetcode",
      categories: [
        {
          identifier: "theory",
          label: "Theory",
          folder: "theory",
          layout: "sections",
          pageType: "theory",
          pageBodyCategory: "theory",
          requiresDifficulty: false,
          sections: [
            { identifier: "arrays", label: "Arrays & Hashing" },
            { identifier: "intervals", label: "Intervals" },
            { identifier: "strings", label: "Strings & Simulation" },
            { identifier: "stacks_queues", label: "Stacks & Queues" },
            { identifier: "design", label: "Object & System Design" },
            { identifier: "trees", label: "Trees" },
            { identifier: "graphs", label: "Graphs" },
          ],
        },
        {
          identifier: "walkthroughs",
          label: "Walkthroughs",
          folder: "walkthroughs",
          layout: "flat",
          pageType: "walkthrough",
          pageBodyCategory: "walkthrough",
          requiresDifficulty: true,
          flatSort: "problemNumber",
          filenamePattern: "^(LC\\d+|CUSTOM\\d+_[A-Za-z0-9_]+)_master\\.html$",
        },
        {
          identifier: "reference",
          label: "Review & Reference",
          folder: "reference",
          layout: "flat",
          pageType: "reference",
          pageBodyCategory: "reference",
          requiresDifficulty: false,
          flatSort: "declaredOrder",
        },
      ],
    },
    {
      identifier: "ios",
      label: "iOS",
      folder: "ios",
      categories: [
        {
          // A parent category: holds sub-categories, not pages. Its own
          // pages would live in ios/swiftui/<child>/<section>/.
          identifier: "swiftui",
          label: "SwiftUI",
          folder: "swiftui",
          layout: "sections",
          pageType: "ios-topic",
          pageBodyCategory: "ios-topic",
          requiresDifficulty: false,
          children: [
            {
              identifier: "swiftui-theory",
              label: "Theory",
              folder: "theory",
              layout: "sections",
              pageType: "ios-topic",
              pageBodyCategory: "ios-topic",
              requiresDifficulty: false,
              sections: [
                { identifier: "fundamentals", label: "Fundamentals" },
                { identifier: "state", label: "State & Data Flow" },
                { identifier: "screens", label: "Building Screens" },
              ],
            },
          ],
        },
        {
          identifier: "concurrency",
          label: "Concurrency",
          folder: "concurrency",
          layout: "sections",
          pageType: "ios-topic",
          pageBodyCategory: "ios-topic",
          requiresDifficulty: false,
          children: [
            {
              identifier: "concurrency-theory",
              label: "Theory",
              folder: "theory",
              layout: "sections",
              pageType: "ios-topic",
              pageBodyCategory: "ios-topic",
              requiresDifficulty: false,
              sections: [
                { identifier: "fundamentals", label: "Fundamentals" },
                { identifier: "isolation", label: "Isolation & Data Races" },
                { identifier: "patterns", label: "Applied Patterns" },
              ],
            },
          ],
        },
      ],
    },
  ],
};
