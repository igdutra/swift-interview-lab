// ============================================================
// templates.ts — page skeletons used by new-page.ts.
// The section lists mirror the wiki skill's page-format
// references (theory 14 sections, walkthrough 15 sections).
// ============================================================

import type { PageMeta } from "./types.ts";

const FONTS_LINK =
  '<link href="https://fonts.googleapis.com/css2?family=Linux+Libertine+O&family=Source+Code+Pro:ital,wght@0,400;0,600;1,400&family=Source+Sans+3:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">';

export interface SectionSkeleton {
  id: string;
  tocLabel: string;
  heading: string | null; // null → the section carries only data-toc-label (the lead)
}

export const THEORY_SECTIONS: SectionSkeleton[] = [
  { id: "lead", tocLabel: "Definition", heading: null },
  { id: "signals", tocLabel: "Recognition Signals", heading: "Recognition Signals — when to reach for it" },
  { id: "terminology", tocLabel: "Terminology Decoder", heading: "Terminology Decoder" },
  { id: "mental-model", tocLabel: "Mental Model", heading: "Mental Model" },
  { id: "pseudocode", tocLabel: "Pseudocode Primer", heading: "Pseudocode Primer" },
  { id: "iterative", tocLabel: "Iterative-Only Pattern", heading: "Iterative-Only Solution Pattern" },
  { id: "swift", tocLabel: "Swift Translation", heading: "Swift Translation" },
  { id: "variants", tocLabel: "Variant Catalog", heading: "Variant Catalog" },
  { id: "complexity", tocLabel: "Complexity Analysis", heading: "Complexity Analysis" },
  { id: "pitfalls", tocLabel: "Common Pitfalls", heading: "Common Pitfalls" },
  { id: "edge-cases", tocLabel: "Edge Cases", heading: "Edge Cases to Verbalize" },
  { id: "cheatsheet", tocLabel: "Cheat Sheet", heading: "Cheat Sheet" },
  { id: "practice", tocLabel: "Demonstrated in Practice", heading: "Demonstrated in Practice" },
  { id: "solo", tocLabel: "Solo Problem", heading: "Solo Practice Problem" },
];

export const WALKTHROUGH_SECTIONS: SectionSkeleton[] = [
  { id: "lead", tocLabel: "The Problem", heading: null },
  { id: "reading", tocLabel: "Reading the Problem", heading: "Reading the Problem — insights from the statement" },
  { id: "edge-cases", tocLabel: "Edge Case Inventory", heading: "Edge Case Inventory" },
  { id: "hints", tocLabel: "Try It Yourself First", heading: "Try It Yourself First" },
  { id: "simulation", tocLabel: "Interview Simulation", heading: "Interview Simulation" },
  { id: "approach", tocLabel: "Why This Approach", heading: "Why This Approach" },
  { id: "structures", tocLabel: "Data Structures", heading: "Data Structure Choice" },
  { id: "dryrun", tocLabel: "Pseudocode Dry Run", heading: "Pseudocode Dry Run" },
  { id: "swift", tocLabel: "Swift Solution", heading: "Swift Solution — iterative" },
  { id: "code-dry-run", tocLabel: "Code Dry Run", heading: "Code Dry Run — the Swift solution, traced" },
  { id: "qmap", tocLabel: "Question → Code Map", heading: "Question → Code Map" },
  { id: "complexity", tocLabel: "Complexity", heading: "Complexity" },
  { id: "followups", tocLabel: "Follow-Up Bank", heading: "Follow-Up Question Bank" },
  { id: "decoder", tocLabel: "Theory Decoder", heading: "Theory Decoder" },
  { id: "parent", tocLabel: "Parent Theory", heading: "Parent Theory" },
];

function escapeHtml(text: string): string {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
}

export function renderMetaBlock(pageMeta: PageMeta): string {
  const declaredMeta: Record<string, unknown> = {
    title: pageMeta.title,
    nav: pageMeta.nav,
    topics: pageMeta.topics,
    blurb: pageMeta.blurb,
  };
  if (pageMeta.difficulty !== undefined) {
    declaredMeta["difficulty"] = pageMeta.difficulty;
  }
  if (pageMeta.order !== undefined) {
    declaredMeta["order"] = pageMeta.order;
  }
  return `<script type="application/json" data-page-meta>\n${JSON.stringify(declaredMeta, null, 2)}\n</script>`;
}

export interface PageShellOptions {
  rootPrefix: string; // "", "../", or "../../"
  htmlTitle: string;
  pageMeta: PageMeta;
  bodyCategory: string;
  bodyContent: string;
}

export function renderPageShell(options: PageShellOptions): string {
  const { rootPrefix, htmlTitle, pageMeta, bodyCategory, bodyContent } = options;
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${escapeHtml(htmlTitle)}</title>
${renderMetaBlock(pageMeta)}
<link rel="stylesheet" href="${rootPrefix}_shared/wiki.css">
${FONTS_LINK}
</head>
<body data-category="${bodyCategory}">

<nav id="topnav" class="topnav"></nav>

<div class="page">
${bodyContent}
</div>

<script src="${rootPrefix}_shared/manifest.js"></script>
<script src="${rootPrefix}_shared/nav.js"></script>
<script src="${rootPrefix}_shared/toc.js"></script>
</body>
</html>
`;
}

export function renderArticleBody(pageTitle: string, metaLine: string, sections: SectionSkeleton[]): string {
  const sectionMarkup = sections
    .map((section, sectionIndex) => {
      const sectionNumber = sectionIndex + 1;
      const openTag = `<section id="${section.id}" data-toc-label="${escapeHtml(section.tocLabel)}">`;
      if (section.heading === null) {
        return `  ${openTag}
    <div class="lead">
      <p>TODO — opening definition / problem restatement.</p>
    </div>
  </section>`;
      }
      return `  ${openTag}
    <h2>${sectionNumber} &nbsp; ${escapeHtml(section.heading)}</h2>
    <p>TODO</p>
  </section>`;
    })
    .join("\n\n  <hr class=\"wiki-hr\">\n\n");

  return `
<main class="content">

  <h1 class="page-title">${escapeHtml(pageTitle)}</h1>
  <div class="page-meta">
    ${metaLine}
  </div>

${sectionMarkup}

  <div class="page-footer">
    ${escapeHtml(pageTitle)}
  </div>

</main>`;
}

/**
 * Reference pages are flat h2-driven documents: no <section> wrappers,
 * the TOC is generated from bare <h2 id data-toc-label> headings.
 */
export function renderReferenceBody(pageTitle: string, metaLine: string): string {
  const placeholderHeadings = ["TODO First Topic", "TODO Second Topic"]
    .map(
      (headingLabel, headingIndex) =>
        `  <h2 id="todo-${headingIndex + 1}" data-toc-label="${escapeHtml(headingLabel)}"><span class="sec-num">${headingIndex + 1}</span> ${escapeHtml(headingLabel)}</h2>
  <p>TODO</p>`,
    )
    .join("\n\n  <hr class=\"wiki-hr\">\n\n");

  return `
<main class="content">

  <h1 class="page-title">${escapeHtml(pageTitle)}</h1>
  <div class="page-meta">
    ${metaLine}
  </div>

  <div class="lead">
    <p>TODO — one paragraph describing this reference page.</p>
  </div>

${placeholderHeadings}

  <div class="page-footer">
    Study Wiki · ${escapeHtml(pageTitle)}
  </div>

</main>`;
}

export function renderHubBody(pageTitle: string, metaLine: string): string {
  return `
<main class="content content-centered">

  <h1 class="page-title">${escapeHtml(pageTitle)}</h1>
  <div class="page-meta">
    ${metaLine}
  </div>

  <div class="lead">
    <p>TODO — one paragraph describing this hub.</p>
  </div>

  <!-- Card grid generated by nav.js from the manifest -->
  <div data-hub-grid></div>

  <div class="page-footer">
    Study Wiki · ${escapeHtml(pageTitle)}
  </div>

</main>`;
}
