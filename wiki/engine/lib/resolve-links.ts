// ============================================================
// resolve-links.ts — turn authored identities into real paths.
//
// Authors write a link as the target's filename; this rewrites it
// to the correct relative path for the page it appears in, and
// rewrites asset links (wiki.css, generated scripts, images) to
// the right "../" depth. Both are GENERATED values: the identity
// in the source is the truth, the emitted path is derived output,
// exactly like manifest.js.
//
// Everything here is idempotent — re-running on already-resolved
// HTML produces identical output, because a resolved href still
// suffix-matches the same single page.
// ============================================================

import { isExternalHref, relativePathBetween, resolveTarget, splitHref } from "./links.ts";
import { rootPrefixForDepth } from "./derive.ts";
import { CSS_HREF, MANIFEST_SRC, NAV_SRC, TOC_SRC } from "./paths.ts";

const HREF_ATTRIBUTE_PATTERN = /\bhref="([^"]*)"/g;
const SOURCE_ATTRIBUTE_PATTERN = /\bsrc="([^"]*)"/g;

/** Asset suffixes that are depth-relative to the wiki root. */
const ROOT_RELATIVE_ASSETS = [CSS_HREF, MANIFEST_SRC, NAV_SRC, TOC_SRC];

export interface LinkProblem {
  href: string;
  message: string;
}

export interface RewriteResult {
  html: string;
  problems: LinkProblem[];
}

/** True when the target is an asset rather than a wiki page. */
function isAssetTarget(target: string): boolean {
  return !target.endsWith(".html");
}

/**
 * Rewrites every authored link in `html` for a page living at `pagePath`.
 * Page links resolve by identity; asset links resolve by depth.
 */
export function rewritePageLinks(
  html: string,
  pagePath: string,
  allPagePaths: string[],
): RewriteResult {
  const problems: LinkProblem[] = [];
  const depth = pagePath.split("/").length - 1;
  const rootPrefix = rootPrefixForDepth(depth);

  function rewriteAttribute(fullMatch: string, rawHref: string, attributeName: string): string {
    if (isExternalHref(rawHref)) {
      return fullMatch;
    }
    const { target, suffix } = splitHref(rawHref);
    if (target === "") {
      return fullMatch;
    }

    if (isAssetTarget(target)) {
      // Root-relative assets: re-prefix to this page's depth.
      const bareTarget = target.replace(/^(\.\.\/)+/, "").replace(/^\.\//, "");
      for (const assetSuffix of ROOT_RELATIVE_ASSETS) {
        if (bareTarget === assetSuffix) {
          return `${attributeName}="${rootPrefix}${assetSuffix}${suffix}"`;
        }
      }
      // Any other asset (images beside the page) is left as authored.
      return fullMatch;
    }

    // "index.html" is positional, not an identity: it always means the
    // hub sitting beside this page. Every folder has one, so it is
    // deliberately exempt from identity resolution.
    if (target === "index.html") {
      return fullMatch;
    }

    const resolution = resolveTarget(target, allPagePaths);
    if (resolution.kind !== "resolved") {
      problems.push({ href: rawHref, message: resolution.message });
      return fullMatch;
    }
    const relativePath = relativePathBetween(pagePath, resolution.targetPath);
    return `${attributeName}="${relativePath}${suffix}"`;
  }

  const withHrefs = html.replace(HREF_ATTRIBUTE_PATTERN, (fullMatch, rawHref: string) =>
    rewriteAttribute(fullMatch, rawHref, "href"),
  );
  const withSources = withHrefs.replace(SOURCE_ATTRIBUTE_PATTERN, (fullMatch, rawHref: string) =>
    rewriteAttribute(fullMatch, rawHref, "src"),
  );

  return { html: withSources, problems };
}
