import Testing

// ============================================================
// PROBLEM: 1. Two Sum
// https://leetcode.com/problems/two-sum/
// Difficulty: Easy
// Topics: Array, Hash Table
//
// Return the indices of the two numbers that add up to target.
//
// Example 1:
//   Input:  nums = [2,7,11,15], target = 9
//   Output: [0,1]
//
// Example 2:
//   Input:  nums = [3,2,4], target = 6
//   Output: [1,2]
//
// Example 3:
//   Input:  nums = [3,3], target = 6
//   Output: [0,1]
//
// Constraints:
//   - 2 <= nums.length <= 10^4
//   - -10^9 <= nums[i] <= 10^9
//   - -10^9 <= target <= 10^9
//   - Only one valid answer exists.
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) — single pass through the array
//
// Space Complexity: O(n) — complement map grows up to n entries
// ============================================================

private func findPair(in nums: [Int], thatSums target: Int) -> [Int] {
    var complementaryMap: [Int: Int] = [:]
    var pair: [Int] = [] // Return empty case none is found
    
    for (currentIndex, num) in nums.enumerated() {
        if let firstIndex = complementaryMap[num] {
            pair = [firstIndex, currentIndex] // Could be easier to read, early return is optimized.
        } else {
            let complement = target - num
            complementaryMap[complement] = currentIndex
        }
    }
    
    return pair
}


// ============================================================
// TESTS
// ============================================================

@Suite("Two Sum")
struct Two_SumTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(findPair(in: [2, 7, 11, 15], thatSums: 9) == [0, 1])
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(findPair(in: [3, 2, 4], thatSums: 6) == [1, 2])
    }

    @Test("Official example 3")
    func officialExample3() {
        #expect(findPair(in: [3, 3], thatSums: 6) == [0, 1])
    }

    // --- Edge cases ---

    @Test("Answer at the very end of the array")
    func answerAtEnd() {
        #expect(findPair(in: [1, 2, 3, 4, 5], thatSums: 9) == [3, 4])
    }

    @Test("Negative numbers summing to target")
    func negativeNumbers() {
        #expect(findPair(in: [-3, 4, 3, 90], thatSums: 0) == [0, 2])
    }

    @Test("Target requires using element with itself — but same index not allowed")
    func complementIsNotSelf() {
        // 6 is at index 0; its complement 0 is at index 2 — different indices, valid
        #expect(findPair(in: [6, 1, 0], thatSums: 6) == [0, 2])
    }

    @Test("Large negative target")
    func largeNegativeTarget() {
        #expect(findPair(in: [-1_000_000_000, -999_999_999, 0], thatSums: -1_999_999_999) == [0, 1])
    }
}
