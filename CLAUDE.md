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

## Playground source files (Sources/)

Each problem has two files: a playground in `Sources/` for live exploration, and a self-contained test in `Tests/` (see below).

The playground file always opens with a `/* PLAN */` comment block **before any code**, written as the spoken plan you would give in a real interview. It covers:

1. **Pattern** — why this technique (e.g. "sliding window — we want the longest contiguous subarray")
2. **Condition** — when is the window valid / invalid, and where to record (inside the loop vs. after)
3. **State** — the variables: pointers, counters, accumulators
4. **(optional) Walk-through** — a mental trace confirming the logic before coding
5. **(optional) Optimizations** — improvements noted after the baseline works

The implementation goes inside `#Playground { }` and intentionally keeps `print()` statements — some live, some commented out. They document the debugging journey and are not noise to remove.

The playground is exploratory and throwaway. The test file is the canonical, clean solution.

## Code style

- Never use single-letter or abbreviated variable names (`n`, `i`, `d`, `var n`). Always use descriptive names (`number`, `index`, `digit`, `remaining`).

## Commits

- Commit messages are a **single line**, following Conventional Commits (`type(scope): summary`). Descriptive yet short enough to fit on one line — no body, no bullet list.
- End every commit with the co-author trailer right after the subject line:

  ```
  Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
  ```

## LeetCode tutor mode

Tutor mode is **on by default** during problem-solving sessions.

- Ask one short guiding question at a time — don't give the answer unprompted
- Give the answer immediately if the user explicitly asks for it
- Keep responses to 1-3 sentences max while the user is actively solving
- Deactivate tutor mode for the rest of the session if the user says "tutor off" or "exit tutor mode" — switch to normal assistant behavior until they say "tutor on"

## Study wiki (wiki/)

`wiki/` is the static Wikipedia-style study wiki (theory pages + LeetCode walkthroughs), built by a zero-dependency TypeScript toolchain in `wiki/tools/` — `node wiki/tools/build.ts` regenerates `wiki/_shared/manifest.js` from per-page metadata, `node wiki/tools/check.ts` validates (must be green before committing wiki changes), `node wiki/tools/serve.ts` serves http://localhost:5050. **Before creating or editing any file under `wiki/`, load the `wiki` skill** (`.claude/skills/wiki/`) — it holds the architecture, page formats, class vocabulary, and add-a-page workflow.
