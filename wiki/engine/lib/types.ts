// ============================================================
// types.ts — shared type definitions for the wiki toolchain.
// Erasable-syntax-only TypeScript (no enums, no namespaces) so
// every tool runs directly under Node's type stripping.
// ============================================================

export type CategoryLayout = "sections" | "flat";
export type FlatSortOrder = "problemNumber" | "declaredOrder";
export type Difficulty = "E" | "M" | "H";

/** How a page type lays out its body. */
export type PageTypeLayout =
  | "sections" // <section id data-toc-label> skeleton (theory, walkthrough)
  | "flat"; // bare <h2 id> document (reference)

/** How a page participates in navigation and hub grids. */
export type PageRole =
  | "home" // the site root index.html
  | "hub" // a category or section index.html
  | "overview" // a *_overview_master.html inside a section
  | "deep-dive" // any other page inside a section
  | "page"; // a regular page in a flat category

// ---------- wiki.config.ts shapes ----------

/** One <section> in a page-type skeleton (scaffolded by new-page.ts). */
export interface SectionSkeleton {
  /** Section id, also the fragment anchor, e.g. "complexity". */
  id: string;
  /** Label shown in the generated table of contents. */
  tocLabel: string;
  /** Heading text, or null for the lead section (data-toc-label only). */
  heading: string | null;
}

/**
 * A reusable page shape. Adding a whole new kind of page (e.g. an
 * electrical-engineering topic) means adding one entry here with its
 * section skeleton — no engine code changes.
 */
export interface PageTypeConfiguration {
  /** Referenced by a category's `pageType`, e.g. "theory". */
  identifier: string;
  layout: PageTypeLayout;
  /** Required when layout is "sections": the ordered section skeleton. */
  sections?: SectionSkeleton[];
  /** Short label used in the page's meta line, e.g. "Theory Masterfile". */
  metaLabel: string;
}

export interface SectionConfiguration {
  /** Folder name under the category folder, e.g. "arrays". */
  identifier: string;
  /** Display label for nav groups and hub cards, e.g. "Arrays & Hashing". */
  label: string;
}

export interface CategoryConfiguration {
  identifier: string;
  label: string;
  /**
   * This category's OWN folder segment, e.g. "theory" — not a path.
   * The full path is built by walking the config tree, so a folder name
   * appears exactly once and renaming it is a one-word edit.
   */
  folder: string;
  layout: CategoryLayout;
  /** Identifier of the page type its regular pages are scaffolded from. */
  pageType: string;
  /** Expected <body data-category> on regular (non-hub) pages. */
  pageBodyCategory: string;
  /** Whether every regular page must declare a difficulty. */
  requiresDifficulty: boolean;
  /** Ordered sections — required when layout is "sections". */
  sections?: SectionConfiguration[];
  /** Ordering rule for pages — required when layout is "flat". */
  flatSort?: FlatSortOrder;
  /** Filename rule for regular pages (regular expression source). */
  filenamePattern?: string;
  /**
   * Nested sub-categories, e.g. swiftui > { theory, codingInterview }.
   * A category either holds pages (layout/sections) or children, not both.
   */
  children?: CategoryConfiguration[];
}

export interface DomainConfiguration {
  identifier: string;
  label: string;
  /** This domain's own folder segment, e.g. "leetcode". */
  folder: string;
  categories: CategoryConfiguration[];
}

export interface WikiConfiguration {
  siteTitle: string;
  serverPort: number;
  /** The page shapes categories can be built from. */
  pageTypes: PageTypeConfiguration[];
  domains: DomainConfiguration[];
}

// ---------- per-page declared metadata (data-page-meta block) ----------

export interface PageMeta {
  /** Full title used on hub cards. */
  title: string;
  /** Short label for the top nav. */
  nav: string;
  /** Topic chips shown on hub cards. */
  topics: string[];
  /** One-line hub-card description. */
  blurb: string;
  /** Required when the category demands it (walkthroughs); forbidden elsewhere. */
  difficulty?: Difficulty;
  /** Optional within-group ordering (theory deep-dives, reference pages). */
  order?: number;
}

// ---------- derived + generated shapes ----------

export interface DerivedLocation {
  domain: string;
  category: string;
  section: string | null;
  role: PageRole;
  problemNumber: number | null;
  /** Directory depth below the wiki root (root page = 0). */
  depth: number;
}

/** One entry in the generated manifest's `pages` map. */
export interface PageRecord {
  path: string;
  domain: string;
  category: string;
  section: string | null;
  role: PageRole;
  title: string;
  nav: string;
  topics: string[];
  blurb: string;
  difficulty: Difficulty | null;
  problemNumber: number | null;
  order: number | null;
}

export interface ManifestSection {
  identifier: string;
  label: string;
  hubPath: string | null;
  /** Ordered page paths, hub excluded. */
  pagePaths: string[];
}

export interface ManifestCategory {
  identifier: string;
  label: string;
  layout: CategoryLayout;
  hubPath: string | null;
  sections: ManifestSection[];
  /** Ordered page paths for flat categories, hub excluded. */
  pagePaths: string[];
}

export interface ManifestDomain {
  identifier: string;
  label: string;
  categories: ManifestCategory[];
}

export interface WikiManifest {
  siteTitle: string;
  domains: ManifestDomain[];
  pages: Record<string, PageRecord>;
}

// ---------- scan/extract output ----------

/** Raw facts pulled from one HTML file, before validation. */
export interface ScannedPage {
  /** Wiki-relative path with forward slashes, e.g. "theory/arrays/index.html". */
  path: string;
  absolutePath: string;
  html: string;
  /** Raw JSON text of each data-page-meta block found (normally exactly one). */
  metaBlocks: string[];
  bodyCategory: string | null;
  htmlTitle: string | null;
  /** Every id="…" attribute value, in document order. */
  elementIds: string[];
  /** Ids of top-level <section id="…"> wrappers. */
  sectionIds: string[];
  /** Ids on <h2 id="…"> headings (reference-page style anchors). */
  headingAnchorIds: string[];
  /** Section ids that have neither an <h2> inside nor a data-toc-label. */
  sectionsWithoutTocLabel: string[];
  /** Same-page fragment hrefs ("#complexity"). */
  fragmentHrefs: string[];
  /** Relative hrefs to other files, possibly with a fragment. */
  relativeHrefs: string[];
  /** Relative img/src references. */
  imageSources: string[];
  /** Every class attribute token used on the page. */
  classTokens: string[];
  /** Hrefs of <a class="xref-card"> and <a class="backref-card"> links. */
  crossReferenceHrefs: string[];
}
