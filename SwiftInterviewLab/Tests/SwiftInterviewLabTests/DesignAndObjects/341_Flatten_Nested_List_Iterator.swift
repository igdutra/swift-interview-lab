import Testing
import SwiftInterviewLab // imports NestedInteger

// ============================================================
// PROBLEM: 341. Flatten Nested List Iterator
// https://leetcode.com/problems/flatten-nested-list-iterator/
// Difficulty: Medium
// Topics: Stack, Tree, Depth-First Search, Design, Queue, Iterator
//
// Design an iterator that flattens a nested list of integers
// (each element is either an integer or a list of integers) and
// yields one integer at a time via next() and hasNext().
//
// Example 1:
//   Input:  nestedList = [[1,1],2,[1,1]]
//   Output: [1,1,2,1,1]
//
// Example 2:
//   Input:  nestedList = [1,[4,[6]]]
//   Output: [1,4,6]
//
// Constraints:
//   - 1 <= nestedList.length <= 500
//   - The values of the integers in the nested list are in the range [-10^6, 10^6]
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(1) amortized per next() / hasNext() call.
//                   Each element is pushed and popped from the stack exactly once
//                   across all calls. A single call may expand several nested lists,
//                   but those lists are never revisited — amortized over N total
//                   integers, each operation costs O(1).
//
//                   NOTE: worst-case per call is O(depth), where depth is the max
//                   nesting level — but amortized across all N integers it is O(1).
//
// Space Complexity: O(N) — the input is stored reversed in the stack up front.
// ============================================================

// ============================================================
// SOLUTION
// ============================================================

private final class NestedListIterator {
    var stack: [NestedInteger]

    init(_ input: NestedInteger) {
        stack = input.getList().reversed()
    }

    func hasNext() -> Bool {
        advanceToNextInteger()
        return !stack.isEmpty
    }

    @discardableResult
    func next() -> Int? {
        advanceToNextInteger()
        guard let next = stack.popLast() else { return nil }
        return next.getInteger()
    }

    // Idempotent: safe to call multiple times without side effects when
    // the top of the stack is already an integer.
    private func advanceToNextInteger() {
        while let last = stack.last, !last.isInteger() {
            let popped = stack.removeLast()
            for value in popped.getList().reversed() {
                stack.append(value)
            }
        }
    }
}

// ============================================================
// HELPERS
// ============================================================

private func drain(_ iterator: NestedListIterator) -> [Int] {
    var result: [Int] = []
    while iterator.hasNext() {
        if let value = iterator.next() { result.append(value) }
    }
    return result
}

// Builds: [1, [4, [6]]]
private func makeExample1() -> NestedInteger {
    let inner2 = NestedInteger()
    inner2.add(NestedInteger(6))

    let inner1 = NestedInteger()
    inner1.add(NestedInteger(4))
    inner1.add(inner2)

    let root = NestedInteger()
    root.add(NestedInteger(1))
    root.add(inner1)
    return root
}

// Builds: [[1,1], 2, [1,1]]
private func makeExample2() -> NestedInteger {
    let left = NestedInteger()
    left.add(NestedInteger(1))
    left.add(NestedInteger(1))

    let right = NestedInteger()
    right.add(NestedInteger(1))
    right.add(NestedInteger(1))

    let root = NestedInteger()
    root.add(left)
    root.add(NestedInteger(2))
    root.add(right)
    return root
}

// ============================================================
// TESTS
// ============================================================

@Suite("341. Flatten Nested List Iterator")
struct _341_FlattenNestedListIteratorTests {

    @Test("Official example 1 — [1,[4,[6]]] → [1,4,6]")
    func officialExample1() {
        #expect(drain(NestedListIterator(makeExample1())) == [1, 4, 6])
    }

    @Test("Official example 2 — [[1,1],2,[1,1]] → [1,1,2,1,1]")
    func officialExample2() {
        #expect(drain(NestedListIterator(makeExample2())) == [1, 1, 2, 1, 1])
    }

    @Test("Single integer at root level")
    func singleInteger() {
        let root = NestedInteger()
        root.add(NestedInteger(42))
        #expect(drain(NestedListIterator(root)) == [42])
    }

    @Test("Deeply nested single value — [[[7]]]")
    func deeplyNested() {
        let inner = NestedInteger()
        inner.add(NestedInteger(7))

        let mid = NestedInteger()
        mid.add(inner)

        let root = NestedInteger()
        root.add(mid)

        #expect(drain(NestedListIterator(root)) == [7])
    }

    @Test("Flat list — no nesting")
    func flatList() {
        let root = NestedInteger()
        root.add(NestedInteger(1))
        root.add(NestedInteger(2))
        root.add(NestedInteger(3))
        #expect(drain(NestedListIterator(root)) == [1, 2, 3])
    }

    @Test("Negative integers")
    func negativeIntegers() {
        let root = NestedInteger()
        root.add(NestedInteger(-1))
        let inner = NestedInteger()
        inner.add(NestedInteger(-2))
        root.add(inner)
        #expect(drain(NestedListIterator(root)) == [-1, -2])
    }

    @Test("hasNext is idempotent — multiple calls do not advance")
    func hasNextIdempotent() {
        let root = NestedInteger()
        root.add(NestedInteger(1))
        root.add(NestedInteger(2))

        let iterator = NestedListIterator(root)
        #expect(iterator.hasNext() == true)
        #expect(iterator.hasNext() == true)
        #expect(iterator.next() == 1)
        #expect(iterator.hasNext() == true)
        #expect(iterator.next() == 2)
        #expect(iterator.hasNext() == false)
    }

    @Test("Empty root list")
    func emptyRoot() {
        let root = NestedInteger()
        let iterator = NestedListIterator(root)
        #expect(iterator.hasNext() == false)
        #expect(iterator.next() == nil)
    }
}
