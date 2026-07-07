// ============================================================
// build.ts — regenerate wiki/static/generated/manifest.js from
// the pages on disk. Disk is the source of truth: every page
// carries its own data-page-meta block, and this script assembles them.
//
//   node wiki/engine/commands/build.ts
// ============================================================

import { writeFileSync } from "node:fs";
import { wikiConfiguration } from "../../wiki.config.ts";
import { scanWikiPages } from "../lib/scan.ts";
import { extractPage } from "../lib/extract.ts";
import { assemblePageRecord, buildManifest, renderManifestFile } from "../lib/manifest.ts";
import { CONTENT_ROOT, MANIFEST_PATH } from "../lib/paths.ts";
import type { PageRecord } from "../lib/types.ts";

const pagePaths = scanWikiPages(CONTENT_ROOT);
const records: PageRecord[] = [];
const failures: string[] = [];

for (const pagePath of pagePaths) {
  const scannedPage = extractPage(CONTENT_ROOT, pagePath);
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
  console.error(`\nFix the pages above (or run engine/commands/check.ts for the full report), then rebuild.`);
  process.exit(1);
}

const manifest = buildManifest(wikiConfiguration, records);
writeFileSync(MANIFEST_PATH, renderManifestFile(manifest));
console.log(`manifest.js written — ${records.length} pages across ${pagePaths.length} scanned files.`);
