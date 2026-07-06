// ============================================================
// migrate.ts — ONE-TIME migration to the manifest architecture.
// Deleted once the migration is complete.
//
//   node wiki/tools/migrate.ts
//
// For every wiki page:
//   1. injects the data-page-meta block (from the old pages.js
//      registry, or harvested from hub xref-cards for the pages
//      that were never registered);
//   2. stamps data-toc-label attributes from the hand-written
//      TOC so the generated TOC keeps today's exact labels;
//   3. deletes the hand-written <nav class="toc-col"> block;
//   4. swaps pages.js → manifest.js and adds toc.js;
//   5. replaces the hub inline centering style with a class.
//
// Prints a report of everything it could not resolve.
// ============================================================

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join, normalize, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { scanWikiPages } from "./lib/scan.ts";
import { renderMetaBlock } from "./lib/templates.ts";
import type { Difficulty, PageMeta } from "./lib/types.ts";

const wikiRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const reportLines: string[] = [];

function decodeEntities(text: string): string {
  return text
    .replaceAll("&amp;", "&")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&quot;", '"')
    .replaceAll("&#39;", "'")
    .replaceAll("&nbsp;", " ");
}

function stripTags(html: string): string {
  return html.replace(/<[^>]+>/g, "").replace(/\s+/g, " ").trim();
}

function escapeAttribute(text: string): string {
  return text.replaceAll("&", "&amp;").replaceAll('"', "&quot;");
}

// ---------- 1. load the legacy registry ----------

interface LegacyEntry {
  cat: "theory" | "walkthrough" | "reference";
  path: string;
  nav: string;
  title: string;
  topics: string[];
  difficulty?: Difficulty;
  blurb: string;
}

const legacySource = readFileSync(join(wikiRoot, "_shared", "pages.js"), "utf8");
const legacyEntries = new Function(`${legacySource}; return WIKI_PAGES;`)() as LegacyEntry[];
const legacyByPath = new Map(legacyEntries.map((entry) => [entry.path, entry]));

// ---------- 2. harvest card data for unregistered pages ----------

interface HarvestedCard {
  title: string;
  topics: string[];
  blurb: string;
}

const harvestedCards = new Map<string, HarvestedCard>();
const CARD_PATTERN = /<a class="(?:xref-card|backref-card)" href="([^"#]+)(?:#[^"]*)?">([\s\S]*?)<\/a>/g;

function harvestCardsFrom(pagePath: string): void {
  const html = readFileSync(join(wikiRoot, pagePath), "utf8");
  const pageFolder = dirname(pagePath) === "." ? "" : dirname(pagePath);
  for (const cardMatch of html.matchAll(CARD_PATTERN)) {
    const targetPath = normalize(join(pageFolder, cardMatch[1])).replaceAll("\\", "/");
    if (harvestedCards.has(targetPath)) {
      continue;
    }
    const cardBody = cardMatch[2];
    const title = cardBody.match(/<span class="ref-title">([\s\S]*?)<\/span>/)?.[1];
    const topics = cardBody.match(/<span class="ref-topics">([\s\S]*?)<\/span>/)?.[1];
    const blurb = cardBody.match(/<span class="ref-desc">([\s\S]*?)<\/span>/)?.[1];
    if (title !== undefined && blurb !== undefined) {
      harvestedCards.set(targetPath, {
        title: decodeEntities(stripTags(title)),
        topics: topics === undefined ? [] : decodeEntities(stripTags(topics)).split(" · ").map((topic) => topic.trim()),
        blurb: decodeEntities(stripTags(blurb)),
      });
    }
  }
}

const allPages = scanWikiPages(wikiRoot);
for (const pagePath of allPages) {
  if (pagePath.endsWith("index.html")) {
    harvestCardsFrom(pagePath);
  }
}

// ---------- 3. decide each page's metadata ----------

const HAND_WRITTEN_META: Record<string, PageMeta> = {
  "index.html": {
    title: "Study Wiki",
    nav: "Home",
    topics: ["Algorithms", "Data Structures", "Swift"],
    blurb: "Theory masterfiles ↔ LeetCode walkthroughs, with full interview simulations.",
  },
  "reference/index.html": {
    title: "Review & Reference Hub",
    nav: "All Reference",
    topics: ["Snippets", "Pattern Recognition", "Complexity", "Process"],
    blurb:
      "The distilled cram layer: Swift code snippets & gotchas, pattern-recognition routing, plus interview stages, sorting trade-offs, and Big-O cheat sheets.",
  },
  "theory/intervals/intervals_overview_master.html": {
    title: "Intervals Overview",
    nav: "Intervals Overview",
    topics: ["Arrays", "Sorting", "Sweep"],
    blurb:
      "Sort-then-sweep interval technique — merge, overlap, insert, gap-find, and split/handoff coverage variants.",
  },
};

function metaForPage(pagePath: string): PageMeta {
  const handWritten = HAND_WRITTEN_META[pagePath];
  if (handWritten !== undefined) {
    return handWritten;
  }
  const legacyEntry = legacyByPath.get(pagePath);
  if (legacyEntry !== undefined) {
    const declaredOrder =
      legacyEntry.cat === "reference"
        ? legacyEntries.filter((entry) => entry.cat === "reference").findIndex((entry) => entry.path === pagePath) + 1
        : undefined;
    return {
      title: legacyEntry.title,
      nav: legacyEntry.nav,
      topics: legacyEntry.topics,
      blurb: legacyEntry.blurb,
      difficulty: legacyEntry.difficulty,
      order: declaredOrder,
    };
  }
  const harvested = harvestedCards.get(pagePath);
  if (harvested !== undefined) {
    return {
      title: harvested.title,
      nav: harvested.title,
      topics: harvested.topics.length > 0 ? harvested.topics : ["TODO"],
      blurb: harvested.blurb,
    };
  }
  reportLines.push(`NO METADATA SOURCE — wrote TODO placeholders: ${pagePath}`);
  return { title: "TODO", nav: "TODO", topics: ["TODO"], blurb: "TODO" };
}

// ---------- 4. transform every page ----------

const TOC_BLOCK_PATTERN = /(?:<!--[^>]*TOC[^>]*-->\s*)?<nav class="toc-col">[\s\S]*?<\/nav>\s*/;
const TOC_LINK_PATTERN = /<a href="#([^"]+)"[^>]*>([\s\S]*?)<\/a>/g;
const PAGES_SCRIPT_PATTERN = /<script src="([^"]*)_shared\/pages\.js"><\/script>\s*\n?\s*<script src="[^"]*_shared\/nav\.js"><\/script>/;

const inlineStyleInventory = new Map<string, number>();
let migratedCount = 0;

for (const pagePath of allPages) {
  const absolutePath = join(wikiRoot, pagePath);
  let html = readFileSync(absolutePath, "utf8");

  if (html.includes("data-page-meta")) {
    reportLines.push(`SKIPPED (already migrated): ${pagePath}`);
    continue;
  }

  // 4a. harvest this page's own TOC labels, then delete the TOC block.
  const tocBlockMatch = html.match(TOC_BLOCK_PATTERN);
  const tocLabels = new Map<string, string>();
  if (tocBlockMatch !== null) {
    for (const linkMatch of tocBlockMatch[0].matchAll(TOC_LINK_PATTERN)) {
      const anchorId = linkMatch[1];
      const label = decodeEntities(stripTags(linkMatch[2].replace(/<span class="toc-num">\d+<\/span>/, "")));
      if (label !== "" && !tocLabels.has(anchorId)) {
        tocLabels.set(anchorId, label);
      }
    }
    html = html.replace(TOC_BLOCK_PATTERN, "");
  }

  // 4b. stamp the harvested labels onto their anchor elements.
  for (const [anchorId, label] of tocLabels) {
    const idAttribute = `id="${anchorId}"`;
    if (html.includes(idAttribute)) {
      html = html.replace(idAttribute, `${idAttribute} data-toc-label="${escapeAttribute(label)}"`);
    } else {
      reportLines.push(`TOC label had no anchor to stamp: ${pagePath} → #${anchorId} ("${label}")`);
    }
  }

  // 4c. inject the metadata block right after <title>.
  const pageMeta = metaForPage(pagePath);
  html = html.replace(/(<title>[\s\S]*?<\/title>)/, `$1\n${renderMetaBlock(pageMeta)}`);

  // 4d. swap the script includes.
  const scriptsMatch = html.match(PAGES_SCRIPT_PATTERN);
  if (scriptsMatch === null) {
    reportLines.push(`SCRIPT INCLUDES NOT FOUND (left untouched): ${pagePath}`);
  } else {
    const rootPrefix = scriptsMatch[1];
    html = html.replace(
      PAGES_SCRIPT_PATTERN,
      `<script src="${rootPrefix}_shared/manifest.js"></script>\n<script src="${rootPrefix}_shared/nav.js"></script>\n<script src="${rootPrefix}_shared/toc.js"></script>`,
    );
  }

  // 4e. hub centering: class instead of inline style.
  html = html.replaceAll('class="content" style="margin: 0 auto;"', 'class="content content-centered"');

  // 4f. inventory whatever inline styles remain (fixed by hand afterwards).
  for (const styleMatch of html.matchAll(/style="([^"]*)"/g)) {
    inlineStyleInventory.set(styleMatch[1], (inlineStyleInventory.get(styleMatch[1]) ?? 0) + 1);
  }

  writeFileSync(absolutePath, html);
  migratedCount += 1;
}

// ---------- 5. report ----------

console.log(`migrated ${migratedCount} of ${allPages.length} pages.\n`);
if (reportLines.length > 0) {
  console.log("attention needed:");
  for (const reportLine of reportLines) {
    console.log(`  • ${reportLine}`);
  }
}
if (inlineStyleInventory.size > 0) {
  console.log("\nremaining inline styles (map each to a wiki.css class):");
  const sortedInventory = [...inlineStyleInventory.entries()].sort((first, second) => second[1] - first[1]);
  for (const [styleValue, occurrenceCount] of sortedInventory) {
    console.log(`  ${String(occurrenceCount).padStart(4)} × style="${styleValue}"`);
  }
}
console.log("\nnext: rewrite the hub pages, run tsc -p wiki/tools/browser, node wiki/tools/build.ts, delete _shared/pages.js, node wiki/tools/check.ts");
