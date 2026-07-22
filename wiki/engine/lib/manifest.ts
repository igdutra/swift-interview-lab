// ============================================================
// manifest.ts — assemble the site manifest from scanned pages.
// Used by build.ts (to write static/generated/manifest.js) and
// check.ts (to validate and verify the committed manifest is fresh).
// ============================================================

import type {
  CategoryConfiguration,
  Difficulty,
  ManifestCategory,
  ManifestTocStyle,
  ManifestDomain,
  ManifestSection,
  PageMeta,
  PageRecord,
  ScannedPage,
  WikiConfiguration,
  WikiManifest,
} from "./types.ts";
import { deriveLocation, listCategories } from "./derive.ts";

const ALLOWED_META_KEYS = new Set(["title", "nav", "topics", "blurb", "difficulty", "order"]);
const DIFFICULTY_VALUES = new Set(["E", "M", "H"]);

export interface PageAssembly {
  record: PageRecord | null;
  errors: string[];
}

/** Parse and validate one page's declared metadata block. */
export function parsePageMeta(scannedPage: ScannedPage): { pageMeta: PageMeta | null; errors: string[] } {
  const errors: string[] = [];
  if (scannedPage.metaBlocks.length === 0) {
    return { pageMeta: null, errors: [`missing <script type="application/json" data-page-meta> block`] };
  }
  if (scannedPage.metaBlocks.length > 1) {
    errors.push(`has ${scannedPage.metaBlocks.length} data-page-meta blocks — exactly one is allowed`);
  }

  let parsedValue: unknown;
  try {
    parsedValue = JSON.parse(scannedPage.metaBlocks[0]);
  } catch (parseError) {
    return { pageMeta: null, errors: [...errors, `data-page-meta is not valid JSON: ${String(parseError)}`] };
  }
  if (typeof parsedValue !== "object" || parsedValue === null || Array.isArray(parsedValue)) {
    return { pageMeta: null, errors: [...errors, "data-page-meta must be a JSON object"] };
  }
  const metaObject = parsedValue as Record<string, unknown>;

  for (const key of Object.keys(metaObject)) {
    if (!ALLOWED_META_KEYS.has(key)) {
      errors.push(`data-page-meta has unknown key "${key}"`);
    }
  }
  for (const requiredKey of ["title", "nav", "blurb"]) {
    const value = metaObject[requiredKey];
    if (typeof value !== "string" || value.trim() === "") {
      errors.push(`data-page-meta "${requiredKey}" must be a non-empty string`);
    }
  }
  const topics = metaObject["topics"];
  if (!Array.isArray(topics) || topics.some((topic) => typeof topic !== "string" || topic.trim() === "")) {
    errors.push(`data-page-meta "topics" must be an array of non-empty strings`);
  }
  const difficulty = metaObject["difficulty"];
  if (difficulty !== undefined && (typeof difficulty !== "string" || !DIFFICULTY_VALUES.has(difficulty))) {
    errors.push(`data-page-meta "difficulty" must be "E", "M", or "H"`);
  }
  const order = metaObject["order"];
  if (order !== undefined && (typeof order !== "number" || !Number.isInteger(order))) {
    errors.push(`data-page-meta "order" must be an integer`);
  }

  if (errors.length > 0) {
    return { pageMeta: null, errors };
  }
  return {
    pageMeta: {
      title: metaObject["title"] as string,
      nav: metaObject["nav"] as string,
      topics: topics as string[],
      blurb: metaObject["blurb"] as string,
      difficulty: difficulty as Difficulty | undefined,
      order: order as number | undefined,
    },
    errors: [],
  };
}

/** Combine derived location + declared metadata into one manifest record. */
export function assemblePageRecord(configuration: WikiConfiguration, scannedPage: ScannedPage): PageAssembly {
  const errors: string[] = [];

  let location;
  try {
    location = deriveLocation(configuration, scannedPage.path);
  } catch (derivationError) {
    return { record: null, errors: [(derivationError as Error).message] };
  }

  const { pageMeta, errors: metaErrors } = parsePageMeta(scannedPage);
  errors.push(...metaErrors);
  if (pageMeta === null) {
    return { record: null, errors };
  }

  const category = listCategories(configuration).find(
    ({ category: candidate }) => candidate.identifier === location.category,
  )?.category;
  const isRegularPage = location.role === "page" || location.role === "overview" || location.role === "deep-dive";
  if (category !== undefined && isRegularPage) {
    if (category.requiresDifficulty && pageMeta.difficulty === undefined) {
      errors.push(`pages in "${category.identifier}" must declare a difficulty`);
    }
    if (!category.requiresDifficulty && pageMeta.difficulty !== undefined) {
      errors.push(`pages in "${category.identifier}" must not declare a difficulty`);
    }
  }
  if (!isRegularPage && pageMeta.difficulty !== undefined) {
    errors.push(`hub pages must not declare a difficulty`);
  }

  if (errors.length > 0) {
    return { record: null, errors };
  }
  return {
    record: {
      path: scannedPage.path,
      domain: location.domain,
      category: location.category,
      section: location.section,
      role: location.role,
      title: pageMeta.title,
      nav: pageMeta.nav,
      topics: pageMeta.topics,
      blurb: pageMeta.blurb,
      difficulty: pageMeta.difficulty ?? null,
      problemNumber: location.problemNumber,
      order: pageMeta.order ?? null,
    },
    errors: [],
  };
}

const ROLE_SORT_RANK: Record<string, number> = { overview: 0, "deep-dive": 1, page: 1 };
const UNORDERED = Number.MAX_SAFE_INTEGER;

function compareSectionPages(first: PageRecord, second: PageRecord): number {
  const roleDifference = (ROLE_SORT_RANK[first.role] ?? 2) - (ROLE_SORT_RANK[second.role] ?? 2);
  if (roleDifference !== 0) {
    return roleDifference;
  }
  const orderDifference = (first.order ?? UNORDERED) - (second.order ?? UNORDERED);
  if (orderDifference !== 0) {
    return orderDifference;
  }
  return first.path.localeCompare(second.path);
}

function compareByProblemNumber(first: PageRecord, second: PageRecord): number {
  const firstNumber = first.problemNumber ?? UNORDERED;
  const secondNumber = second.problemNumber ?? UNORDERED;
  if (firstNumber !== secondNumber) {
    return firstNumber - secondNumber;
  }
  return first.path.localeCompare(second.path);
}

function compareByDeclaredOrder(first: PageRecord, second: PageRecord): number {
  const orderDifference = (first.order ?? UNORDERED) - (second.order ?? UNORDERED);
  if (orderDifference !== 0) {
    return orderDifference;
  }
  return first.path.localeCompare(second.path);
}

/** Build the full manifest from already-assembled page records. */
export function buildManifest(configuration: WikiConfiguration, records: PageRecord[]): WikiManifest {
  // Sub-categories are flattened into their domain's list: the manifest is
  // a NAVIGATION view, and a parent category that only holds children has
  // no pages of its own to show. Its label is prefixed onto each child so
  // "SwiftUI > Theory" stays readable in the nav.
  function flattenCategories(
    categories: CategoryConfiguration[],
    labelPrefix: string,
  ): { configuration: CategoryConfiguration; label: string }[] {
    const flattened: { configuration: CategoryConfiguration; label: string }[] = [];
    for (const categoryConfiguration of categories) {
      const label = labelPrefix === "" ? categoryConfiguration.label : `${labelPrefix} · ${categoryConfiguration.label}`;
      const children = categoryConfiguration.children ?? [];
      if (children.length > 0) {
        flattened.push(...flattenCategories(children, label));
      } else {
        flattened.push({ configuration: categoryConfiguration, label });
      }
    }
    return flattened;
  }

  const domains: ManifestDomain[] = configuration.domains.map((domainConfiguration) => ({
    identifier: domainConfiguration.identifier,
    label: domainConfiguration.label,
    categories: flattenCategories(domainConfiguration.categories, "").map(({ configuration: categoryConfiguration, label: categoryLabel }): ManifestCategory => {
      const categoryRecords = records.filter((record) => record.category === categoryConfiguration.identifier);

      if (categoryConfiguration.layout === "sections") {
        const sections: ManifestSection[] = (categoryConfiguration.sections ?? []).map((sectionConfiguration) => {
          const sectionRecords = categoryRecords.filter((record) => record.section === sectionConfiguration.identifier);
          const hubRecord = sectionRecords.find((record) => record.role === "hub");
          return {
            identifier: sectionConfiguration.identifier,
            label: sectionConfiguration.label,
            hubPath: hubRecord?.path ?? null,
            pagePaths: sectionRecords
              .filter((record) => record.role !== "hub")
              .sort(compareSectionPages)
              .map((record) => record.path),
          };
        });
        // A category-level index.html (section === null) is the category's
        // own landing page; the nav uses it as the dropdown's click target.
        const categoryHubRecord = categoryRecords.find(
          (record) => record.role === "hub" && record.section === null,
        );
        return {
          identifier: categoryConfiguration.identifier,
          label: categoryLabel,
          layout: "sections",
          hubPath: categoryHubRecord?.path ?? null,
          sections,
          pagePaths: [],
        };
      }

      const hubRecord = categoryRecords.find((record) => record.role === "hub");
      const comparator =
        categoryConfiguration.flatSort === "problemNumber" ? compareByProblemNumber : compareByDeclaredOrder;
      return {
        identifier: categoryConfiguration.identifier,
        label: categoryLabel,
        layout: "flat",
        hubPath: hubRecord?.path ?? null,
        sections: [],
        pagePaths: categoryRecords
          .filter((record) => record.role !== "hub")
          .sort(comparator)
          .map((record) => record.path),
      };
    }),
  }));

  const pages: Record<string, PageRecord> = {};
  for (const record of [...records].sort((first, second) => first.path.localeCompare(second.path))) {
    pages[record.path] = record;
  }

  // Map each body category to its page type's TOC presentation. Built here
  // so browser/toc.ts can look it up instead of hardcoding content names.
  const tocStyles: Record<string, ManifestTocStyle> = {};
  for (const { category } of listCategories(configuration)) {
    const pageType = configuration.pageTypes.find(
      (candidate) => candidate.identifier === category.pageType,
    );
    if (pageType === undefined) {
      continue;
    }
    tocStyles[category.pageBodyCategory] = {
      title: pageType.tocTitle ?? "Contents",
      accent: pageType.tocAccent ?? null,
    };
  }

  return { siteTitle: configuration.siteTitle, domains, pages, tocStyles };
}

/** Render the committed static/generated/manifest.js file contents. */
export function renderManifestFile(manifest: WikiManifest): string {
  return (
    "// GENERATED FILE — DO NOT EDIT.\n" +
    "// Source of truth: the data-page-meta block inside each wiki page.\n" +
    "// Regenerate with: node wiki/engine/commands/build.ts\n" +
    `const WIKI_MANIFEST = ${JSON.stringify(manifest, null, 2)};\n`
  );
}
