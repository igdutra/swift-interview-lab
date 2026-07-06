// ============================================================
// check.ts — validate every wiki page against the standard.
//
//   node wiki/tools/check.ts
//
// Errors (exit 1): structural problems that break navigation,
// registration, links, or the closed-vocabulary rules.
// Warnings (exit 0): consistency issues worth fixing.
// ============================================================

import { existsSync, readFileSync } from "node:fs";
import { dirname, join, normalize, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { wikiConfiguration } from "./wiki.config.ts";
import { scanWikiPages } from "./lib/scan.ts";
import { extractPage } from "./lib/extract.ts";
import { assemblePageRecord, buildManifest, renderManifestFile } from "./lib/manifest.ts";
import { rootPrefixForDepth } from "./lib/derive.ts";
import type { PageRecord, ScannedPage } from "./lib/types.ts";

const wikiRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const errors: string[] = [];
const warnings: string[] = [];

function reportError(pagePath: string, message: string): void {
  errors.push(`${pagePath}: ${message}`);
}
function reportWarning(pagePath: string, message: string): void {
  warnings.push(`${pagePath}: ${message}`);
}

function decodeEntities(text: string): string {
  return text
    .replaceAll("&amp;", "&")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&quot;", '"')
    .replaceAll("&#39;", "'")
    .replaceAll("&nbsp;", " ");
}

/** Resolve an href relative to a page into a wiki-relative path + fragment. */
function resolveHref(pagePath: string, href: string): { targetPath: string; fragment: string | null } | null {
  const [rawTarget, fragment] = href.split("#", 2);
  const pageFolder = dirname(pagePath) === "." ? "" : dirname(pagePath);
  let combined = normalize(join(pageFolder, rawTarget)).replaceAll("\\", "/");
  if (combined.startsWith("..")) {
    return null; // escapes the wiki root — reported by the caller
  }
  if (combined === "." || combined === "") {
    combined = "index.html";
  } else if (href.endsWith("/") || !combined.includes(".")) {
    combined = `${combined}/index.html`;
  }
  return { targetPath: combined, fragment: fragment ?? null };
}

// ---------- scan + per-page assembly ----------

const pagePaths = scanWikiPages(wikiRoot);
const scannedPages = new Map<string, ScannedPage>();
const records = new Map<string, PageRecord>();

for (const pagePath of pagePaths) {
  const scannedPage = extractPage(wikiRoot, pagePath);
  scannedPages.set(pagePath, scannedPage);
  const { record, errors: assemblyErrors } = assemblePageRecord(wikiConfiguration, scannedPage);
  for (const assemblyError of assemblyErrors) {
    reportError(pagePath, assemblyError);
  }
  if (record !== null) {
    records.set(pagePath, record);
  }
}

const categoriesById = new Map(
  wikiConfiguration.domains.flatMap((domain) => domain.categories).map((category) => [category.identifier, category]),
);

// ---------- per-page checks ----------

for (const [pagePath, scannedPage] of scannedPages) {
  const record = records.get(pagePath);

  // data-category must match the derived role.
  if (record !== undefined) {
    const isHubLike = record.role === "hub" || record.role === "home";
    const expectedBodyCategory = isHubLike ? "hub" : categoriesById.get(record.category)?.pageBodyCategory;
    if (expectedBodyCategory !== undefined && scannedPage.bodyCategory !== expectedBodyCategory) {
      reportError(
        pagePath,
        `<body data-category="${scannedPage.bodyCategory ?? ""}"> but its location requires "${expectedBodyCategory}"`,
      );
    }
  }

  // Boilerplate wiring at the correct relative depth.
  const depth = pagePath.split("/").length - 1;
  const rootPrefix = rootPrefixForDepth(depth);
  const acceptedPrefixes = depth === 0 ? ["", "./"] : [rootPrefix];
  const hasWiring = (suffix: string) =>
    acceptedPrefixes.some((prefix) => scannedPage.html.includes(`${prefix}_shared/${suffix}`));
  if (!hasWiring("wiki.css")) {
    reportError(pagePath, `missing or wrong-depth stylesheet link (expected ${rootPrefix}_shared/wiki.css)`);
  }
  for (const scriptName of ["manifest.js", "nav.js", "toc.js"]) {
    if (!hasWiring(scriptName)) {
      reportError(pagePath, `missing or wrong-depth script include (expected ${rootPrefix}_shared/${scriptName})`);
    }
  }
  const manifestPosition = scannedPage.html.indexOf("_shared/manifest.js");
  const navPosition = scannedPage.html.indexOf("_shared/nav.js");
  const tocPosition = scannedPage.html.indexOf("_shared/toc.js");
  if (manifestPosition !== -1 && navPosition !== -1 && tocPosition !== -1) {
    if (!(manifestPosition < navPosition && navPosition < tocPosition)) {
      reportError(pagePath, "script includes must be ordered manifest.js → nav.js → toc.js");
    }
  }
  if (!scannedPage.html.includes('<nav id="topnav"')) {
    reportError(pagePath, `missing <nav id="topnav"> placeholder`);
  }
  if (scannedPage.html.includes("pages.js")) {
    reportError(pagePath, "references the retired pages.js registry");
  }
  if (scannedPage.html.includes('class="toc-col"')) {
    reportError(pagePath, "carries a hand-written toc-col — the TOC is generated by toc.js now");
  }
  if (scannedPage.html.includes('style="')) {
    const inlineStyleCount = scannedPage.html.split('style="').length - 1;
    reportError(pagePath, `has ${inlineStyleCount} inline style attribute(s) — use wiki.css classes instead`);
  }

  // TOC-ability.
  const optedOutOfToc = scannedPage.html.includes("data-no-toc");
  const isHubLikePage = record === undefined || record.role === "hub" || record.role === "home";
  if (!isHubLikePage && !optedOutOfToc) {
    const anchorCount = scannedPage.sectionIds.length > 0 ? scannedPage.sectionIds.length : scannedPage.headingAnchorIds.length;
    if (anchorCount < 2) {
      reportError(pagePath, "has fewer than 2 TOC anchors (section[id] or h2[id]) — add data-no-toc to opt out");
    }
    for (const sectionId of scannedPage.sectionsWithoutTocLabel) {
      reportError(pagePath, `section #${sectionId} has neither an <h2> nor a data-toc-label for the generated TOC`);
    }
  }

  // Duplicate element ids break fragments and the TOC.
  const seenIds = new Set<string>();
  for (const elementId of scannedPage.elementIds) {
    if (seenIds.has(elementId)) {
      reportError(pagePath, `duplicate element id "${elementId}"`);
    }
    seenIds.add(elementId);
  }

  // Link integrity.
  const ownIds = new Set(scannedPage.elementIds);
  for (const fragmentHref of scannedPage.fragmentHrefs) {
    const fragment = fragmentHref.slice(1);
    if (fragment !== "" && !ownIds.has(fragment)) {
      reportError(pagePath, `fragment link ${fragmentHref} has no matching id on the page`);
    }
  }
  for (const relativeHref of scannedPage.relativeHrefs) {
    const resolved = resolveHref(pagePath, relativeHref);
    if (resolved === null) {
      reportError(pagePath, `link "${relativeHref}" escapes the wiki root`);
      continue;
    }
    const targetScanned = scannedPages.get(resolved.targetPath);
    if (targetScanned === undefined) {
      if (!existsSync(join(wikiRoot, resolved.targetPath))) {
        reportError(pagePath, `link "${relativeHref}" points at a missing file (${resolved.targetPath})`);
      }
      continue;
    }
    if (resolved.fragment !== null && !targetScanned.elementIds.includes(resolved.fragment)) {
      reportError(pagePath, `link "${relativeHref}" targets a missing id #${resolved.fragment} in ${resolved.targetPath}`);
    }
  }
  for (const imageSource of scannedPage.imageSources) {
    const resolved = resolveHref(pagePath, imageSource);
    if (resolved !== null && !existsSync(join(wikiRoot, resolved.targetPath))) {
      reportError(pagePath, `image "${imageSource}" is missing on disk`);
    }
  }
}

// ---------- structural checks ----------

for (const category of categoriesById.values()) {
  if (category.layout !== "sections") {
    continue;
  }
  for (const section of category.sections ?? []) {
    const hubPath = `${category.folder}/${section.identifier}/index.html`;
    if (!scannedPages.has(hubPath)) {
      reportError(hubPath, `configured section "${section.identifier}" has no hub index.html`);
    }
  }
}

const problemNumbersSeen = new Map<number, string>();
for (const record of records.values()) {
  if (record.problemNumber !== null) {
    const existingPath = problemNumbersSeen.get(record.problemNumber);
    if (existingPath !== undefined) {
      reportError(record.path, `duplicate problem number ${record.problemNumber} (also ${existingPath})`);
    }
    problemNumbersSeen.set(record.problemNumber, record.path);
  }
}

// Manifest freshness: the committed file must match a fresh build.
const manifestPath = join(wikiRoot, "_shared", "manifest.js");
if (errors.length === 0) {
  const freshManifest = renderManifestFile(buildManifest(wikiConfiguration, [...records.values()]));
  const committedManifest = existsSync(manifestPath) ? readFileSync(manifestPath, "utf8") : "";
  if (freshManifest !== committedManifest) {
    errors.push(`_shared/manifest.js is stale — run: node wiki/tools/build.ts`);
  }
}

// ---------- warnings ----------

// Class vocabulary: every class used on a page should exist in wiki.css.
const wikiCss = readFileSync(join(wikiRoot, "_shared", "wiki.css"), "utf8");
const styledClasses = new Set([...wikiCss.matchAll(/\.([a-zA-Z][\w-]*)/g)].map((match) => match[1]));
for (const [pagePath, scannedPage] of scannedPages) {
  const unknownTokens = [...new Set(scannedPage.classTokens)].filter((token) => !styledClasses.has(token));
  if (unknownTokens.length > 0) {
    reportWarning(pagePath, `uses classes not defined in wiki.css: ${unknownTokens.join(", ")}`);
  }
}

// Cross-reference reciprocity: if A cards to B, B should link back to A.
for (const [pagePath, scannedPage] of scannedPages) {
  for (const cardHref of scannedPage.crossReferenceHrefs) {
    const resolved = resolveHref(pagePath, cardHref);
    if (resolved === null) {
      continue;
    }
    const targetScanned = scannedPages.get(resolved.targetPath);
    if (targetScanned === undefined || resolved.targetPath === pagePath) {
      continue;
    }
    const targetLinksBack = targetScanned.relativeHrefs.some((backHref) => {
      const backResolved = resolveHref(resolved.targetPath, backHref);
      return backResolved !== null && backResolved.targetPath === pagePath;
    });
    if (!targetLinksBack) {
      reportWarning(pagePath, `cards to ${resolved.targetPath}, which never links back (close the loop)`);
    }
  }
}

// Title consistency: <title> should begin with the declared meta title.
for (const [pagePath, record] of records) {
  const scannedPage = scannedPages.get(pagePath);
  if (scannedPage?.htmlTitle == null) {
    continue;
  }
  const decodedTitle = decodeEntities(scannedPage.htmlTitle);
  if (!decodedTitle.startsWith(record.title)) {
    reportWarning(pagePath, `<title> "${decodedTitle}" does not begin with meta title "${record.title}"`);
  }
}

// ---------- report ----------

if (errors.length > 0) {
  console.error(`\n${errors.length} error(s):\n`);
  for (const errorMessage of errors) {
    console.error(`  ✘ ${errorMessage}`);
  }
}
if (warnings.length > 0) {
  console.warn(`\n${warnings.length} warning(s):\n`);
  for (const warningMessage of warnings) {
    console.warn(`  ⚠ ${warningMessage}`);
  }
}
if (errors.length === 0 && warnings.length === 0) {
  console.log(`all checks passed — ${scannedPages.size} pages validated.`);
} else if (errors.length === 0) {
  console.log(`\npassed with warnings — ${scannedPages.size} pages validated.`);
}
process.exit(errors.length > 0 ? 1 : 0);
