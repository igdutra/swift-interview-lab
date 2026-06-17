import Testing

// ============================================================
// PROBLEM: 217. Contains Duplicate
// https://leetcode.com/problems/contains-duplicate/
// Difficulty: Easy
// Topics: Array, Hash Table, Sorting
//
// Return true if any value appears at least twice in the array.
//
// Example 1:
//   Input:  nums = [1,2,3,1]
//   Output: true
//
// Example 2:
//   Input:  nums = [1,2,3,4]
//   Output: false
//
// Example 3:
//   Input:  nums = [1,1,1,3,3,4,3,2,4,2]
//   Output: true
//
// Constraints:
//   - 1 <= nums.length <= 10^5
//   - -10^9 <= nums[i] <= 10^9
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) — single pass; early exit on first duplicate
//
// Space Complexity: O(n) — seen set grows up to n elements
// ============================================================

private func hasDuplicates(in nums: [Int]) -> Bool {
    var seenNumbers: Set<Int> = []

    for number in nums {
        guard !seenNumbers.contains(number) else {
            return true
        }
        seenNumbers.insert(number)
    }

    return false
}


// ============================================================
// TESTS
// ============================================================

@Suite("Contains Duplicate")
struct Contains_DuplicateTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(hasDuplicates(in:[1, 2, 3, 1]) == true)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(hasDuplicates(in:[1, 2, 3, 4]) == false)
    }

    @Test("Official example 3")
    func officialExample3() {
        #expect(hasDuplicates(in:[1, 1, 1, 3, 3, 4, 3, 2, 4, 2]) == true)
    }

    // --- Edge cases ---

    @Test("Single element — no duplicate possible")
    func singleElement() {
        #expect(hasDuplicates(in:[42]) == false)
    }

    @Test("Two identical elements")
    func twoIdentical() {
        #expect(hasDuplicates(in:[7, 7]) == true)
    }

    @Test("Two distinct elements")
    func twoDistinct() {
        #expect(hasDuplicates(in:[1, 2]) == false)
    }

    @Test("All identical elements")
    func allIdentical() {
        #expect(hasDuplicates(in:[5, 5, 5, 5, 5]) == true)
    }

    @Test("Duplicate at very end")
    func duplicateAtEnd() {
        #expect(hasDuplicates(in:[1, 2, 3, 4, 5, 1]) == true)
    }
}
