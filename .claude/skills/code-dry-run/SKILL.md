---
name: code-dry-run
description: Produces a detailed, step-by-step code execution trace in formatted plain text. ONLY activate when the user explicitly types the slash command `/code-dry-run`. NEVER trigger on demand, automatically, or based on intent alone — the slash command is mandatory. Do not trigger for general code explanation requests or LeetCode problem setup (/leetcode handles that).
---

# /code-dry-run

Walks through code execution step by step — like a debugger in your head — outputting a structured plain-text trace that shows exactly what happens at runtime.

## Activation

**Strict slash-command only: `/code-dry-run`**
Never trigger this skill automatically or proactively. It must be explicitly invoked.

The user will provide:
- The code (Swift, or other language)
- An input / test case to trace

Optional context: LeetCode problem number, class/function name, language.

---

## Output Format

Output as a single fenced code block (` ```text `) — never HTML, never interactive, never markdown outside the block.

Follow this structure closely:

```
────────────────────────────────
/code-dry-run
Problem: <problem name or number if known, else omit>
Input: <the exact input provided>
────────────────────────────────

<CLASS / FUNCTION NAME>
  <variable>  = <initial value>
  <variable>  = <initial value>

────────────────────────────────
<LOOP / STEP HEADER — describe what's being evaluated>
────────────────────────────────

  <action taken>
    <variable>  = <new value>
    <variable>  = <new value>

  <condition check>? YES/NO → <branch taken>
    <sub-action>
    <variable>  = <new value>

  ↑ <optional inline note explaining a non-obvious behavior>

  <state snapshot>
    <variable>  = <current value>

────────────────────────────────
<NEXT LOOP / STEP HEADER>
────────────────────────────────

  ...

────────────────────────────────
RESULT
────────────────────────────────

<final output / return values>
<public API calls with results if applicable>
```

---

## Formatting Rules

- **Section dividers**: `────────────────────────────────` (32 dashes) separating every major step/iteration.
- **Loop headers**: State what the loop/condition is evaluating, and whether it enters or exits. Example:
  ```
  while !workStack.isEmpty  → [2,3], []  → NOT empty → enter
  ```
- **Variable alignment**: Align `=` signs within a block for readability.
- **Inline annotations**: Use `↑` for short explanatory notes about non-obvious behavior (e.g. why an empty list is skipped, why reversed() is needed).
- **State snapshots**: After each iteration or major step, show the current value of key variables.
- **Condition checks**: Show the check, result (YES/NO), and branch taken on one line.
- **No prose outside the code block** — the entire trace goes inside ` ```text `.
- A brief one-liner before the block is fine (e.g. "Here's the dry run for input `[[1], [], [2,3]]`:")

---

## Depth Guidelines

- Trace **every iteration** of loops (one exception: the repeat cap below).
- Show **every variable mutation** as it happens.
- For collections (arrays, stacks, queues): show the full state after each mutation.
- For recursive calls: indent each level clearly.
- Empty collections or no-ops: trace them explicitly and annotate with `↑` why nothing happened.
- At the end, show the **public API usage** (e.g. `hasNext()` / `next()` calls) if the problem has one.

---

## Repeat Cap — compressing gotcha-free iterations

When **3 or more consecutive iterations** are pure no-ops — same branches taken, no tracked-variable changes, nothing non-obvious — collapse them into ONE divider-fenced block instead of repeating yourself:

```
────────────────────────────────
right=6 … right=8   rightCharacters "O","D","E" — repeated no-op
────────────────────────────────

  EXPAND: none of "O","D","E" is in targetCounts → skip
  SHRINK? matchedCount(2) == 3? NO → skip
  … continue this until right=9: "B" is the next target character
```

Rules:

- Only compress a pattern whose **first occurrence was already traced in full**.
- The block header names the skipped range; the shared branch reasoning appears once; the block ends with an explicit `… continue this until <condition>` line stating what breaks the repetition.
- **Never** compress an iteration that mutates a tracked variable (counters, pointers, best-so-far), enters or exits an inner loop, or deserves a `↑` note.
- When in doubt, trace it fully — the cap exists to cut noise, not work.

---

## Language Notes

- Swift: use Swift syntax for types, method calls, optionals.
- The skill is language-agnostic — adapt variable notation to whatever language the user provides.

---

## Example Invocation

User types:
```
/code-dry-run

Input: [[1], [], [2,3]]

class NestedIteratorEager { ... }
```

Claude outputs a single ```text block with the full execution trace.
