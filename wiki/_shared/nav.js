// ============================================================
// nav.js — builds the top nav bar (every page) and the hub
// card grid (index.html only) from WIKI_PAGES in pages.js.
// Pages never hard-code navigation; they include:
//   <nav id="topnav" class="topnav"></nav>
//   ...
//   <script src="../_shared/pages.js"></script>
//   <script src="../_shared/nav.js"></script>
// (paths are ./_shared/... from the wiki root, ../_shared/...
//  from theory/ and walkthroughs/)
// ============================================================
(function () {
  // Depth of the current page relative to the wiki root.
  var path = location.pathname.replace(/\/+$/, "");
  var fromRoot = /\/(theory|walkthroughs)\//.test(path) ? "../" : "./";

  function isCurrent(pagePath) {
    return path.indexOf(pagePath.split("/").pop()) !== -1;
  }

  // --- top nav bar ---
  var nav = document.getElementById("topnav");
  if (nav) {
    // Home links to the directory root, not index.html — some static
    // servers only serve the hub at "/", and "./" works everywhere.
    var isHub = !/\/(theory|walkthroughs)\//.test(path);
    var html = '<a href="' + fromRoot + '"' +
      (isHub ? ' class="current"' : "") +
      ">Home</a>";
    ["theory", "walkthrough"].forEach(function (cat) {
      var items = WIKI_PAGES.filter(function (p) { return p.cat === cat; });
      if (!items.length) return;
      html += '<span class="nav-cat">' + (cat === "theory" ? "Theory" : "Walkthroughs") + "</span>";
      items.forEach(function (p) {
        html += '<a href="' + fromRoot + p.path + '"' +
          (isCurrent(p.path) ? ' class="current"' : "") + ">" + p.nav + "</a>";
      });
    });
    nav.innerHTML = html;
  }

  // --- hub card grid (index.html has <div id="hub"></div>) ---
  var hub = document.getElementById("hub");
  if (hub) {
    var out = "";
    [["theory", "Theory masterfiles", "backref-card"],
     ["walkthrough", "LeetCode walkthroughs", "xref-card"]].forEach(function (def) {
      var items = WIKI_PAGES.filter(function (p) { return p.cat === def[0]; });
      if (!items.length) return;
      out += '<div class="hub-section-title">' + def[1] + "</div>";
      out += '<div class="ref-grid">';
      items.forEach(function (p) {
        var diffNames = { E: "Easy", M: "Medium", H: "Hard" };
        var meta = "";
        if (p.difficulty) {
          meta += '<span class="tag tag-' + p.difficulty + '">' + diffNames[p.difficulty] + "</span>";
        }
        if (p.topics && p.topics.length) {
          meta += '<span class="ref-topics">' + p.topics.join(" · ") + "</span>";
        }
        out += '<a class="' + def[2] + '" href="' + p.path + '">' +
          '<span class="ref-file">' + p.path + "</span>" +
          '<span class="ref-title">' + p.title + "</span>" +
          (meta ? '<span class="ref-meta">' + meta + "</span>" : "") +
          '<span class="ref-desc">' + p.blurb + "</span></a>";
      });
      out += "</div>";
    });
    hub.innerHTML = out;
  }
})();
