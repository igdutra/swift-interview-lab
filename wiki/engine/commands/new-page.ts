// ============================================================
// new-page.ts — scaffold a new wiki page with correct wiring.
//
//   node wiki/engine/commands/new-page.ts <category> [section] <filename>
//
// The category list, the sections it accepts, and the body shape
// it scaffolds all come from wiki.config.ts — this script hardcodes
// no content names. Run it with no arguments to see the usage built
// from the current config.
//
// The file lands with TODO placeholders; fill the metadata block
// and the sections, then run build.ts + check.ts.
// ============================================================

import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { wikiConfiguration } from "../../wiki.config.ts";
import { listCategories, rootPrefixForDepth } from "../lib/derive.ts";
import { renderArticleBody, renderFlatBody, renderPageShell } from "../lib/templates.ts";
import { CONTENT_ROOT } from "../lib/paths.ts";
import type { PageMeta } from "../lib/types.ts";

const commandArguments = process.argv.slice(2);

// Walk the config tree so nested sub-categories are scaffoldable too, and
// so the folder path comes from the walk rather than a single `folder`.
const scaffoldableCategories = listCategories(wikiConfiguration).filter(
  ({ category: candidate }) => (candidate.children ?? []).length === 0,
);

/** Usage lines built from the live config, one per category. */
function usageLines(): string {
  return scaffoldableCategories
    .map(({ category: eachCategory }) =>
      eachCategory.layout === "sections"
        ? `  npm run new ${eachCategory.identifier} <section> <filename>`
        : `  npm run new ${eachCategory.identifier} <filename>`,
    )
    .join("\n");
}

function fail(message: string): never {
  console.error(`✘ ${message}`);
  console.error(`\nusage:\n${usageLines()}`);
  process.exit(1);
}

const categoryIdentifier = commandArguments[0];
const resolvedCategory = scaffoldableCategories.find(
  ({ category: candidate }) => candidate.identifier === categoryIdentifier,
);
if (resolvedCategory === undefined) {
  fail(
    `unknown category "${categoryIdentifier ?? ""}" — expected one of: ` +
      scaffoldableCategories.map(({ category: candidate }) => candidate.identifier).join(", "),
  );
}
const category = resolvedCategory.category;
const categoryFolderPath = resolvedCategory.folderSegments.join("/");

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
  relativePath = `${categoryFolderPath}/${section.identifier}/${fileName}`;
} else {
  fileName = commandArguments[1];
  if (fileName === undefined || !fileName.endsWith(".html")) {
    fail(`expected an .html filename (got "${fileName ?? ""}")`);
  }
  if (category.filenamePattern !== undefined && !new RegExp(category.filenamePattern).test(fileName)) {
    fail(`filename "${fileName}" does not match the ${category.identifier} pattern ${category.filenamePattern}`);
  }
  relativePath = `${categoryFolderPath}/${fileName}`;
}

const absolutePath = join(CONTENT_ROOT, relativePath);
if (existsSync(absolutePath)) {
  fail(`${relativePath} already exists — refusing to overwrite`);
}

// The page's shape comes entirely from the page type its category
// references — no per-category branching in the engine.
const pageType = wikiConfiguration.pageTypes.find((candidate) => candidate.identifier === category.pageType);
if (pageType === undefined) {
  fail(`category "${category.identifier}" references unknown page type "${category.pageType}"`);
}
if (pageType.sections === undefined || pageType.sections.length === 0) {
  fail(`page type "${pageType.identifier}" has no section skeleton`);
}

const depth = relativePath.split("/").length - 1;
const rootPrefix = rootPrefixForDepth(depth);
const problemNumberMatch = fileName.match(/^LC(\d+)_/);

const pageMeta: PageMeta = {
  title: problemNumberMatch !== null ? `LC ${problemNumberMatch[1]} — TODO Problem Name` : "TODO Title",
  nav: problemNumberMatch !== null ? `LC ${problemNumberMatch[1]}` : "TODO",
  topics: ["TODO"],
  blurb: "TODO — one line for the hub card.",
  ...(category.requiresDifficulty ? { difficulty: "M" as const } : {}),
};

const metaLine = category.requiresDifficulty
  ? `<span>${pageType.metaLabel}</span><span>·</span>\n    <span>Language: Swift</span><span>·</span>\n    <span>TODO — difficulty · pattern · one-line hook</span>`
  : `<span>${pageType.metaLabel}</span><span>·</span>\n    <span>TODO — topic line</span>`;

const bodyContent =
  pageType.layout === "sections"
    ? renderArticleBody(pageMeta.title, metaLine, pageType.sections)
    : renderFlatBody(pageMeta.title, metaLine, pageType.sections);

const pageHtml = renderPageShell({
  rootPrefix,
  htmlTitle: `${pageMeta.title} · ${pageType.metaLabel}`,
  pageMeta,
  bodyCategory: category.pageBodyCategory,
  bodyContent,
});

// New sections start as empty folders, so create the target directory
// rather than failing with a bare ENOENT from writeFileSync.
mkdirSync(dirname(absolutePath), { recursive: true });
writeFileSync(absolutePath, pageHtml);
console.log(`created ${relativePath}`);
console.log("\nnext steps:");
console.log("  1. Fill the data-page-meta block (title, nav, topics, blurb).");
console.log("  2. Write the sections (see the wiki skill's format references).");
console.log("  3. npm run build");
console.log("  4. npm run check");
