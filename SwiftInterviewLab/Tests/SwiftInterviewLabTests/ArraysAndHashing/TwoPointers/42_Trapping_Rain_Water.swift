import Testing

// ============================================================
// PROBLEM: 42. Trapping Rain Water
// https://leetcode.com/problems/trapping-rain-water/
// Difficulty: Hard
// Topics: Two Pointers, Array, Dynamic Programming, Stack, Monotonic Stack
//
// Given an elevation map as an array of bar heights, compute
// how much rainwater can be trapped between the bars.
//
// Example 1:
//   Input:  height = [0,1,0,2,1,0,1,3,2,1,2,1]
//   Output: 6
//
// Example 2:
//   Input:  height = [4,2,0,3,2,5]
//   Output: 9
//
// Constraints:
//   - n == height.length
//   - 1 <= n <= 2 * 10^4
//   - 0 <= height[i] <= 10^5
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) — single pass, each bar visited at most once.
// Space Complexity: O(1) — only four scalar variables, no extra arrays.
// ============================================================

private func trap(_ height: [Int]) -> Int {
    var leftPointer = 0
    var rightPointer = height.count - 1
    // Seed the walls with the outermost bars — they can never trap water themselves.
    var maxWallLeft = height[leftPointer]
    var maxWallRight = height[rightPointer]
    var totalWater = 0

    while leftPointer < rightPointer {
        if maxWallLeft < maxWallRight {
            // Left wall is the bottleneck — safe to commit water here.
            // maxWallRight is already taller, so water can't leak right.
            leftPointer += 1
            maxWallLeft = max(maxWallLeft, height[leftPointer])
            let waterTrapped = maxWallLeft - height[leftPointer]
            totalWater += waterTrapped
        } else {
            // Right wall is the bottleneck — safe to commit water here.
            // maxWallLeft is already taller, so water can't leak left.
            rightPointer -= 1
            maxWallRight = max(maxWallRight, height[rightPointer])
            let waterTrapped = maxWallRight - height[rightPointer]
            totalWater += waterTrapped
        }
    }

    return totalWater
}


// ============================================================
// TESTS
// ============================================================

@Suite("Trapping Rain Water")
struct Trapping_Rain_WaterTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(trap([0,1,0,2,1,0,1,3,2,1,2,1]) == 6)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(trap([4,2,0,3,2,5]) == 9)
    }

    // --- Edge cases ---

    @Test("Single bar — no water possible")
    func singleBar() {
        #expect(trap([5]) == 0)
    }

    @Test("Two bars — no water possible")
    func twoBars() {
        #expect(trap([3,4]) == 0)
    }

    @Test("Flat terrain — no water")
    func flat() {
        #expect(trap([3,3,3,3]) == 0)
    }

    @Test("All zeros — no water")
    func allZeros() {
        #expect(trap([0,0,0,0]) == 0)
    }

    @Test("Valley shape — water in middle")
    func valley() {
        #expect(trap([3,0,3]) == 3)
    }

    @Test("Strictly increasing — no water")
    func strictlyIncreasing() {
        #expect(trap([1,2,3,4,5]) == 0)
    }

    @Test("Strictly decreasing — no water")
    func strictlyDecreasing() {
        #expect(trap([5,4,3,2,1]) == 0)
    }
}
