# PLAN COMMENT STANDARD

The canonical structure for the `/* PLAN */` block that opens every playground
source file in `Sources/`. This is the spoken plan you would deliver in a real
interview — write it as if narrating out loud before touching any code.

Companion to `WALKTHROUGH_MASTERFILE_STANDARD.md` §6b, which mirrors this
structure in wiki walkthroughs. Both must stay in sync.

---

## Why this structure

Industry consensus (Tech Interview Handbook, AlgoMonster, Google/FB prep guides)
is clear: candidates who plan verbally before coding outperform those who jump
straight to implementation — 90% of interviewees skip this step and are penalized
for poor communication. The structure below maps to what top performers actually
do, with one addition: a Sequence step that draws the algorithm before naming
any variable. That ordering — algorithm first, state second, code third — is what
prevents the most common failure mode: choosing data structures before
understanding what the problem actually requires.

---

## The six pillars (in strict order)

```
/* PLAN

 QUESTIONS
 - (clarifications you'd ask before touching anything)

 1. PATTERN
    Name the technique + one-sentence justification.
    "token-based parser — for + if because each character drives one decision"

 2. SEQUENCE
    Draw the algorithm as a mini prose trace: walk the happy path step by step
    before naming any variable. Conditions and state will surface from this.
    - strip leading ?
    - loop characters, accumulate into key or value
    - on = : commit to key, start value
    - on & or string end: commit key+value to map, reset

 3. STATE
    Every variable, its type, and why it exists (derived from the sequence).
    - currentKey: [Character]
    - currentValue: [Character]
    - hasSeenEqual: Bool
    - outputMap: [String: [String]]

 4. CONDITIONS / LOOPS
    Pseudocode-level skeleton: the loop, every branch, every commit point.
    - for each (index, char):
        - if ? → skip
        - if = → hasSeenEqual ? append to value : set true
        - else → hasSeenEqual ? append to value : append to key
        - if & || last index → commit (handle empty value edge case)

 5. WALK
    Trace one or two concrete inputs through YOUR step-4 conditions.
    Goal: catch wrong branch ordering before writing real code — not just
    verify the expected output.
    - "?theme=dark&view=compact" → ...
    - "empty=" → ...

 6. EDGE CASES
    One-liner per case. Mark ✓ after the Walk confirms it is handled.
    - empty string → ✓
    - no leading ? → ✓
    - value is empty string (name=) → ✓
    - multiple = in token (fast=beta) → ✓

*/
```

---

## Rules

**Sequence before State before Conditions.** The sequence reveals what needs
tracking; State names it; Conditions codify it. Jumping to data structures or
pseudocode before writing the sequence skips the reasoning and causes weak plans.

**Walk traces conditions, not outputs.** The Walk is a bug-catch pass through
your step-4 branch logic — not just a mental check that the output looks right.
The value of the Walk is catching wrong branch ordering (e.g. checking
`hasSeenEqual` before checking `is &`) before writing a single line of Swift.

**Pattern is one sentence.** Not just a label ("sliding window") but a
justification ("sliding window — the window grows until invalid, then shrinks
from the left, so we avoid recomputing from scratch each time").

**QUESTIONS comes before the numbers.** Clarifying questions go at the top,
before any analysis — because the answers can change the entire plan.

---

## What a weak plan looks like (avoid)

```
/* PLAN
 - use a dictionary
 - split on &
 - handle edge cases
*/
```

No pattern justification. No sequence. No state derivation. No condition
skeleton. No walk. This is a list of outputs, not a plan — it does not survive
contact with "what if the value contains `=`?"

---

## Sources

- [How to Use Pseudocode Effectively in Technical Interviews — AlgoCademy](https://algocademy.com/blog/how-to-use-pseudocode-effectively-in-technical-interviews-a-comprehensive-guide/)
- [Mastering Pseudocode in Coding Interviews — asierr.dev](https://medium.com/@asierr/mastering-pseudocode-in-coding-interviews-a-strategic-approach-95305f187a72)
- [Ace the Coding Interview: Google and Facebook, twice — Matthew Leong](https://mjbleong.medium.com/ace-the-coding-interview-how-i-got-offers-at-google-and-facebook-twice-d5083fcca17d)
- [Tech Interview Handbook — Coding Interview Study Plan](https://www.techinterviewhandbook.org/coding-interview-study-plan/)
- Companion: [`WALKTHROUGH_MASTERFILE_STANDARD.md`](./WALKTHROUGH_MASTERFILE_STANDARD.md) §6b
