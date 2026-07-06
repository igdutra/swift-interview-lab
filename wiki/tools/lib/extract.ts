// ============================================================
// extract.ts — pull structured facts out of one wiki HTML file.
//
// The wiki's pages are authored against a strict standard, so
// anchored regular expressions are reliable here — no HTML
// parser dependency needed. Every pattern below matches markup
// shapes that the standard mandates.
// ============================================================

import { readFileSync } from "node:fs";
import { join } from "node:path";
import type { ScannedPage } from "./types.ts";

const META_BLOCK_PATTERN = /<script\s+type="application\/json"\s+data-page-meta\s*>([\s\S]*?)<\/script>/g;
const BODY_CATEGORY_PATTERN = /<body[^>]*\bdata-category="([^"]*)"/;
const TITLE_PATTERN = /<title>([\s\S]*?)<\/title>/;
const ELEMENT_ID_PATTERN = /\bid="([^"]+)"/g;
const SECTION_OPEN_PATTERN = /<section\b[^>]*>/g;
const HEADING_ANCHOR_PATTERN = /<h2\b[^>]*\bid="([^"]+)"/g;
const HREF_PATTERN = /\bhref="([^"]*)"/g;
const IMAGE_SOURCE_PATTERN = /\bsrc="([^"]*)"/g;
const CLASS_ATTRIBUTE_PATTERN = /\bclass="([^"]*)"/g;
const CROSS_REFERENCE_CARD_PATTERN = /<a\b[^>]*\bclass="[^"]*\b(?:xref-card|backref-card)\b[^"]*"[^>]*>/g;
const ATTRIBUTE_VALUE_PATTERN = (attributeName: string) => new RegExp(`\\b${attributeName}="([^"]*)"`);

function isExternalTarget(target: string): boolean {
  return (
    target.startsWith("http://") ||
    target.startsWith("https://") ||
    target.startsWith("mailto:") ||
    target.startsWith("data:")
  );
}

function allMatches(pattern: RegExp, text: string): RegExpExecArray[] {
  const matches: RegExpExecArray[] = [];
  pattern.lastIndex = 0;
  let currentMatch = pattern.exec(text);
  while (currentMatch !== null) {
    matches.push(currentMatch);
    currentMatch = pattern.exec(text);
  }
  return matches;
}

export function extractPage(wikiRoot: string, relativePath: string): ScannedPage {
  const absolutePath = join(wikiRoot, relativePath);
  const html = readFileSync(absolutePath, "utf8");

  const metaBlocks = allMatches(META_BLOCK_PATTERN, html).map((match) => match[1]);
  const bodyCategory = html.match(BODY_CATEGORY_PATTERN)?.[1] ?? null;
  const htmlTitle = html.match(TITLE_PATTERN)?.[1]?.trim() ?? null;
  const elementIds = allMatches(ELEMENT_ID_PATTERN, html).map((match) => match[1]);
  const headingAnchorIds = allMatches(HEADING_ANCHOR_PATTERN, html).map((match) => match[1]);

  // Sections: id, presence of an <h2> inside, presence of data-toc-label.
  const sectionIds: string[] = [];
  const sectionsWithoutTocLabel: string[] = [];
  for (const openTagMatch of allMatches(SECTION_OPEN_PATTERN, html)) {
    const openTag = openTagMatch[0];
    const sectionId = openTag.match(ATTRIBUTE_VALUE_PATTERN("id"))?.[1];
    if (sectionId === undefined) {
      continue;
    }
    sectionIds.push(sectionId);
    const hasTocLabel = openTag.includes("data-toc-label=");
    const sectionEnd = html.indexOf("</section>", openTagMatch.index);
    const sectionBody = sectionEnd === -1 ? "" : html.slice(openTagMatch.index, sectionEnd);
    const hasHeading = /<h2\b/.test(sectionBody);
    if (!hasTocLabel && !hasHeading) {
      sectionsWithoutTocLabel.push(sectionId);
    }
  }

  const fragmentHrefs: string[] = [];
  const relativeHrefs: string[] = [];
  for (const hrefMatch of allMatches(HREF_PATTERN, html)) {
    const target = hrefMatch[1];
    if (target === "" || isExternalTarget(target) || target.startsWith("javascript:")) {
      continue;
    }
    if (target.startsWith("#")) {
      fragmentHrefs.push(target);
    } else {
      relativeHrefs.push(target);
    }
  }

  const imageSources = allMatches(IMAGE_SOURCE_PATTERN, html)
    .map((match) => match[1])
    .filter((target) => !isExternalTarget(target) && (target.endsWith(".png") || target.endsWith(".svg") || target.endsWith(".jpg") || target.endsWith(".gif")));

  const classTokens: string[] = [];
  for (const classMatch of allMatches(CLASS_ATTRIBUTE_PATTERN, html)) {
    for (const token of classMatch[1].split(/\s+/)) {
      if (token !== "") {
        classTokens.push(token);
      }
    }
  }

  const crossReferenceHrefs = allMatches(CROSS_REFERENCE_CARD_PATTERN, html)
    .map((match) => match[0].match(ATTRIBUTE_VALUE_PATTERN("href"))?.[1])
    .filter((target): target is string => target !== undefined && !isExternalTarget(target));

  return {
    path: relativePath,
    absolutePath,
    html,
    metaBlocks,
    bodyCategory,
    htmlTitle,
    elementIds,
    sectionIds,
    headingAnchorIds,
    sectionsWithoutTocLabel,
    fragmentHrefs,
    relativeHrefs,
    imageSources,
    classTokens,
    crossReferenceHrefs,
  };
}
