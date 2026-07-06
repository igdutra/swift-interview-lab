/* GENERATED from wiki/tools/browser/nav.ts — edit the .ts, then run: tsc -p wiki/tools/browser */
// ============================================================
// nav.ts — builds the top nav (every page) and the hub card
// grids from WIKI_MANIFEST (_shared/manifest.js, generated).
//
// Pages carry only placeholders:
//   <nav id="topnav" class="topnav"></nav>   — the nav bar
//   <div id="hub"></div>                     — root hub grid
//   <div data-hub-grid></div>                — section/category hub grid
// ============================================================
(function () {
  // --- wiki root URL, derived from this script's own src ---------------
  // The include is always "{prefix}_shared/nav.js", so stripping that
  // suffix from the resolved src yields the wiki root at any depth,
  // under any server mount, with or without trailing-slash URLs.
  const NAV_SCRIPT_SUFFIX = "_shared/nav.js";
  const scriptElement = document.currentScript as HTMLScriptElement | null;
  const scriptSource = scriptElement !== null ? scriptElement.src : "";
  const wikiRootUrl = scriptSource.endsWith(NAV_SCRIPT_SUFFIX)
    ? scriptSource.slice(0, scriptSource.length - NAV_SCRIPT_SUFFIX.length)
    : "./";

  // --- current page: exact match against manifest keys ------------------
  const rawPathname = decodeURIComponent(location.pathname);
  const normalizedPathname = rawPathname.endsWith("/") ? `${rawPathname}index.html` : rawPathname;
  let currentPath: string | null = null;
  for (const pagePath of Object.keys(WIKI_MANIFEST.pages)) {
    if (normalizedPathname === `/${pagePath}` || normalizedPathname.endsWith(`/${pagePath}`)) {
      currentPath = pagePath;
      break;
    }
  }
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

  function difficultyChip(record: WikiManifestPageRecord): string {
    return record.difficulty !== null
      ? `<span class="tag tag-${record.difficulty}">${record.difficulty}</span> `
      : "";
  }

  function menuItem(pagePath: string): string {
    const record = WIKI_MANIFEST.pages[pagePath];
    const currentClass = pagePath === currentPath ? " current" : "";
    return `<a class="nav-item${currentClass}" href="${pageUrl(pagePath)}">${difficultyChip(record)}${escapeHtml(record.title)}</a>`;
  }

  interface NavGroup {
    label: string;
    triggerPath: string | null; // where clicking the group header goes
    itemPaths: string[]; // dropdown contents, in order
    scrollable: boolean;
  }

  function renderNavGroup(group: NavGroup): string {
    const containsCurrent = group.itemPaths.some((itemPath) => itemPath === currentPath);
    const triggerClass = `nav-trigger${containsCurrent ? " current" : ""}`;
    const triggerLabel = `${escapeHtml(group.label)} <span class="nav-caret">▾</span>`;
    const trigger =
      group.triggerPath !== null
        ? `<a class="${triggerClass}" href="${pageUrl(group.triggerPath)}">${triggerLabel}</a>`
        : `<span class="${triggerClass}" tabindex="0">${triggerLabel}</span>`;
    const menuClass = `nav-menu${group.scrollable ? " nav-menu-scroll" : ""}`;
    const menuItems = group.itemPaths.map(menuItem).join("");
    return `<div class="nav-group">${trigger}<div class="${menuClass}">${menuItems}</div></div>`;
  }

  // --- top nav bar -------------------------------------------------------
  const topNav = document.getElementById("topnav");
  if (topNav !== null) {
    const showDomainLabels = WIKI_MANIFEST.domains.length > 1;
    const homeCurrentClass = currentRecord !== null && currentRecord.role === "home" ? ' class="current"' : "";
    const navParts: string[] = [`<a href="${wikiRootUrl}"${homeCurrentClass}>Home</a>`];

    for (const domain of WIKI_MANIFEST.domains) {
      if (showDomainLabels) {
        navParts.push(`<span class="nav-cat">${escapeHtml(domain.label)}</span>`);
      }
      for (const category of domain.categories) {
        if (category.layout === "sections") {
          for (const section of category.sections) {
            const itemPaths = section.hubPath !== null ? [section.hubPath, ...section.pagePaths] : section.pagePaths;
            navParts.push(
              renderNavGroup({
                label: section.label,
                triggerPath: section.hubPath,
                itemPaths,
                scrollable: false,
              }),
            );
          }
        } else {
          const itemPaths = category.hubPath !== null ? [category.hubPath, ...category.pagePaths] : category.pagePaths;
          navParts.push(
            renderNavGroup({
              label: category.label,
              triggerPath: category.hubPath,
              itemPaths,
              scrollable: category.pagePaths.length > 12,
            }),
          );
        }
      }
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
