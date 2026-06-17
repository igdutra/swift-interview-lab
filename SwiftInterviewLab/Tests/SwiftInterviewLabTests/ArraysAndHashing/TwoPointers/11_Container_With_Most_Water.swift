import Testing

// ============================================================
// PROBLEM: 11. Container With Most Water
// https://leetcode.com/problems/container-with-most-water/
// Difficulty: Medium
// Topics: Two Pointers, Array, Greedy
//
// Given heights of n vertical lines, find the two lines that
// form a container holding the most water.
//
// Example 1:
//   Input:  height = [1,8,6,2,5,4,8,3,7]
//   Output: 49
//
// Example 2:
//   Input:  height = [1,1]
//   Output: 1
//
// Constraints:
//   - n == height.length
//   - 2 <= n <= 10^5
//   - 0 <= height[i] <= 10^4
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// O(n) — left and right pointers share a budget of exactly n-1 total steps;
//         each step advances one pointer inward by 1, so the loop runs n-1 times.
//
// Space Complexity:
// O(1) — only a fixed set of scalar variables; no auxiliary data structures.
// ============================================================

private func maxArea(_ height: [Int]) -> Int {
    var leftPointer  = 0
    var rightPointer = height.count - 1
    var maxWater     = 0

    while leftPointer < rightPointer {
        let width        = rightPointer - leftPointer
        let shorterWall  = min(height[leftPointer], height[rightPointer])
        maxWater = max(maxWater, width * shorterWall)

        // Advance the shorter wall — the only move that can improve area
        if height[leftPointer] <= height[rightPointer] {
            leftPointer  += 1
        } else {
            rightPointer -= 1
        }
    }

    return maxWater
}


// ============================================================
// TESTS
// ============================================================

@Suite("Container With Most Water")
struct Container_With_Most_WaterTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(maxArea([1,8,6,2,5,4,8,3,7]) == 49)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(maxArea([1,1]) == 1)
    }

    // --- Edge cases ---

    @Test("Two elements, different heights")
    func twoElementsDifferent() {
        #expect(maxArea([4,1]) == 1)
    }

    @Test("Increasing heights — answer at right boundary")
    func increasing() {
        #expect(maxArea([1,2,3,4,5]) == 6)
    }

    @Test("Decreasing heights — answer at left boundary")
    func decreasing() {
        #expect(maxArea([5,4,3,2,1]) == 6)
    }

    @Test("Tall walls at both ends with short wall in middle")
    func tallEndsShortMiddle() {
        #expect(maxArea([10,1,10]) == 20)
    }

    @Test("All same height")
    func allSame() {
        #expect(maxArea([3,3,3,3]) == 9)
    }
}
