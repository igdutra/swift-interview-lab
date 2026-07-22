// ============================================================
// derive.ts — everything a page's disk location already tells us.
// Path → domain / category / section / role / problem number.
//
// The config tree is walked, not pattern-matched: a page's folder
// path is `domain.folder / …category.folder / [section] / file.html`
// at ANY depth. Each folder name is written once, in wiki.config.ts,
// so renaming one is a single-word edit that the whole toolchain
// (and every generated link) follows automatically.
// ============================================================

import type {
  CategoryConfiguration,
  DerivedLocation,
  DomainConfiguration,
  WikiConfiguration,
} from "./types.ts";

const PROBLEM_NUMBER_PATTERN = /^LC(\d+)_/;
const OVERVIEW_FILENAME_PATTERN = /_overview_master\.html$/;

/** A category plus the domain and folder path that led to it. */
export interface ResolvedCategory {
  domain: DomainConfiguration;
  category: CategoryConfiguration;
  /** Folder segments from the content root down to the category. */
  folderSegments: string[];
}

/**
 * Every category in the config, each with the full folder path that
 * reaches it. Sub-categories are included, deepest last.
 */
export function listCategories(configuration: WikiConfiguration): ResolvedCategory[] {
  const resolved: ResolvedCategory[] = [];
  for (const domain of configuration.domains) {
    collectCategories(domain, domain.categories, [domain.folder], resolved);
  }
  return resolved;
}

function collectCategories(
  domain: DomainConfiguration,
  categories: CategoryConfiguration[],
  parentSegments: string[],
  resolved: ResolvedCategory[],
): void {
  for (const category of categories) {
    const folderSegments = [...parentSegments, category.folder];
    resolved.push({ domain, category, folderSegments });
    if (category.children !== undefined) {
      collectCategories(domain, category.children, folderSegments, resolved);
    }
  }
}

/** The category whose folder path is the longest prefix of these segments. */
function findCategoryForPath(
  configuration: WikiConfiguration,
  pathSegments: string[],
): ResolvedCategory | null {
  let bestMatch: ResolvedCategory | null = null;
  for (const candidate of listCategories(configuration)) {
    const { folderSegments } = candidate;
    if (folderSegments.length > pathSegments.length) {
      continue;
    }
    const isPrefix = folderSegments.every((segment, index) => segment === pathSegments[index]);
    if (!isPrefix) {
      continue;
    }
    // Longest match wins: a nested category beats its own parent.
    if (bestMatch === null || folderSegments.length > bestMatch.folderSegments.length) {
      bestMatch = candidate;
    }
  }
  return bestMatch;
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

  const match = findCategoryForPath(configuration, pathSegments);
  if (match === null) {
    throw new Error(`"${pathSegments[0]}" does not start any configured domain/category folder path (${relativePath})`);
  }
  const { domain, category, folderSegments } = match;

  // Segments between the category folder and the filename.
  const innerSegments = pathSegments.slice(folderSegments.length, pathSegments.length - 1);

  if (category.children !== undefined && category.children.length > 0) {
    throw new Error(
      `"${folderSegments.join("/")}" is a parent category — pages belong in one of its sub-folders (${relativePath})`,
    );
  }

  if (category.layout === "sections") {
    // A category-level index.html is the category's own landing page —
    // the top of its breadcrumb, above the individual section hubs.
    if (innerSegments.length === 0 && fileName === "index.html") {
      return { domain: domain.identifier, category: category.identifier, section: null, role: "hub", problemNumber: null, depth };
    }
    if (innerSegments.length !== 1) {
      throw new Error(`pages in "${folderSegments.join("/")}/" must live inside a section folder (${relativePath})`);
    }
    const sectionFolder = innerSegments[0];
    const section = (category.sections ?? []).find((candidate) => candidate.identifier === sectionFolder);
    if (section === undefined) {
      throw new Error(
        `folder "${folderSegments.join("/")}/${sectionFolder}" is not a configured section of "${category.identifier}"`,
      );
    }
    const role = fileName === "index.html" ? "hub" : OVERVIEW_FILENAME_PATTERN.test(fileName) ? "overview" : "deep-dive";
    return { domain: domain.identifier, category: category.identifier, section: section.identifier, role, problemNumber: null, depth };
  }

  // Flat category: the file sits directly inside the category folder.
  if (innerSegments.length !== 0) {
    throw new Error(`pages in "${folderSegments.join("/")}/" must sit directly inside it (${relativePath})`);
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
