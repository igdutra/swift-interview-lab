/* GENERATED from wiki/engine/browser/nav.ts — edit the .ts, then run: tsc -p wiki/engine/browser */
// ============================================================
// nav.ts — builds the top nav (every page) and the hub card
// grids from WIKI_MANIFEST (static/generated/manifest.js, generated).
//
// Pages carry only placeholders:
//   <nav id="topnav" class="topnav"></nav>   — the nav bar
//   <div id="hub"></div>                     — root hub grid
//   <div data-hub-grid></div>                — section/category hub grid
// ============================================================
(function () {
  // --- wiki root URL, derived from this script's own src ---------------
  // The include is always "{prefix}static/generated/nav.js", so stripping
  // that suffix from the resolved src yields the wiki root at any depth,
  // under any server mount, with or without trailing-slash URLs.
  // This literal mirrors NAV_SRC in engine/lib/paths.ts — keep them in sync
  // (the browser layer has no module system to import the constant).
  const NAV_SCRIPT_SUFFIX = "static/generated/nav.js";
  const scriptElement = document.currentScript as HTMLScriptElement | null;
  const scriptSource = scriptElement !== null ? scriptElement.src : "";
  const wikiRootUrl = scriptSource.endsWith(NAV_SCRIPT_SUFFIX)
    ? scriptSource.slice(0, scriptSource.length - NAV_SCRIPT_SUFFIX.length)
    : "./";

  // --- current page: pathname relative to the wiki root -----------------
  // Suffix-matching manifest keys is ambiguous: every hub's .../index.html
  // also ends with the root home's key "index.html". Resolving against the
  // root URL gives exactly one candidate at any mount depth.
  const rawPathname = decodeURIComponent(location.pathname);
  const normalizedPathname = rawPathname.endsWith("/") ? `${rawPathname}index.html` : rawPathname;
  const wikiRootPathname = wikiRootUrl === "./" ? null : new URL(wikiRootUrl).pathname;
  const candidatePath =
    wikiRootPathname !== null && normalizedPathname.startsWith(wikiRootPathname)
      ? normalizedPathname.slice(wikiRootPathname.length)
      : null;
  const currentPath =
    candidatePath !== null && Object.prototype.hasOwnProperty.call(WIKI_MANIFEST.pages, candidatePath)
      ? candidatePath
      : null;
  const currentRecord = currentPath !== null ? WIKI_MANIFEST.pages[currentPath] : null;

  function escapeHtml(text: string): string {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function pageUrl(pagePath: string): string {
    return wikiRootUrl + pagePath;
  }

  // --- top nav bar -------------------------------------------------------
  //
  // Exactly ONE group per domain, so the bar's width is a function of how
  // many domains exist — not how much content they hold. Depth is revealed
  // on hover, capped at two menu levels:
  //
  //   [LeetCode ▾] → Theory ▸ → Arrays & Hashing   (a section HUB)
  //                  Reference ▸ → Cheat Sheet     (a page)
  //
  // A sections-layout category lists its section hubs rather than every
  // page, which keeps the cascade at two levels: the hub page itself is
  // the third level, reached by clicking instead of hovering further.

  /** One entry in a submenu: a real link with a label. */
  interface SubmenuEntry {
    label: string;
    path: string | null;
    difficulty: string | null;
  }

  function renderSubmenuEntry(entry: SubmenuEntry): string {
    if (entry.path === null) {
      return `<span class="nav-item nav-item-empty">${escapeHtml(entry.label)}</span>`;
    }
    const currentClass = entry.path === currentPath ? " current" : "";
    const chip =
      entry.difficulty !== null ? `<span class="tag tag-${entry.difficulty}">${entry.difficulty}</span> ` : "";
    return `<a class="nav-item${currentClass}" href="${pageUrl(entry.path)}">${chip}${escapeHtml(entry.label)}</a>`;
  }

  /** A category row inside a domain menu, with its own fly-out submenu. */
  function renderCategoryRow(category: WikiManifestCategory): string {
    const entries: SubmenuEntry[] =
      category.layout === "sections"
        ? category.sections.map((section) => ({
            label: section.label,
            path: section.hubPath,
            difficulty: null,
          }))
        : category.pagePaths.map((pagePath) => ({
            label: WIKI_MANIFEST.pages[pagePath].title,
            path: pagePath,
            difficulty: WIKI_MANIFEST.pages[pagePath].difficulty,
          }));

    if (entries.length === 0) {
      return "";
    }

    const descendantPaths =
      category.layout === "sections"
        ? category.sections.flatMap((section) =>
            section.hubPath !== null ? [section.hubPath, ...section.pagePaths] : section.pagePaths,
          )
        : category.pagePaths;
    const containsCurrent =
      descendantPaths.some((pagePath) => pagePath === currentPath) || category.hubPath === currentPath;

    const rowClass = `nav-item nav-subtrigger${containsCurrent ? " current" : ""}`;
    const label = `${escapeHtml(category.label)} <span class="nav-caret">▸</span>`;
    const row =
      category.hubPath !== null
        ? `<a class="${rowClass}" href="${pageUrl(category.hubPath)}">${label}</a>`
        : `<span class="${rowClass}" tabindex="0">${label}</span>`;
    const submenuClass = `nav-submenu${entries.length > 12 ? " nav-menu-scroll" : ""}`;
    return `<div class="nav-subgroup">${row}<div class="${submenuClass}">${entries.map(renderSubmenuEntry).join("")}</div></div>`;
  }

  const topNav = document.getElementById("topnav");
  if (topNav !== null) {
    const homeCurrentClass = currentRecord !== null && currentRecord.role === "home" ? ' class="current"' : "";
    const navParts: string[] = [`<a href="${wikiRootUrl}"${homeCurrentClass}>Home</a>`];

    for (const domain of WIKI_MANIFEST.domains) {
      const rows = domain.categories.map(renderCategoryRow).join("");
      if (rows === "") {
        continue;
      }
      const isCurrentDomain = currentRecord !== null && currentRecord.domain === domain.identifier;
      const triggerClass = `nav-trigger${isCurrentDomain ? " current" : ""}`;
      const trigger = `<span class="${triggerClass}" tabindex="0">${escapeHtml(domain.label)} <span class="nav-caret">▾</span></span>`;
      navParts.push(`<div class="nav-group">${trigger}<div class="nav-menu">${rows}</div></div>`);
    }
    topNav.innerHTML = navParts.join("");
  }

  // --- hub cards ----------------------------------------------------------
  function renderCard(pagePath: string, cardClass: "xref-card" | "backref-card"): string {
    const record = WIKI_MANIFEST.pages[pagePath];
    const difficultyNames: Record<string, string> = { E: "Easy", M: "Medium", H: "Hard" };
    const metaParts: string[] = [];
    if (record.difficulty !== null) {
      metaParts.push(`<span class="tag tag-${record.difficulty}">${difficultyNames[record.difficulty]}</span>`);
    }
    if (record.topics.length > 0) {
      metaParts.push(`<span class="ref-topics">${escapeHtml(record.topics.join(" · "))}</span>`);
    }
    const metaMarkup = metaParts.length > 0 ? `<span class="ref-meta">${metaParts.join("")}</span>` : "";
    return (
      `<a class="${cardClass}" href="${pageUrl(pagePath)}">` +
      `<span class="ref-file">${escapeHtml(record.path)}</span>` +
      `<span class="ref-title">${escapeHtml(record.title)}</span>` +
      metaMarkup +
      `<span class="ref-desc">${escapeHtml(record.blurb)}</span></a>`
    );
  }

  function renderCardGrid(pagePaths: string[], cardClass: "xref-card" | "backref-card"): string {
    return `<div class="ref-grid">${pagePaths.map((pagePath) => renderCard(pagePath, cardClass)).join("")}</div>`;
  }

  // Root hub (<div id="hub"> on the home page): one group per category.
  const rootHub = document.getElementById("hub");
  if (rootHub !== null) {
    const showDomainLabels = WIKI_MANIFEST.domains.length > 1;
    const hubParts: string[] = [];
    for (const domain of WIKI_MANIFEST.domains) {
      for (const category of domain.categories) {
        const sectionTitle = showDomainLabels ? `${domain.label} — ${category.label}` : category.label;
        hubParts.push(`<div class="hub-section-title">${escapeHtml(sectionTitle)}</div>`);
        if (category.layout === "sections") {
          const hubPaths = category.sections
            .map((section) => section.hubPath)
            .filter((hubPath): hubPath is string => hubPath !== null);
          hubParts.push(renderCardGrid(hubPaths, "backref-card"));
        } else {
          const pagePaths = category.hubPath !== null ? [category.hubPath, ...category.pagePaths] : category.pagePaths;
          hubParts.push(renderCardGrid(pagePaths, "xref-card"));
        }
      }
    }
    rootHub.innerHTML = hubParts.join("");
  }

  // Section/category hub (<div data-hub-grid> on hub pages): its own pages.
  const hubGrid = document.querySelector("[data-hub-grid]");
  if (hubGrid !== null && currentRecord !== null && currentRecord.role === "hub") {
    const gridParts: string[] = [];
    for (const domain of WIKI_MANIFEST.domains) {
      for (const category of domain.categories) {
        if (category.identifier !== currentRecord.category) {
          continue;
        }
        if (category.layout === "sections") {
          const section = category.sections.find((candidate) => candidate.identifier === currentRecord.section);
          if (section === undefined) {
            continue;
          }
          const overviewPaths = section.pagePaths.filter((pagePath) => WIKI_MANIFEST.pages[pagePath].role === "overview");
          const deepDivePaths = section.pagePaths.filter((pagePath) => WIKI_MANIFEST.pages[pagePath].role === "deep-dive");
          if (overviewPaths.length > 0) {
            gridParts.push(`<div class="hub-section-title">Overview</div>`);
            gridParts.push(renderCardGrid(overviewPaths, "xref-card"));
          }
          if (deepDivePaths.length > 0) {
            gridParts.push(`<div class="hub-section-title">Deep Dives</div>`);
            gridParts.push(renderCardGrid(deepDivePaths, "xref-card"));
          }
        } else {
          gridParts.push(renderCardGrid(category.pagePaths, "xref-card"));
        }
      }
    }
    hubGrid.innerHTML = gridParts.join("");
  }
})();
