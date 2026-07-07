// ============================================================
// serve.ts — zero-dependency static server for local reading.
//
//   node wiki/tools/serve.ts
//   → http://localhost:5050
// ============================================================

import { createServer } from "node:http";
import { existsSync, readFileSync, statSync } from "node:fs";
import { dirname, extname, join, normalize, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { wikiConfiguration } from "./wiki.config.ts";

const wikiRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

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

const server = createServer((request, response) => {
  const requestPath = decodeURIComponent((request.url ?? "/").split("?")[0]);
  const safePath = normalize(requestPath).replaceAll("\\", "/");

  if (safePath.includes("..")) {
    response.statusCode = 400;
    response.end("Bad request");
    return;
  }

  let filePath = join(wikiRoot, safePath);
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
