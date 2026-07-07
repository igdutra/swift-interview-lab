// ============================================================
// new-page.ts — scaffold a new wiki page with correct wiring.
//
//   node wiki/tools/new-page.ts theory <section> <filename>
//   node wiki/tools/new-page.ts walkthroughs <filename>
//   node wiki/tools/new-page.ts reference <filename>
//
// Examples:
//   node wiki/tools/new-page.ts theory graphs union_find_deep_dive_master.html
//   node wiki/tools/new-page.ts walkthroughs LC121_master.html
//
// The file lands with TODO placeholders; fill the metadata block
// and the sections, then run build.ts + check.ts.
// ============================================================

import { existsSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { wikiConfiguration } from "./wiki.config.ts";
import { rootPrefixForDepth } from "./lib/derive.ts";
import {
  renderArticleBody,
  renderPageShell,
  renderReferenceBody,
  THEORY_SECTIONS,
  WALKTHROUGH_SECTIONS,
} from "./lib/templates.ts";
import type { PageMeta } from "./lib/types.ts";

const wikiRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const commandArguments = process.argv.slice(2);

function fail(message: string): never {
  console.error(`✘ ${message}`);
  console.error(
    "\nusage:\n" +
      "  node wiki/tools/new-page.ts theory <section> <filename>\n" +
      "  node wiki/tools/new-page.ts walkthroughs <filename>\n" +
      "  node wiki/tools/new-page.ts reference <filename>",
  );
  process.exit(1);
}

const categoryIdentifier = commandArguments[0];
const allCategories = wikiConfiguration.domains.flatMap((domain) => domain.categories);
const category = allCategories.find((candidate) => candidate.identifier === categoryIdentifier);
if (category === undefined) {
  fail(`unknown category "${categoryIdentifier ?? ""}" — expected one of: ${allCategories.map((candidate) => candidate.identifier).join(", ")}`);
}

let relativePath: string;
let fileName: string;
if (category.layout === "sections") {
  const sectionIdentifier = commandArguments[1];
  fileName = commandArguments[2];
  const section = (category.sections ?? []).find((candidate) => candidate.identifier === sectionIdentifier);
  if (section === undefined) {
    fail(`unknown section "${sectionIdentifier ?? ""}" — expected one of: ${(category.sections ?? []).map((candidate) => candidate.identifier).join(", ")}`);
  }
  if (fileName === undefined || !fileName.endsWith("_master.html")) {
    fail(`theory filenames must end in _master.html (got "${fileName ?? ""}")`);
  }
  relativePath = `${category.folder}/${section.identifier}/${fileName}`;
} else {
  fileName = commandArguments[1];
  if (fileName === undefined || !fileName.endsWith(".html")) {
    fail(`expected an .html filename (got "${fileName ?? ""}")`);
  }
  if (category.filenamePattern !== undefined && !new RegExp(category.filenamePattern).test(fileName)) {
    fail(`filename "${fileName}" does not match the ${category.identifier} pattern ${category.filenamePattern}`);
  }
  relativePath = `${category.folder}/${fileName}`;
}

const absolutePath = join(wikiRoot, relativePath);
if (existsSync(absolutePath)) {
  fail(`${relativePath} already exists — refusing to overwrite`);
}

const depth = relativePath.split("/").length - 1;
const rootPrefix = rootPrefixForDepth(depth);
const problemNumberMatch = fileName.match(/^LC(\d+)_/);
const isWalkthrough = category.identifier === "walkthroughs";

const pageMeta: PageMeta = {
  title: problemNumberMatch !== null ? `LC ${problemNumberMatch[1]} — TODO Problem Name` : "TODO Title",
  nav: problemNumberMatch !== null ? `LC ${problemNumberMatch[1]}` : "TODO",
  topics: ["TODO"],
  blurb: "TODO — one line for the hub card.",
  ...(isWalkthrough ? { difficulty: "M" as const } : {}),
};

const isTheory = category.layout === "sections";
const titleSuffix = isWalkthrough ? "Walkthrough Masterfile" : isTheory ? "Theory Masterfile" : "Study Wiki";
const metaLine = isWalkthrough
  ? "<span>Walkthrough Masterfile</span><span>·</span>\n    <span>Language: Swift</span><span>·</span>\n    <span>TODO — difficulty · pattern · one-line hook</span>"
  : isTheory
    ? "<span>Theory Masterfile</span><span>·</span>\n    <span>TODO — topic line</span>"
    : "<span>Reference</span><span>·</span>\n    <span>TODO — topic line</span>";

// Theory and walkthrough pages follow their masterfile section skeletons;
// every other category (reference) gets the flat h2-driven document shape.
const bodyContent = isWalkthrough
  ? renderArticleBody(pageMeta.title, metaLine, WALKTHROUGH_SECTIONS)
  : isTheory
    ? renderArticleBody(pageMeta.title, metaLine, THEORY_SECTIONS)
    : renderReferenceBody(pageMeta.title, metaLine);

const pageHtml = renderPageShell({
  rootPrefix,
  htmlTitle: `${pageMeta.title} · ${titleSuffix}`,
  pageMeta,
  bodyCategory: category.pageBodyCategory,
  bodyContent,
});

writeFileSync(absolutePath, pageHtml);
console.log(`created ${relativePath}`);
console.log("\nnext steps:");
console.log("  1. Fill the data-page-meta block (title, nav, topics, blurb).");
console.log("  2. Write the sections (see the wiki skill's format references).");
console.log("  3. node wiki/tools/build.ts");
console.log("  4. node wiki/tools/check.ts");
