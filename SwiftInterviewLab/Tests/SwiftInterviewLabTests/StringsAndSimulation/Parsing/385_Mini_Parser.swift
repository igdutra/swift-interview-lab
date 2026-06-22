import Testing
import SwiftInterviewLab

// ============================================================
// PROBLEM: 385. Mini Parser
// https://leetcode.com/problems/mini-parser/
// Difficulty: Medium
// Topics: Stack, Depth-First Search, String
//
// Given a string s representing a serialization of a nested
// list, parse and getNestedNumber it into a NestedInteger object.
//
// Example 1:
//   Input:  s = "324"
//   Output: 324
//
// Example 2:
//   Input:  s = "[123,[456,[789]]]"
//   Output: [123,[456,[789]]]
//
// Constraints:
//   - 1 <= s.length <= 5 * 10^4
//   - s consists of digits, square brackets "[]", negative sign '-', and commas ','
//   - s is the serialization of valid NestedInteger
//   - All the values in the range [-10^6, 10^6]
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time:  O(n) — single pass over the string
// Space: O(d) — stack depth equals max nesting depth
// ============================================================

private func getNestedNumber(_ s: String) -> NestedInteger {
    var currentNumber = 0
    var isNegative = false
    // guards against committing a phantom 0 into empty lists like []
    // currentNumber == 0 alone can't distinguish "nothing accumulated" from the literal value 0
    var hasSeenNumber = false
    // start empty — pre-seeding with a result object caused plain numbers ("324") to be
    // wrapped inside a list instead of returned as integers
    var stack: [NestedInteger] = []

    for character in s {
        switch character {
        case "[":
            stack.append(NestedInteger())
        case ",":
            if hasSeenNumber {
                let value = isNegative ? -currentNumber : currentNumber
                stack[stack.count - 1].add(NestedInteger(value))
                currentNumber = 0; isNegative = false; hasSeenNumber = false
            }
        case "]":
            if hasSeenNumber {
                let value = isNegative ? -currentNumber : currentNumber
                stack[stack.count - 1].add(NestedInteger(value))
                currentNumber = 0; isNegative = false; hasSeenNumber = false
            }
            let popped = stack.removeLast()
            // stack empty means this was the outermost bracket — popped IS the answer
            if stack.isEmpty { return popped }
            stack[stack.count - 1].add(popped)
        case "-":
            isNegative = true
            hasSeenNumber = true
        default:
            if let digit = character.wholeNumberValue {
                currentNumber = currentNumber * 10 + digit
                hasSeenNumber = true
            }
        }
    }

    // reached only for plain number inputs with no brackets (e.g. "324", "-5")
    let value = isNegative ? -currentNumber : currentNumber
    return NestedInteger(value)
}


// ============================================================
// TESTS
// ============================================================

@Suite("Mini Parser")
struct MiniParserTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        let result = getNestedNumber("324")
        #expect(result.isInteger())
        #expect(result.getInteger() == 324)
    }

    @Test("Official example 2")
    func officialExample2() {
        let result = getNestedNumber("[123,[456,[789]]]")
        #expect(!result.isInteger())
        let list = result.getList()
        #expect(list.count == 2)
        #expect(list[0].isInteger())
        #expect(list[0].getInteger() == 123)
    }

    // --- Edge cases ---

    @Test("Empty list")
    func emptyList() {
        let result = getNestedNumber("[]")
        #expect(!result.isInteger())
        #expect(result.getList().isEmpty)
    }

    @Test("Single element list")
    func singleElementList() {
        let result = getNestedNumber("[1]")
        #expect(!result.isInteger())
        let list = result.getList()
        #expect(list.count == 1)
        #expect(list[0].getInteger() == 1)
    }

    @Test("Negative number")
    func negativeNumber() {
        let result = getNestedNumber("-5")
        #expect(result.isInteger())
        #expect(result.getInteger() == -5)
    }

    @Test("List with negative numbers")
    func listWithNegatives() {
        let result = getNestedNumber("[-1,2,-3]")
        #expect(!result.isInteger())
        let list = result.getList()
        #expect(list.count == 3)
        #expect(list[0].getInteger() == -1)
        #expect(list[1].getInteger() == 2)
        #expect(list[2].getInteger() == -3)
    }
}
