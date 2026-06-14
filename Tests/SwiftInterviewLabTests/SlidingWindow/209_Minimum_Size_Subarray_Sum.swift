import Testing

// ============================================================
// PROBLEM: 209. Minimum Size Subarray Sum
// https://leetcode.com/problems/minimum-size-subarray-sum/
// Difficulty: Medium
// Topics: Array, Binary Search, Sliding Window, Prefix Sum
//
// Find the minimal length contiguous subarray whose sum is >= target;
// return 0 if no such subarray exists.
//
// Example 1:
//   Input:  target = 7, nums = [2,3,1,2,4,3]
//   Output: 2  (subarray [4,3])
//
// Example 2:
//   Input:  target = 4, nums = [1,4,4]
//   Output: 1
//
// Example 3:
//   Input:  target = 11, nums = [1,1,1,1,1,1,1,1]
//   Output: 0
//
// Constraints:
//   - 1 <= target <= 10^9
//   - 1 <= nums.length <= 10^5
//   - 1 <= nums[i] <= 10^4
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// O(n) ✓ — each element enters and leaves the window at most once
//
// Space Complexity:
// "O(1) auxiliary space — I hold four scalar variables regardless of input size."
// ============================================================

private func minSubArrayLen(_ target: Int, _ nums: [Int]) -> Int {
    var leftPointer = 0
    // GOTCHA: init with Int.max, not 0 — lets min() work correctly on the first valid window
    var minSubArrayLenght = Int.max
    var currentSum = 0

    for (rightPointer, rightNumber) in nums.enumerated() {
        currentSum += rightNumber

        // Shrink from the left while the window is valid; record at every valid size
        while currentSum >= target {
            minSubArrayLenght = min(minSubArrayLenght, rightPointer - leftPointer + 1)
            currentSum -= nums[leftPointer]
            leftPointer += 1
        }
    }

    // GOTCHA: no valid window found → return 0 instead of Int.max
    return minSubArrayLenght == Int.max ? 0 : minSubArrayLenght
}


// ============================================================
// TESTS
// ============================================================

@Suite("Minimum Size Subarray Sum")
struct _209_Minimum_Size_Subarray_SumTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(minSubArrayLen(7, [2, 3, 1, 2, 4, 3]) == 2)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(minSubArrayLen(4, [1, 4, 4]) == 1)
    }

    @Test("Official example 3")
    func officialExample3() {
        #expect(minSubArrayLen(11, [1, 1, 1, 1, 1, 1, 1, 1]) == 0)
    }

    // --- Edge cases ---

    @Test("Single element equal to target")
    func singleElementEqualsTarget() {
        #expect(minSubArrayLen(5, [5]) == 1)
    }

    @Test("Single element less than target")
    func singleElementBelowTarget() {
        #expect(minSubArrayLen(5, [3]) == 0)
    }

    @Test("Entire array needed")
    func entireArrayNeeded() {
        #expect(minSubArrayLen(15, [1, 2, 3, 4, 5]) == 5)
    }

    @Test("Answer at the very start")
    func answerAtStart() {
        #expect(minSubArrayLen(6, [6, 1, 1, 1, 1, 1]) == 1)
    }

    @Test("Answer at the very end")
    func answerAtEnd() {
        #expect(minSubArrayLen(6, [1, 1, 1, 1, 1, 6]) == 1)
    }

    @Test("All elements identical")
    func allIdentical() {
        #expect(minSubArrayLen(6, [2, 2, 2, 2, 2]) == 3)
    }
}
