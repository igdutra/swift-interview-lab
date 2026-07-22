"use strict";
/* GENERATED from wiki/engine/browser/toc.ts — edit the .ts, then run: tsc -p wiki/engine/browser */
// ============================================================
// toc.ts — generates the sticky table of contents from the
// page's own anchors, so the TOC can never drift from the
// sections it links to.
//
// Anchor sources, in preference order:
//   1. <section id="…"> direct children of main.content
//      (label = data-toc-label, else the first <h2> text);
//      elements inside a section carrying data-toc-label + id
//      become indented sub-entries.
//   2. <h2 id="…"> headings (reference-style pages).
//
// Pages opt out with <body data-no-toc>; hub pages never get one.
// ============================================================
(function () {
    var _a, _b, _c, _d, _e;
    const body = document.body;
    if (body.hasAttribute("data-no-toc")) {
        return;
    }
    const bodyCategory = (_a = body.getAttribute("data-category")) !== null && _a !== void 0 ? _a : "";
    if (bodyCategory === "hub") {
        return;
    }
    const pageContainer = document.querySelector("div.page");
    const contentColumn = document.querySelector("main.content");
    if (pageContainer === null || contentColumn === null) {
        return;
    }
    function cleanedHeadingText(heading) {
        var _a;
        const headingCopy = heading.cloneNode(true);
        for (const numberSpan of Array.from(headingCopy.querySelectorAll(".sec-num"))) {
            numberSpan.remove();
        }
        const text = ((_a = headingCopy.textContent) !== null && _a !== void 0 ? _a : "").replace(/\s+/g, " ").trim();
        // Strip a hand-written leading section number ("7 " or "7. ").
        return text.replace(/^\d+[.)]?\s+/, "");
    }
    const entries = [];
    const sections = Array.from(contentColumn.querySelectorAll(":scope > section[id]"));
    if (sections.length > 0) {
        for (const section of sections) {
            const anchorId = (_b = section.getAttribute("id")) !== null && _b !== void 0 ? _b : "";
            const explicitLabel = section.getAttribute("data-toc-label");
            const firstHeading = section.querySelector("h2");
            const label = explicitLabel !== null && explicitLabel !== void 0 ? explicitLabel : (firstHeading !== null ? cleanedHeadingText(firstHeading) : "");
            if (label === "") {
                continue;
            }
            const subEntries = Array.from(section.querySelectorAll("[id][data-toc-label]"))
                .filter((candidate) => candidate !== section)
                .map((candidate) => {
                var _a, _b;
                return ({
                    anchorId: (_a = candidate.getAttribute("id")) !== null && _a !== void 0 ? _a : "",
                    label: (_b = candidate.getAttribute("data-toc-label")) !== null && _b !== void 0 ? _b : "",
                });
            })
                .filter((subEntry) => subEntry.anchorId !== "" && subEntry.label !== "");
            entries.push({ anchorId, label, subEntries });
        }
    }
    else {
        for (const heading of Array.from(contentColumn.querySelectorAll("h2[id]"))) {
            const anchorId = (_c = heading.getAttribute("id")) !== null && _c !== void 0 ? _c : "";
            const label = (_d = heading.getAttribute("data-toc-label")) !== null && _d !== void 0 ? _d : cleanedHeadingText(heading);
            if (anchorId !== "" && label !== "") {
                entries.push({ anchorId, label, subEntries: [] });
            }
        }
    }
    if (entries.length < 2) {
        return;
    }
    function escapeHtml(text) {
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;");
    }
    // Title and accent come from the manifest (built from each page type's
    // `tocTitle` / `tocAccent` in wiki.config.ts), so this file knows no
    // content names. A new page type needs no edit here.
    const tocStyle = typeof WIKI_MANIFEST !== "undefined" ? WIKI_MANIFEST.tocStyles[bodyCategory] : undefined;
    const tocTitle = (_e = tocStyle === null || tocStyle === void 0 ? void 0 : tocStyle.title) !== null && _e !== void 0 ? _e : "Contents";
    const tocTitleClass = (tocStyle === null || tocStyle === void 0 ? void 0 : tocStyle.accent) != null ? ` toc-accent-${tocStyle.accent}` : "";
    const linkParts = [];
    entries.forEach((entry, entryIndex) => {
        linkParts.push(`<a href="#${entry.anchorId}" class="toc-link"><span class="toc-num">${entryIndex + 1}</span> ${escapeHtml(entry.label)}</a>`);
        if (entry.subEntries.length > 0) {
            const subLinks = entry.subEntries
                .map((subEntry) => `<a href="#${subEntry.anchorId}" class="toc-link">${escapeHtml(subEntry.label)}</a>`)
                .join("");
            linkParts.push(`<div class="toc-sub">${subLinks}</div>`);
        }
    });
    const tocColumn = document.createElement("nav");
    tocColumn.className = "toc-col";
    tocColumn.innerHTML = `<div class="toc-inner"><div class="toc-title${tocTitleClass}">${tocTitle}</div>${linkParts.join("")}</div>`;
    pageContainer.insertBefore(tocColumn, pageContainer.firstChild);
})();
