// ============================================================
// links.ts — authored links carry IDENTITY, not paths.
//
// A link is written as the target's filename:
//
//     <a href="sliding_window_master.html">
//
// and this module resolves it, at build time, to the correct
// relative path from whichever page contains it. Folder names
// therefore never appear in authored content, and renaming a
// folder is a config edit plus a rebuild — nothing to find,
// nothing to replace.
//
// When a bare filename is ambiguous (two pages share it), the
// author qualifies it with the SHORTEST distinguishing suffix:
//
//     <a href="codingInterview/state_management.html">
//
// Resolution is therefore suffix matching over real page paths,
// the same rule Obsidian/MediaWiki-style wikis use. Exactly one
// match resolves; zero or many is a build error.
// ============================================================

/** Split "file.html#anchor?q" into its path and trailing parts. */
interface SplitHref {
  target: string;
  suffix: string;
}

export function splitHref(href: string): SplitHref {
  const boundary = href.search(/[#?]/);
  if (boundary === -1) {
    return { target: href, suffix: "" };
  }
  return { target: href.slice(0, boundary), suffix: href.slice(boundary) };
}

/** Links the resolver must leave untouched. */
export function isExternalHref(href: string): boolean {
  return (
    href === "" ||
    href.startsWith("#") ||
    href.startsWith("http://") ||
    href.startsWith("https://") ||
    href.startsWith("//") ||
    href.startsWith("mailto:") ||
    href.startsWith("tel:") ||
    href.startsWith("data:")
  );
}

export interface ResolutionSuccess {
  kind: "resolved";
  /** Content-relative path of the target page. */
  targetPath: string;
}

export interface ResolutionFailure {
  kind: "missing" | "ambiguous";
  message: string;
}

export type Resolution = ResolutionSuccess | ResolutionFailure;

/**
 * Resolves an authored href against every known page path.
 * `target` is matched as a trailing path suffix, on segment
 * boundaries, so "state_management.html" matches
 * "ios/swiftui/theory/state_management.html" but "management.html"
 * does not.
 */
export function resolveTarget(target: string, allPagePaths: string[]): Resolution {
  // Strip any leading "./" or "../" so that ALREADY-RESOLVED output
  // resolves again to the same page. This is what makes the build
  // idempotent: re-running it must be a no-op, not a second rewrite.
  const normalized = target.replace(/^(\.\.?\/)+/, "");
  let matches = allPagePaths.filter(
    (pagePath) => pagePath === normalized || pagePath.endsWith(`/${normalized}`),
  );

  // Fall back to the FILENAME alone. Previously-resolved links carry
  // directory names that a folder rename invalidates; the filename is the
  // real identity, so this is what lets a rename be a config edit plus a
  // rebuild rather than a hunt through every page.
  if (matches.length === 0) {
    const fileName = normalized.slice(normalized.lastIndexOf("/") + 1);
    matches = allPagePaths.filter(
      (pagePath) => pagePath === fileName || pagePath.endsWith(`/${fileName}`),
    );
  }

  if (matches.length === 1) {
    return { kind: "resolved", targetPath: matches[0] };
  }
  if (matches.length === 0) {
    return { kind: "missing", message: `no page matches "${target}"` };
  }
  return {
    kind: "ambiguous",
    message:
      `"${target}" matches ${matches.length} pages — qualify it with more of the path: ` +
      matches.map((pagePath) => `"${shortestUniqueSuffix(pagePath, allPagePaths)}"`).join(", "),
  };
}

/**
 * The fewest trailing segments of `pagePath` that identify it uniquely.
 * This is what an author should write, and what the validator suggests.
 */
export function shortestUniqueSuffix(pagePath: string, allPagePaths: string[]): string {
  const segments = pagePath.split("/");
  for (let take = 1; take <= segments.length; take += 1) {
    const candidate = segments.slice(segments.length - take).join("/");
    const matches = allPagePaths.filter(
      (other) => other === candidate || other.endsWith(`/${candidate}`),
    );
    if (matches.length === 1) {
      return candidate;
    }
  }
  return pagePath;
}

/** Relative path to get from the page at `fromPath` to `toPath`. */
export function relativePathBetween(fromPath: string, toPath: string): string {
  const fromSegments = fromPath.split("/").slice(0, -1);
  const toSegments = toPath.split("/");
  let shared = 0;
  while (
    shared < fromSegments.length &&
    shared < toSegments.length - 1 &&
    fromSegments[shared] === toSegments[shared]
  ) {
    shared += 1;
  }
  const upwards = "../".repeat(fromSegments.length - shared);
  const downwards = toSegments.slice(shared).join("/");
  return `${upwards}${downwards}`;
}
