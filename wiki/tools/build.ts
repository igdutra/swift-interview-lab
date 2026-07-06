// ============================================================
// build.ts — regenerate wiki/_shared/manifest.js from the pages
// on disk. Disk is the source of truth: every page carries its
// own data-page-meta block, and this script assembles them.
//
//   node wiki/tools/build.ts
// ============================================================

import { writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { wikiConfiguration } from "./wiki.config.ts";
import { scanWikiPages } from "./lib/scan.ts";
import { extractPage } from "./lib/extract.ts";
import { assemblePageRecord, buildManifest, renderManifestFile } from "./lib/manifest.ts";
import type { PageRecord } from "./lib/types.ts";

const wikiRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const manifestPath = join(wikiRoot, "_shared", "manifest.js");

const pagePaths = scanWikiPages(wikiRoot);
const records: PageRecord[] = [];
const failures: string[] = [];

for (const pagePath of pagePaths) {
  const scannedPage = extractPage(wikiRoot, pagePath);
  const { record, errors } = assemblePageRecord(wikiConfiguration, scannedPage);
  if (record !== null) {
    records.push(record);
  } else {
    for (const error of errors) {
      failures.push(`${pagePath}: ${error}`);
    }
  }
}

if (failures.length > 0) {
  console.error(`build failed — ${failures.length} problem(s):\n`);
  for (const failure of failures) {
    console.error(`  ✘ ${failure}`);
  }
  console.error(`\nFix the pages above (or run check.ts for the full report), then rebuild.`);
  process.exit(1);
}

const manifest = buildManifest(wikiConfiguration, records);
writeFileSync(manifestPath, renderManifestFile(manifest));
console.log(`manifest.js written — ${records.length} pages across ${pagePaths.length} scanned files.`);
