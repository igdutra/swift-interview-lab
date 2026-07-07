// ============================================================
// paths.ts — the ONE place every filesystem path and browser URL
// prefix is defined. Rename a folder here and the whole toolchain
// (the Node commands AND the <head> wiring the validator enforces)
// follows in lockstep.
//
// This file lives at engine/lib/paths.ts, so the wiki root is two
// directories up. The commands in engine/commands/ import from here
// instead of re-deriving the root themselves.
//
// The one path this file cannot own is the wiki-root suffix baked
// into engine/browser/nav.ts: that script compiles to plain browser
// JS with no module system, so it mirrors NAV_SRC as a literal.
// Keep the two in sync.
// ============================================================

import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

// ---- absolute roots ----

/** The wiki/ directory — two up from engine/lib/. */
export const WIKI_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");

// ---- folder names (change here to rename) ----

/** Authored pages live here; served as the web root. */
export const CONTENT_DIR = "content";
/** Everything a page loads (css + generated scripts). */
export const STATIC_DIR = "static";
/** Build outputs, nested inside static/. */
export const GENERATED_DIR = "generated";

// ---- absolute directories the commands operate on ----

export const CONTENT_ROOT = join(WIKI_ROOT, CONTENT_DIR);
export const STATIC_ROOT = join(WIKI_ROOT, STATIC_DIR);
export const GENERATED_ROOT = join(STATIC_ROOT, GENERATED_DIR);

// ---- specific files on disk ----

export const MANIFEST_PATH = join(GENERATED_ROOT, "manifest.js");
export const WIKI_CSS_PATH = join(STATIC_ROOT, "wiki.css");

// ---- browser-facing URL suffixes (relative to a page) ----
// A page prepends its own "../" depth prefix to these.

export const CSS_HREF = `${STATIC_DIR}/wiki.css`;
export const MANIFEST_SRC = `${STATIC_DIR}/${GENERATED_DIR}/manifest.js`;
export const NAV_SRC = `${STATIC_DIR}/${GENERATED_DIR}/nav.js`;
export const TOC_SRC = `${STATIC_DIR}/${GENERATED_DIR}/toc.js`;
