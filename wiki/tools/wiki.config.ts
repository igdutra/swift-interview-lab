// ============================================================
// wiki.config.ts — THIS wiki's structure, in one place.
//
// The engine (lib/, build.ts, check.ts, the browser nav) knows
// nothing about "theory" or "arrays" — it iterates this file.
// Adding a whole new knowledge domain (e.g. design systems)
// means adding one entry to `domains` and creating its folder.
//
// Section order below = display order in the nav and hub grids.
// ============================================================

import type { WikiConfiguration } from "./lib/types.ts";

export const wikiConfiguration: WikiConfiguration = {
  siteTitle: "Study Wiki",
  serverPort: 5050,
  domains: [
    {
      identifier: "leetcode",
      label: "LeetCode",
      categories: [
        {
          identifier: "theory",
          label: "Theory",
          folder: "theory",
          layout: "sections",
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
          pageBodyCategory: "reference",
          requiresDifficulty: false,
          flatSort: "declaredOrder",
        },
      ],
    },
  ],
};
