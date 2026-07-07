// ============================================================
// serve.ts — zero-dependency static server for local reading.
//
//   node wiki/engine/commands/serve.ts
//   → http://localhost:5050
//
// Two roots are served under clean URLs: content pages come from
// content/ (so "/theory/…" needs no "/content" prefix), while the
// loaded files under "/static/…" come from the wiki root. The URL
// space matches exactly what a page's relative links expect.
// ============================================================

import { createServer } from "node:http";
import { existsSync, readFileSync, statSync } from "node:fs";
import { extname, join, normalize } from "node:path";
import { wikiConfiguration } from "../../wiki.config.ts";
import { CONTENT_ROOT, STATIC_DIR, WIKI_ROOT } from "../lib/paths.ts";

const MIME_TYPES: Record<string, string> = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".woff2": "font/woff2",
  ".txt": "text/plain; charset=utf-8",
};

/** Requests under /static/ serve from the wiki root; all else from content/. */
function baseRootFor(safePath: string): string {
  const firstSegment = safePath.replace(/^\//, "").split("/")[0];
  return firstSegment === STATIC_DIR ? WIKI_ROOT : CONTENT_ROOT;
}

const server = createServer((request, response) => {
  const requestPath = decodeURIComponent((request.url ?? "/").split("?")[0]);
  const safePath = normalize(requestPath).replaceAll("\\", "/");

  if (safePath.includes("..")) {
    response.statusCode = 400;
    response.end("Bad request");
    return;
  }

  let filePath = join(baseRootFor(safePath), safePath);
  if (existsSync(filePath) && statSync(filePath).isDirectory()) {
    // Directory URLs need the trailing slash, or the page's relative links
    // would resolve one level too high. Redirect like every static server.
    if (!requestPath.endsWith("/")) {
      response.statusCode = 301;
      response.setHeader("Location", `${requestPath}/`);
      response.end();
      return;
    }
    filePath = join(filePath, "index.html");
  }
  if (!existsSync(filePath) || !statSync(filePath).isFile()) {
    response.statusCode = 404;
    response.setHeader("Content-Type", "text/plain; charset=utf-8");
    response.end(`404 — no such page: ${safePath}`);
    return;
  }

  response.statusCode = 200;
  response.setHeader("Content-Type", MIME_TYPES[extname(filePath)] ?? "application/octet-stream");
  // Without this, browsers heuristically cache assets and keep serving a
  // stale wiki.css/nav.js across editing sessions.
  response.setHeader("Cache-Control", "no-store");
  response.end(readFileSync(filePath));
});

server.listen(wikiConfiguration.serverPort, () => {
  console.log(`${wikiConfiguration.siteTitle} → http://localhost:${wikiConfiguration.serverPort}`);
});
