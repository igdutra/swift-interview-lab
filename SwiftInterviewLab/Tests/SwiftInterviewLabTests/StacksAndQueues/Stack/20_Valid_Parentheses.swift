import Testing

// ============================================================
// PROBLEM: 20. Valid Parentheses
// https://leetcode.com/problems/valid-parentheses/
// Difficulty: Easy
// Topics: String, Stack, Hash Map
// See also: Stack (LIFO) — most-recently-opened closes first
//
// Given a string `s` containing just the characters
// '(', ')', '{', '}', '[' and ']', determine if the input is valid.
//
// A string is valid when:
//   1. Open brackets are closed by the same type of bracket.
//   2. Open brackets are closed in the correct order.
//   3. Every close bracket has a matching open bracket of the same type.
//
// Example:
//   "()"     → true
//   "()[]{}" → true
//   "(]"     → false   (wrong type)
//   "([)]"   → false   (wrong order — ) tries to close [ )
//   "([])"   → true
//
// Constraints:
//   - 1 <= s.length <= 10^4
//   - s consists only of '()[]{}'
//
// ============================================================
// PATTERN: Stack (LIFO)
//
// Nesting is last-in-first-out: the most recently opened bracket
// must be the next one closed. Push every opener; on a closer, the
// top of the stack must be its matching opener — pop and compare.
// A closing-char → opening-char dictionary turns the "does it match?"
// question into one O(1) lookup instead of a branch per bracket type.
//
// Why no explicit empty-stack guard is needed: `popLast()` returns
// an Optional and yields `nil` on an empty stack. `nil == openerCharacter`
// is `false`, so a closer with nothing open falls straight into
// `return false` — the optional handles the edge case for us.
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) — one pass; each character is pushed and
//                   popped at most once, dictionary lookup is O(1).
// Space Complexity: O(n) — worst case "(((((" pushes every character
//                   onto the stack before any close arrives.
// ============================================================

private func isValid(_ string: String) -> Bool {
    var stack: [Character] = []
    let openerForCloser: [Character: Character] = [
        ")": "(",
        "}": "{",
        "]": "["
    ]

    for character in string {
        if let expectedOpener = openerForCloser[character] {
            // closing bracket — the top must be its matching opener
            guard stack.popLast() == expectedOpener else { return false }
        } else {
            // opening bracket — remember it for its future closer
            stack.append(character)
        }
    }

    // valid only if every opener was matched and closed
    return stack.isEmpty
}


// ============================================================
// TESTS
// ============================================================

@Suite("Valid Parentheses")
struct LC20ValidParenthesesTests {

    // --- Official LeetCode examples ---

    @Test("Simple matched pair")
    func simpleMatchedPair() {
        #expect(isValid("()") == true)
    }

    @Test("All three types in sequence")
    func allThreeTypesInSequence() {
        #expect(isValid("()[]{}") == true)
    }

    @Test("Wrong closing type")
    func wrongClosingType() {
        #expect(isValid("(]") == false)
    }

    @Test("Correctly nested")
    func correctlyNested() {
        #expect(isValid("([])") == true)
    }

    @Test("Interleaved — wrong order")
    func interleavedWrongOrder() {
        #expect(isValid("([)]") == false)
    }

    // --- Edge cases ---

    @Test("Single closer with nothing open")
    func singleCloserNothingOpen() {
        #expect(isValid(")") == false)
    }

    @Test("Single opener never closed")
    func singleOpenerNeverClosed() {
        #expect(isValid("(") == false)
    }

    @Test("Deeply nested, all matched")
    func deeplyNestedAllMatched() {
        #expect(isValid("(((((((((())))))))))") == true)
    }

    @Test("More closers than openers")
    func moreClosersThanOpeners() {
        #expect(isValid("())") == false)
    }
}
