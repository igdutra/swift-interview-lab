"use strict";
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
    var _a, _b;
    // --- wiki root URL, derived from this script's own src ---------------
    // The include is always "{prefix}static/generated/nav.js", so stripping
    // that suffix from the resolved src yields the wiki root at any depth,
    // under any server mount, with or without trailing-slash URLs.
    // This literal mirrors NAV_SRC in engine/lib/paths.ts — keep them in sync
    // (the browser layer has no module system to import the constant).
    const NAV_SCRIPT_SUFFIX = "static/generated/nav.js";
    const scriptElement = document.currentScript;
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
    const candidatePath = wikiRootPathname !== null && normalizedPathname.startsWith(wikiRootPathname)
        ? normalizedPathname.slice(wikiRootPathname.length)
        : null;
    const currentPath = candidatePath !== null && Object.prototype.hasOwnProperty.call(WIKI_MANIFEST.pages, candidatePath)
        ? candidatePath
        : null;
    const currentRecord = currentPath !== null ? WIKI_MANIFEST.pages[currentPath] : null;
    function escapeHtml(text) {
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;");
    }
    function pageUrl(pagePath) {
        return wikiRootUrl + pagePath;
    }
    function renderSubmenuEntry(entry) {
        if (entry.path === null) {
            return `<span class="nav-item nav-item-empty">${escapeHtml(entry.label)}</span>`;
        }
        const currentClass = entry.path === currentPath ? " current" : "";
        const chip = entry.difficulty !== null ? `<span class="tag tag-${entry.difficulty}">${entry.difficulty}</span> ` : "";
        return `<a class="nav-item${currentClass}" href="${pageUrl(entry.path)}">${chip}${escapeHtml(entry.label)}</a>`;
    }
    /** A category row inside a domain menu, with its own fly-out submenu. */
    function renderCategoryRow(category) {
        const entries = category.layout === "sections"
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
        const descendantPaths = category.layout === "sections"
            ? category.sections.flatMap((section) => section.hubPath !== null ? [section.hubPath, ...section.pagePaths] : section.pagePaths)
            : category.pagePaths;
        const containsCurrent = descendantPaths.some((pagePath) => pagePath === currentPath) || category.hubPath === currentPath;
        const rowClass = `nav-item nav-subtrigger${containsCurrent ? " current" : ""}`;
        const label = `${escapeHtml(category.label)} <span class="nav-caret">▸</span>`;
        const row = category.hubPath !== null
            ? `<a class="${rowClass}" href="${pageUrl(category.hubPath)}">${label}</a>`
            : `<span class="${rowClass}" tabindex="0">${label}</span>`;
        const submenuClass = `nav-submenu${entries.length > 12 ? " nav-menu-scroll" : ""}`;
        return `<div class="nav-subgroup">${row}<div class="${submenuClass}">${entries.map(renderSubmenuEntry).join("")}</div></div>`;
    }
    const topNav = document.getElementById("topnav");
    if (topNav !== null) {
        const homeCurrentClass = currentRecord !== null && currentRecord.role === "home" ? ' class="current"' : "";
        const navParts = [`<a href="${wikiRootUrl}"${homeCurrentClass}>Home</a>`];
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
        // Flip a submenu leftward only when opening rightward would overflow
        // the viewport. Measured on hover because a hidden element has no
        // usable geometry, and re-measured every time since the viewport can
        // be resized between openings.
        for (const subgroup of Array.from(topNav.querySelectorAll(".nav-subgroup"))) {
            subgroup.addEventListener("mouseenter", function () {
                const submenu = subgroup.querySelector(".nav-submenu");
                if (submenu === null) {
                    return;
                }
                submenu.classList.remove("nav-submenu-left");
                const bounds = submenu.getBoundingClientRect();
                if (bounds.right > document.documentElement.clientWidth) {
                    submenu.classList.add("nav-submenu-left");
                }
            });
        }
    }
    // --- hub cards ----------------------------------------------------------
    function renderCard(pagePath, cardClass) {
        const record = WIKI_MANIFEST.pages[pagePath];
        const difficultyNames = { E: "Easy", M: "Medium", H: "Hard" };
        const metaParts = [];
        if (record.difficulty !== null) {
            metaParts.push(`<span class="tag tag-${record.difficulty}">${difficultyNames[record.difficulty]}</span>`);
        }
        if (record.topics.length > 0) {
            metaParts.push(`<span class="ref-topics">${escapeHtml(record.topics.join(" · "))}</span>`);
        }
        const metaMarkup = metaParts.length > 0 ? `<span class="ref-meta">${metaParts.join("")}</span>` : "";
        return (`<a class="${cardClass}" href="${pageUrl(pagePath)}">` +
            `<span class="ref-file">${escapeHtml(record.path)}</span>` +
            `<span class="ref-title">${escapeHtml(record.title)}</span>` +
            metaMarkup +
            `<span class="ref-desc">${escapeHtml(record.blurb)}</span></a>`);
    }
    function renderCardGrid(pagePaths, cardClass) {
        return `<div class="ref-grid">${pagePaths.map((pagePath) => renderCard(pagePath, cardClass)).join("")}</div>`;
    }
    // Root hub (<div id="hub"> on the home page): ONE card per category,
    // grouped by domain. The home page is an entry point, not a directory —
    // listing every page made it grow without bound (52 cards at two
    // domains, 37 of them individual walkthroughs). Depth lives one click
    // away, in the category and section hubs.
    const rootHub = document.getElementById("hub");
    if (rootHub !== null) {
        const hubParts = [];
        for (const domain of WIKI_MANIFEST.domains) {
            const cards = [];
            for (const category of domain.categories) {
                const pageCount = category.layout === "sections"
                    ? category.sections.reduce((runningTotal, section) => runningTotal + section.pagePaths.length, 0)
                    : category.pagePaths.length;
                if (pageCount === 0) {
                    continue;
                }
                // Prefer the category's own hub; otherwise its first section hub.
                const landingPath = (_b = (_a = category.hubPath) !== null && _a !== void 0 ? _a : category.sections.map((section) => section.hubPath).find((hubPath) => hubPath !== null)) !== null && _b !== void 0 ? _b : null;
                if (landingPath === null) {
                    continue;
                }
                const plural = (count, noun) => `${count} ${noun}${count === 1 ? "" : "s"}`;
                const subtitle = category.layout === "sections"
                    ? `${plural(category.sections.length, "section")} · ${plural(pageCount, "page")}`
                    : plural(pageCount, "page");
                cards.push(`<a class="xref-card" href="${pageUrl(landingPath)}">` +
                    `<span class="ref-title">${escapeHtml(category.label)}</span>` +
                    `<span class="ref-meta"><span class="ref-topics">${escapeHtml(subtitle)}</span></span></a>`);
            }
            if (cards.length === 0) {
                continue;
            }
            hubParts.push(`<div class="hub-section-title">${escapeHtml(domain.label)}</div>`);
            hubParts.push(`<div class="ref-grid">${cards.join("")}</div>`);
        }
        rootHub.innerHTML = hubParts.join("");
    }
    // Section/category hub (<div data-hub-grid> on hub pages): its own pages.
    const hubGrid = document.querySelector("[data-hub-grid]");
    if (hubGrid !== null && currentRecord !== null && currentRecord.role === "hub") {
        const gridParts = [];
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
                }
                else {
                    gridParts.push(renderCardGrid(category.pagePaths, "xref-card"));
                }
            }
        }
        hubGrid.innerHTML = gridParts.join("");
    }
})();
