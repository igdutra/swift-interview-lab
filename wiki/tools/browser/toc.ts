/* GENERATED from wiki/tools/browser/toc.ts — edit the .ts, then run: tsc -p wiki/tools/browser */
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
  const body = document.body;
  if (body.hasAttribute("data-no-toc")) {
    return;
  }
  const bodyCategory = body.getAttribute("data-category") ?? "";
  if (bodyCategory === "hub") {
    return;
  }
  const pageContainer = document.querySelector("div.page");
  const contentColumn = document.querySelector("main.content");
  if (pageContainer === null || contentColumn === null) {
    return;
  }

  function cleanedHeadingText(heading: Element): string {
    const headingCopy = heading.cloneNode(true) as Element;
    for (const numberSpan of Array.from(headingCopy.querySelectorAll(".sec-num"))) {
      numberSpan.remove();
    }
    const text = (headingCopy.textContent ?? "").replace(/\s+/g, " ").trim();
    // Strip a hand-written leading section number ("7 " or "7. ").
    return text.replace(/^\d+[.)]?\s+/, "");
  }

  interface TocEntry {
    anchorId: string;
    label: string;
    subEntries: { anchorId: string; label: string }[];
  }

  const entries: TocEntry[] = [];
  const sections = Array.from(contentColumn.querySelectorAll(":scope > section[id]"));

  if (sections.length > 0) {
    for (const section of sections) {
      const anchorId = section.getAttribute("id") ?? "";
      const explicitLabel = section.getAttribute("data-toc-label");
      const firstHeading = section.querySelector("h2");
      const label = explicitLabel ?? (firstHeading !== null ? cleanedHeadingText(firstHeading) : "");
      if (label === "") {
        continue;
      }
      const subEntries = Array.from(section.querySelectorAll("[id][data-toc-label]"))
        .filter((candidate) => candidate !== section)
        .map((candidate) => ({
          anchorId: candidate.getAttribute("id") ?? "",
          label: candidate.getAttribute("data-toc-label") ?? "",
        }))
        .filter((subEntry) => subEntry.anchorId !== "" && subEntry.label !== "");
      entries.push({ anchorId, label, subEntries });
    }
  } else {
    for (const heading of Array.from(contentColumn.querySelectorAll("h2[id]"))) {
      const anchorId = heading.getAttribute("id") ?? "";
      const label = heading.getAttribute("data-toc-label") ?? cleanedHeadingText(heading);
      if (anchorId !== "" && label !== "") {
        entries.push({ anchorId, label, subEntries: [] });
      }
    }
  }

  if (entries.length < 2) {
    return;
  }

  function escapeHtml(text: string): string {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  const categoryTitles: Record<string, string> = {
    theory: "Theory · Contents",
    walkthrough: "Walkthrough · Contents",
    reference: "Reference · Contents",
  };
  const tocTitle = categoryTitles[bodyCategory] ?? "Contents";
  const tocTitleClass = bodyCategory === "theory" || bodyCategory === "walkthrough" ? ` toc-cat-${bodyCategory}` : "";

  const linkParts: string[] = [];
  entries.forEach((entry, entryIndex) => {
    linkParts.push(
      `<a href="#${entry.anchorId}" class="toc-link"><span class="toc-num">${entryIndex + 1}</span> ${escapeHtml(entry.label)}</a>`,
    );
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
