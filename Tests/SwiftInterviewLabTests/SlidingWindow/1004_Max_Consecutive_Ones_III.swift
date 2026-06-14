import Testing

// ============================================================
// PROBLEM: 1004. Max Consecutive Ones III
// https://leetcode.com/problems/max-consecutive-ones-iii/
// Difficulty: Medium
// Topics: Array, Binary Search, Sliding Window, Prefix Sum
//
// Find the maximum number of consecutive 1s in a binary array
// if you can flip at most k 0s to 1s.
//
// Example 1:
//   Input:  nums = [1,1,1,0,0,0,1,1,1,1,0], k = 2
//   Output: 6
//
// Example 2:
//   Input:  nums = [0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], k = 3
//   Output: 10
//
// Constraints:
//   - 1 <= nums.length <= 10^5
//   - nums[i] is either 0 or 1
//   - 0 <= k <= nums.length
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// O(n)
//
// Space Complexity:
// O(1) - only maxConsecutives, flippedCount
// ============================================================

private func findConsecutiveOnes(in nums: [Int], with k: Int) -> Int {
    var leftPointer = 0
    var currentReplacementCount = 0
    var maxReplacementCount = 0
    
    for (rightPointer, num) in nums.enumerated() {
        // guard num == 0 else { continue }
        // currentReplacementCount += 1
        // Bug: skips maxReplacementCount update when num == 1; window size must be recorded on every step.
        if num == 0 {
            currentReplacementCount += 1
        }
        
        while currentReplacementCount > k {
            let leftNumber = nums[leftPointer]
            if leftNumber == 0 {
                currentReplacementCount -= 1
            }
            leftPointer += 1
        }
        
        maxReplacementCount = max(maxReplacementCount, rightPointer - leftPointer + 1)
    }
    
    return maxReplacementCount
}


// ============================================================
// TESTS
// ============================================================

@Suite("Max Consecutive Ones III")
struct _1004_Max_Consecutive_Ones_IIITests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(findConsecutiveOnes(in: [1,1,1,0,0,0,1,1,1,1,0], with: 2) == 6)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(findConsecutiveOnes(in: [0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], with: 3) == 10)
    }

    // --- Edge cases ---

    @Test("All ones, k = 0 — entire array is the answer")
    func allOnesNoFlips() {
        #expect(findConsecutiveOnes(in: [1,1,1,1,1], with: 0) == 5)
    }

    @Test("All zeros, k equals length — entire array is the answer")
    func allZerosFlipAll() {
        #expect(findConsecutiveOnes(in: [0,0,0,0], with: 4) == 4)
    }

    @Test("k = 0, no flips allowed — longest existing run of 1s")
    func noFlipsAllowed() {
        #expect(findConsecutiveOnes(in: [1,0,1,1,0,1], with: 0) == 2)
    }

    @Test("Single element 0 with k = 1")
    func singleZeroFlipped() {
        #expect(findConsecutiveOnes(in: [0], with: 1) == 1)
    }

    @Test("Single element 1 with k = 0")
    func singleOne() {
        #expect(findConsecutiveOnes(in: [1], with: 0) == 1)
    }

    @Test("k larger than number of zeros — flip all zeros")
    func kExceedsZeroCount() {
        #expect(findConsecutiveOnes(in: [1,0,1,0,1], with: 5) == 5)
    }
}
