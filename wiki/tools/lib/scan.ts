// ============================================================
// scan.ts — find every content HTML file under the wiki root.
// ============================================================

import { readdirSync } from "node:fs";
import { join } from "node:path";

/** Folders under wiki/ that never contain content pages. */
const EXCLUDED_FOLDERS = new Set(["_shared", "tools", "assets", "node_modules"]);

/**
 * Returns wiki-relative paths (forward slashes) of every .html file,
 * sorted alphabetically for deterministic output.
 */
export function scanWikiPages(wikiRoot: string): string[] {
  const foundPages: string[] = [];
  walkDirectory(wikiRoot, "", foundPages);
  return foundPages.sort();
}

function walkDirectory(wikiRoot: string, relativeFolder: string, foundPages: string[]): void {
  const absoluteFolder = relativeFolder === "" ? wikiRoot : join(wikiRoot, relativeFolder);
  for (const entry of readdirSync(absoluteFolder, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) {
      continue;
    }
    const relativePath = relativeFolder === "" ? entry.name : `${relativeFolder}/${entry.name}`;
    if (entry.isDirectory()) {
      if (!EXCLUDED_FOLDERS.has(entry.name)) {
        walkDirectory(wikiRoot, relativePath, foundPages);
      }
    } else if (entry.name.endsWith(".html")) {
      foundPages.push(relativePath);
    }
  }
}
