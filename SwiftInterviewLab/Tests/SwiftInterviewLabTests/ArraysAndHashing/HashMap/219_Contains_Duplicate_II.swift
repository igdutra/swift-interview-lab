import Testing

// ============================================================
// PROBLEM: 219. Contains Duplicate II
// https://leetcode.com/problems/contains-duplicate-ii/
// Difficulty: Easy
// Topics: Array, Hash Table, Sliding Window
//
// Return true if there exist two indices i and j such that
// nums[i] == nums[j] and abs(i - j) <= k.
//
// Example 1:
//   Input:  nums = [1,2,3,1], k = 3
//   Output: true
//
// Example 2:
//   Input:  nums = [1,0,1,1], k = 1
//   Output: true
//
// Example 3:
//   Input:  nums = [1,2,3,1,2,3], k = 2
//   Output: false
//
// Constraints:
//   - 1 <= nums.length <= 10^5
//   - -10^9 <= nums[i] <= 10^9
//   - 0 <= k <= 10^5
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) — single pass through the array
// Space Complexity: O(n) — hash map can hold up to n distinct entries
// ============================================================

private func containsNearbyDuplicate(_ nums: [Int], _ k: Int) -> Bool {
    var seenNumberIndexes: [Int: Int] = [:]

    for (currentIndex, number) in nums.enumerated() {
        if let lastSeenIndex = seenNumberIndexes[number],
           currentIndex - lastSeenIndex <= k {
            return true
        }
        seenNumberIndexes[number] = currentIndex
    }

    return false
}


// ============================================================
// TESTS
// ============================================================

@Suite("Contains Duplicate II")
struct Contains_Duplicate_IITests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(containsNearbyDuplicate([1, 2, 3, 1], 3) == true)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(containsNearbyDuplicate([1, 0, 1, 1], 1) == true)
    }

    @Test("Official example 3")
    func officialExample3() {
        #expect(containsNearbyDuplicate([1, 2, 3, 1, 2, 3], 2) == false)
    }

    // --- Edge cases ---

    @Test("Single element — no pair possible")
    func singleElement() {
        #expect(containsNearbyDuplicate([1], 0) == false)
    }

    @Test("k = 0 — indices must be equal, impossible for i != j")
    func kEqualsZero() {
        #expect(containsNearbyDuplicate([1, 1], 0) == false)
    }

    @Test("Duplicate exists but distance is exactly k + 1")
    func distanceJustOutsideWindow() {
        #expect(containsNearbyDuplicate([1, 2, 3, 4, 1], 3) == false)
    }

    @Test("Duplicate distance exactly equals k")
    func distanceExactlyK() {
        #expect(containsNearbyDuplicate([1, 2, 3, 4, 1], 4) == true)
    }

    @Test("All identical elements with large k")
    func allIdentical() {
        #expect(containsNearbyDuplicate([5, 5, 5, 5], 1) == true)
    }
}
