// ============================================================
// derive.ts — everything a page's disk location already tells us.
// Path → domain / category / section / role / problem number.
// Driven entirely by wiki.config.ts; no content names hardcoded.
// ============================================================

import type {
  CategoryConfiguration,
  DerivedLocation,
  DomainConfiguration,
  WikiConfiguration,
} from "./types.ts";

const PROBLEM_NUMBER_PATTERN = /^LC(\d+)_/;
const OVERVIEW_FILENAME_PATTERN = /_overview_master\.html$/;

interface CategoryLookup {
  domain: DomainConfiguration;
  category: CategoryConfiguration;
}

function findCategoryByFolder(configuration: WikiConfiguration, folder: string): CategoryLookup | null {
  for (const domain of configuration.domains) {
    for (const category of domain.categories) {
      if (category.folder === folder) {
        return { domain, category };
      }
    }
  }
  return null;
}

/**
 * Derives a page's place in the wiki from its path alone.
 * Throws with a descriptive message when the path does not fit the
 * configured structure — callers surface that as a validation error.
 */
export function deriveLocation(configuration: WikiConfiguration, relativePath: string): DerivedLocation {
  const pathSegments = relativePath.split("/");
  const fileName = pathSegments[pathSegments.length - 1];
  const depth = pathSegments.length - 1;

  if (relativePath === "index.html") {
    return { domain: "root", category: "root", section: null, role: "home", problemNumber: null, depth };
  }

  const categoryLookup = findCategoryByFolder(configuration, pathSegments[0]);
  if (categoryLookup === null) {
    throw new Error(`folder "${pathSegments[0]}" is not a configured category folder (${relativePath})`);
  }
  const { domain, category } = categoryLookup;

  if (category.layout === "sections") {
    if (pathSegments.length !== 3) {
      throw new Error(
        `pages in "${category.folder}/" must live inside a section folder (${relativePath})`,
      );
    }
    const sectionFolder = pathSegments[1];
    const section = (category.sections ?? []).find((candidate) => candidate.identifier === sectionFolder);
    if (section === undefined) {
      throw new Error(
        `folder "${category.folder}/${sectionFolder}" is not a configured section of "${category.identifier}"`,
      );
    }
    const role = fileName === "index.html" ? "hub" : OVERVIEW_FILENAME_PATTERN.test(fileName) ? "overview" : "deep-dive";
    return { domain: domain.identifier, category: category.identifier, section: section.identifier, role, problemNumber: null, depth };
  }

  // Flat category.
  if (pathSegments.length !== 2) {
    throw new Error(`pages in "${category.folder}/" must sit directly inside it (${relativePath})`);
  }
  if (fileName === "index.html") {
    return { domain: domain.identifier, category: category.identifier, section: null, role: "hub", problemNumber: null, depth };
  }
  if (category.filenamePattern !== undefined && !new RegExp(category.filenamePattern).test(fileName)) {
    throw new Error(
      `filename "${fileName}" does not match the "${category.identifier}" pattern ${category.filenamePattern}`,
    );
  }
  const problemNumberMatch = fileName.match(PROBLEM_NUMBER_PATTERN);
  const problemNumber = problemNumberMatch === null ? null : Number(problemNumberMatch[1]);
  return { domain: domain.identifier, category: category.identifier, section: null, role: "page", problemNumber, depth };
}

/** "../" repeated as many times as the page is below the wiki root. */
export function rootPrefixForDepth(depth: number): string {
  return depth === 0 ? "" : "../".repeat(depth);
}
