---
name: leetcode
description: >
  Scaffolds a new LeetCode problem for this Swift repo: creates a single
  self-contained test file with the private solution stub, problem header,
  complexity analysis, and Swift Testing cases.
  Use this skill whenever the user types `/leetcode`, provides a LeetCode
  problem number, or pastes a leetcode.com URL and wants to start working on
  it. Even if the user just says "add problem 42" or "set up LeetCode 3 for
  me", trigger this skill.
---

# /leetcode — Scaffold a LeetCode Problem

Creates one self-contained file per problem. The private solution function,
problem description, complexity analysis, and all tests live together in the
test file. There is no separate source stub.

## Usage

```
/leetcode {problem_number}
/leetcode {full LeetCode URL}
```

## Project layout (this repo)

```
Tests/LeetCodeSwiftTests/{NUMBER}_{Slug}.swift   ← everything goes here
Sources/LeetCodeSwift/Helpers/                   ← shared types only (ListNode, TreeNode, …)
```

File naming uses **Pascal_Snake_Case** for the slug — each word is title-cased,
separated by underscores. The number is never zero-padded.

Examples:
- Problem 3  → `3_Longest_Substring_Without_Repeating_Characters.swift`
- Problem 42 → `42_Trapping_Rain_Water.swift`

---

## Step 1 — Fetch the problem

If given a number, construct:
`https://leetcode.com/problems/{slug}/`

Try `web_fetch`. LeetCode often blocks unauthenticated requests. If it fails
or returns a login wall, **tell the user immediately** and ask them to paste
the full problem text from their browser. Continue from Step 2 with the pasted
content — don't spin endlessly on retries.

Extract:
- Problem number → use as-is, no leading zeros (`3` → `3`)
- Full title (e.g. "Longest Substring Without Repeating Characters")
- Pascal_Snake_Case slug (`Longest_Substring_Without_Repeating_Characters`)
- Difficulty: Easy / Medium / Hard
- Canonical URL
- Topics/tags (e.g. Hash Table, String, Sliding Window)
- Swift function signature **exactly as LeetCode shows it**
- All example inputs + expected outputs (Example 1, 2, 3…)
- Constraints (read carefully — they drive edge case selection and complexity)

## Step 2 — Check for existing files

Path:
```
Tests/LeetCodeSwiftTests/{NUMBER}_{Slug}.swift
```

If the file exists, warn the user and **stop**. Never overwrite.

## Step 3 — Scaffold the complexity block

The complexity block is always scaffolded with `// TODO` — the user fills it in themselves after implementing the solution. Do not pre-fill the analysis.

## Step 4 — Create the file

```swift
import Testing

// ============================================================
// PROBLEM: {NUMBER}. {Full Problem Title}
// {canonical LeetCode URL}
// Difficulty: {Easy | Medium | Hard}
// Topics: {comma-separated tags}
//
// {One-sentence problem statement in your own words.}
//
// Example 1:
//   Input:  {verbatim input}
//   Output: {expected output}  ({optional note, e.g. "abc"})
//
// Example 2:
//   Input:  {verbatim input}
//   Output: {expected output}
//
// Example 3:
//   Input:  {verbatim input}
//   Output: {expected output}
//
// Constraints:
//   - {verbatim constraint}
//   - {verbatim constraint}
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// TODO
// 
// Space Complexity: 
// TODO
// ============================================================

private func {exactFunctionName}({exactParameters}) -> {returnType} {
    // TODO
}


// ============================================================
// TESTS
// ============================================================

@Suite("{Full Problem Title}")
struct {NUMBER}_{Slug}Tests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect({functionName}({input1}) == {expected1})
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect({functionName}({input2}) == {expected2})
    }

    // (add example 3 if the problem has one)

    // --- Edge cases ---

    @Test("{short plain description}")
    func {camelCaseName}() {
        #expect({functionName}({edgeInput}) == {edgeExpected})
    }

    // 2–5 more edge cases depending on complexity
}
```

Header rules:
- Problem description: one condensed sentence — not verbatim, not omitted.
- Examples: reproduce verbatim from LeetCode, multi-line `Input:` / `Output:` format.
- Constraints: copy verbatim, one per line with a leading `- `.
- Complexity lines are **always present** — never leave them as placeholders.
- `Time Complexity:` and `Space Complexity:` are aligned with two spaces after the colon so they line up visually.

Function rules:
- `private func`. Never wrap in a `Solution` class.
- Body is exactly `// TODO`. No hints, no approach notes, nothing else.

Test rules:
- No `@testable import` — the private function is in the same file.
- One `@Test` per official example, labeled exactly `"Official example N"`.
- Edge case labels are a short plain description — no `"Edge — "` prefix.
- Edge cases must follow from the constraints and problem structure — not random.

Good edge cases by pattern:
- Empty string / array (if constraints allow)
- Single element
- All identical elements (`"bbbbb"`, `[1,1,1,1]`)
- Two elements — distinct vs. identical
- Answer at the very start vs. the very end of input
- Non-ASCII / special characters (if constraints mention them)
- Overflow-prone inputs for sum/product problems
- The "trap" specific to the problem (e.g. `"abba"` for sliding window — left pointer must not regress)

Target: 3 official examples + 3–6 edge cases. Skip any edge case that duplicates an official example.

## Step 5 — Handle shared types

If the problem needs `ListNode`, `TreeNode`, or similar, check
`Sources/LeetCodeSwift/Helpers/` first. If the file exists, use it. If it's
missing, create it there with the standard LeetCode definition and mention it
in the summary.

## Step 6 — Confirm to the user

```
✅ {NUMBER}: {Title} ({Difficulty})

Created:
  Tests/LeetCodeSwiftTests/{NUMBER}_{Slug}.swift

Tests: {N} official examples + {M} edge cases

Next: implement {functionName}(...) in {NUMBER}_{Slug}.swift, then run:
  swift test --filter "{NUMBER}"
```

---

## Hard rules — never break these

- **Never implement the solution.** Body is always `// TODO`.
- **Never use a `Solution` class.** Always `private func`.
- **Never use XCTest.** Always Swift Testing (`@Suite`, `@Test`, `#expect`).
- **Never use `@testable import`.** The private function lives in the test file.
- **Never zero-pad problem numbers.** `3` stays `3`, not `0003`.
- **Always scaffold the complexity block** with `// TODO` — never pre-fill it; the user writes it after solving.

## Companion reference

- `references/plan-comments.md` — the canonical six-pillar `/* PLAN */` comment standard for `Sources/` playground files (Pattern → Sequence → State → Conditions → Walk → Edge cases). The wiki skill's walkthrough §5b spoken plan mirrors this structure; this file is the single source of truth for it.
