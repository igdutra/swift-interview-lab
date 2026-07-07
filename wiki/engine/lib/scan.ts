// ============================================================
// scan.ts — find every content HTML file under the content root.
// The content root (wiki/content/) holds only authored pages, so
// paths are relative to it and every .html file is a page.
// ============================================================

import { readdirSync } from "node:fs";
import { join } from "node:path";

/** Folders that never contain content pages. */
const EXCLUDED_FOLDERS = new Set(["node_modules"]);

/**
 * Returns content-relative paths (forward slashes) of every .html file,
 * sorted alphabetically for deterministic output.
 */
export function scanWikiPages(contentRoot: string): string[] {
  const foundPages: string[] = [];
  walkDirectory(contentRoot, "", foundPages);
  return foundPages.sort();
}

function walkDirectory(contentRoot: string, relativeFolder: string, foundPages: string[]): void {
  const absoluteFolder = relativeFolder === "" ? contentRoot : join(contentRoot, relativeFolder);
  for (const entry of readdirSync(absoluteFolder, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) {
      continue;
    }
    const relativePath = relativeFolder === "" ? entry.name : `${relativeFolder}/${entry.name}`;
    if (entry.isDirectory()) {
      if (!EXCLUDED_FOLDERS.has(entry.name)) {
        walkDirectory(contentRoot, relativePath, foundPages);
      }
    } else if (entry.name.endsWith(".html")) {
      foundPages.push(relativePath);
    }
  }
}
