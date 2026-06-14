Use this repo as a Swift LeetCode practice workspace.

The local skill at `.claude/skills/leetcode/SKILL.md` is the source of truth for `/leetcode` scaffolding.

## Repo layout

- `SwiftInterviewLab/` — the Swift package (`Package.swift`, `Sources/`, `Tests/`). Open this folder in Xcode.
- `wiki/` — static study wiki (theory + walkthroughs).
- Everything else (study plans, assets, this file) lives at the repo root and is never seen by Xcode.

## Test file pattern

- One problem, one self-contained test file.
- Include the LeetCode title, URL, difficulty, and topics in the header.
- Use `{number}_{Pascal_Snake_Case_Title}.swift`.
- Keep the solution function `private`.
- Use Swift Testing only: `import Testing`, `@Suite`, `@Test`, `#expect`.
- Do not use `Solution` classes or XCTest.
- If you are editing the currently checked-in example, follow its self-contained test-file style first.
- Run tests from the package root: `cd SwiftInterviewLab && swift test`

## Study wiki (wiki/)

- `wiki/` is the static Wikipedia-style study wiki (theory pages + LeetCode walkthroughs).
- Run it with: `cd wiki && python3 -m http.server 8080`, then open http://localhost:5050.
- To add a page: drop the HTML file in the right folder and add one line to `wiki/_shared/pages.js` — the nav bar and hub index update automatically. Full checklist: `wiki/_standards/HOW_TO_ADD_PAGES.md`.
- Page conventions live in the three standards docs in `wiki/_standards/`: `THEORY_MASTERFILE_STANDARD.md`, `WALKTHROUGH_MASTERFILE_STANDARD.md`, `WIKI_CSS_STYLE_RESEARCH.md`.
