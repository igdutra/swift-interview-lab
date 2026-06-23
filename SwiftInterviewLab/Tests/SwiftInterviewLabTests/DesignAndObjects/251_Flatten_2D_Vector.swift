import Testing

// ============================================================
// PROBLEM: 251. Flatten 2D Vector
// https://leetcode.com/problems/flatten-2d-vector/
// Difficulty: Medium
// Topics: Array, Design, Two Pointers, Iterator
//
// Design an iterator over a 2D integer array that yields
// one integer at a time in row-major order via next() and
// hasNext(), silently skipping any empty inner arrays.
//
// Example 1:
//   Input:  vec = [[1,2],[3],[4]]
//   Output: [1,2,3,4]
//
// Example 2:
//   Input:  vec = [[1,2,3],[4,5,6]]
//   Output: [1,2,3,4,5,6]
//
// Constraints:
//   - 0 <= vec.length <= 200
//   - 0 <= vec[i].length <= 500
//   - -500 <= vec[i][j] <= 500
//   - At most 10^5 calls will be made to next and hasNext.
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS.
//
// Time Complexity:  O(1) amortized per next() / hasNext() call.
//                   Each element is visited exactly once across all calls.
//                   A call may skip several empty rows, but those rows are
//                   never revisited — amortized over N total elements, O(1).
//
// Space Complexity: O(1) extra — only two integer indices are stored.
//                   No copy of the input data is made.
// ============================================================

// ============================================================
// SOLUTION
// ============================================================

private class Vector2D {
    var innerIndex: Int = 0
    var outerIndex: Int = 0
    let vector: [[Int]]

    init(_ vec: [[Int]]) {
        self.vector = vec
    }

    // outerIndex - advance and check at every call
    // innerIndex - advance on next, when subitem is exhausted

    // idempotency - must be safe to be called multiple times
    private func advanceToNextSubitem() {
        // Both conditions must hold to stay in the loop:
        //   outerIndex < vector.count       — still rows left
        //   innerIndex >= vector[outerIndex].count  — current row exhausted
        //
        // NOTE: >= (not >) is required. When innerIndex == count the row is
        // exactly exhausted; > would let next() try to read that out-of-bounds
        // index before the loop fires, causing a crash.
        while outerIndex < vector.count, innerIndex >= vector[outerIndex].count {
            outerIndex += 1
            innerIndex = 0
        }
    }

    func next() -> Int {
        advanceToNextSubitem()
        let next = vector[outerIndex][innerIndex]
        innerIndex += 1
        return next
    }

    func hasNext() -> Bool {
        advanceToNextSubitem()
        return outerIndex < vector.count
    }
}

// ============================================================
// YOUR POINTER VERSION (playground attempt)
// ============================================================

private class Vector2DPointer {
    var input: [[Int]]
    var outerIndex: Int = 0
    var innerIndex: Int = 0

    init(_ vec: [[Int]]) {
        self.input = vec
        advanceToNextVector()
    }

    func hasNext() -> Bool {
        advanceToNextVector()
        // fix: only check outerIndex - when outerIndex overflows that is the indication of exhaustion
        return outerIndex < input.count
    }

    func next() -> Int? {
        advanceToNextVector()
        guard outerIndex < input.count else { return nil }
        let value = input[outerIndex][innerIndex]
        innerIndex += 1
        return value
    }

    private func advanceToNextVector() {
        // fix: only check outerIndex - when outerIndex overflows that is the indication of exhaustion
        while outerIndex < input.count, innerIndex >= input[outerIndex].count {
            outerIndex += 1
            innerIndex = 0
        }
    }
}

// ============================================================
// SOLUTION 2 — Stack-based (your approach)
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS.
//
// Time Complexity:  O(1) amortized per next() / hasNext() call.
//                   Each element is loaded into the stack exactly once.
//
// Space Complexity: O(S) where S is the size of the largest inner array,
//                   since we load one inner array at a time into the stack.
//                   O(N) worst case if one row holds all elements.
// ============================================================

private class Vector2DStack {
    var input: [[Int]]
    var stack: [Int] = []

    init(_ vec: [[Int]]) {
        self.input = vec.reversed()
        advanceToNextVector()
    }

    func hasNext() -> Bool {
        advanceToNextVector()
        return !stack.isEmpty
    }

    func next() -> Int {
        advanceToNextVector()
        return stack.popLast()!
    }

    private func advanceToNextVector() {
        while !input.isEmpty && stack.isEmpty {
            if let popped = input.popLast(), !popped.isEmpty {
                stack.append(contentsOf: popped.reversed())
            }
        }
    }
}

// ============================================================
// HELPERS
// ============================================================

private func drain(_ it: Vector2D) -> [Int] {
    var result: [Int] = []
    while it.hasNext() { result.append(it.next()) }
    return result
}

private func drainStack(_ it: Vector2DStack) -> [Int] {
    var result: [Int] = []
    while it.hasNext() { result.append(it.next()) }
    return result
}

// ============================================================
// TESTS
// ============================================================

@Suite("Flatten 2D Vector")
struct _251_Flatten_2D_VectorTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(drain(Vector2D([[1,2],[3],[4]])) == [1,2,3,4])
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(drain(Vector2D([[1,2,3],[4,5,6]])) == [1,2,3,4,5,6])
    }

    // --- Edge cases ---

    @Test("Single element")
    func singleElement() {
        #expect(drain(Vector2D([[42]])) == [42])
    }

    @Test("Empty inner arrays are skipped")
    func emptyInnerArrays() {
        // [[1,2],[],[3]]
        #expect(drain(Vector2D([[1,2],[],[3]])) == [1,2,3])
    }

    @Test("Multiple consecutive empty inner arrays")
    func multipleEmptyRows() {
        // [[],[],[1]]
        #expect(drain(Vector2D([[],[],[1]])) == [1])
    }

    @Test("All inner arrays empty")
    func allEmpty() {
        let it = Vector2D([[],[],[]])
        #expect(it.hasNext() == false)
        #expect(drain(it) == [])
    }

    @Test("Empty outer array")
    func emptyOuter() {
        let it = Vector2D([])
        #expect(it.hasNext() == false)
        #expect(drain(it) == [])
    }

    @Test("hasNext is idempotent — multiple consecutive calls do not advance")
    func hasNextIdempotent() {
        let it = Vector2D([[1,2],[3]])
        #expect(it.hasNext() == true)
        #expect(it.hasNext() == true)   // must not advance the cursor
        #expect(it.next() == 1)
        #expect(it.hasNext() == true)
        #expect(it.next() == 2)
        #expect(it.next() == 3)
        #expect(it.hasNext() == false)
    }

    @Test("Negative integers")
    func negativeIntegers() {
        #expect(drain(Vector2D([[-1,-2],[-3]])) == [-1,-2,-3])
    }
}

@Suite("Flatten 2D Vector — Stack (your solution)")
struct _251_StackTests {

    @Test("Official example 1")
    func officialExample1() {
        #expect(drainStack(Vector2DStack([[1,2],[3],[4]])) == [1,2,3,4])
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(drainStack(Vector2DStack([[1,2,3],[4,5,6]])) == [1,2,3,4,5,6])
    }

    @Test("Single element")
    func singleElement() {
        #expect(drainStack(Vector2DStack([[42]])) == [42])
    }

    @Test("Empty inner arrays are skipped")
    func emptyInnerArrays() {
        #expect(drainStack(Vector2DStack([[1,2],[],[3]])) == [1,2,3])
    }

    @Test("Multiple consecutive empty inner arrays")
    func multipleEmptyRows() {
        #expect(drainStack(Vector2DStack([[],[],[1]])) == [1])
    }

    @Test("All inner arrays empty")
    func allEmpty() {
        let it = Vector2DStack([[],[],[]])
        #expect(it.hasNext() == false)
        #expect(drainStack(it) == [])
    }

    @Test("Empty outer array")
    func emptyOuter() {
        let it = Vector2DStack([])
        #expect(it.hasNext() == false)
        #expect(drainStack(it) == [])
    }

    @Test("hasNext is idempotent")
    func hasNextIdempotent() {
        let it = Vector2DStack([[1,2],[3]])
        #expect(it.hasNext() == true)
        #expect(it.hasNext() == true)
        #expect(it.next() == 1)
        #expect(it.hasNext() == true)
        #expect(it.next() == 2)
        #expect(it.next() == 3)
        #expect(it.hasNext() == false)
    }

    @Test("Negative integers")
    func negativeIntegers() {
        #expect(drainStack(Vector2DStack([[-1,-2],[-3]])) == [-1,-2,-3])
    }
}

@Suite("Flatten 2D Vector — Your Pointer Version")
struct _251_YourPointerTests {

    @Test("Official example 1")
    func officialExample1() {
        let it = Vector2DPointer([[1,2],[3],[4]])
        var result: [Int] = []
        while it.hasNext() { if let val = it.next() { result.append(val) } }
        #expect(result == [1,2,3,4])
    }

    @Test("Empty outer array — crashes without guard")
    func emptyOuter() {
        let it = Vector2DPointer([])
        #expect(it.hasNext() == false)
    }

    @Test("All inner arrays empty")
    func allEmpty() {
        let it = Vector2DPointer([[],[],[]])
        #expect(it.hasNext() == false)
    }
}
