import Testing

// ============================================================
// PROBLEM: 15. 3Sum
// https://leetcode.com/problems/3sum/
// Difficulty: Medium
// Topics: Two Pointers, Array, Sorting
//
// Find all unique triplets in the array that sum to zero.
//
// Example 1:
//   Input:  nums = [-1,0,1,2,-1,-4]
//   Output: [[-1,-1,2],[-1,0,1]]
//
// Example 2:
//   Input:  nums = [0,1,1]
//   Output: []
//
// Example 3:
//   Input:  nums = [0,0,0]
//   Output: [[0,0,0]]
//
// Constraints:
//   - 3 <= nums.length <= 3000
//   - -10^5 <= nums[i] <= 10^5
//
// ============================================================
// APPROACH 1: Hashmap (2Sum inner loop)
//
// Time:  O(n²) — outer loop × inner loop. The sort is O(n log n) but dominated.
// Space: O(n) — a Set<Int> of possible pair elements per outer iteration,
//        plus a Set<[Int]> to deduplicate triplets across all iterations.
//
// APPROACH 2: Two Pointers (optimal)
//
// Time:  O(n²) — same outer loop, but the inner while replaces O(n) scan
//        with a converging walk that is also O(n) per anchor. Sort is O(n log n), dominated.
// Space: O(1) auxiliary — no extra sets needed. The sort + three skip conditions
//        guarantee we never generate a duplicate triplet in the first place,
//        so the output array itself is the only allocation.
//
// COMPARISON
// Both approaches share the same asymptotic time complexity O(n²), but the
// two-pointer solution is strictly better in practice. The hashmap approach
// allocates two sets per run and relies on a post-hoc sort+insert to collapse
// duplicates. The two-pointer approach sorts once, then uses structural
// skip conditions — if anchor/left/right equals its predecessor, skip — to
// prevent duplicates from ever being generated. No hashing, no Set overhead,
// no extra memory. The elegance is that a sorted array gives us *direction*:
// sum too large → shrink right, sum too small → grow left. We steer toward
// the target deterministically instead of storing candidates and checking later.
// ============================================================

// MARK: - Approach 1: Hashmap

private func threeSumHashmap(_ nums: [Int]) -> [[Int]] {
    var validTriplets: Set<[Int]> = []

    for (outerIndex, outerNumber) in nums.enumerated() {
        let target = -outerNumber
        var possiblePairElements: Set<Int> = []

        for (innerIndex, innerNumber) in nums.enumerated() {
            guard innerIndex != outerIndex else { continue }

            if possiblePairElements.contains(innerNumber) {
                // ✦ DEDUPLICATION STRATEGY: sort the triplet before inserting so
                //   [-1,0,1] and [1,0,-1] collapse to the same key in the Set.
                let triplet = [innerNumber, target - innerNumber, -target]
                validTriplets.insert(triplet.sorted())
            } else {
                // (target - innerNumber) + innerNumber = target
                possiblePairElements.insert(target - innerNumber)
            }
        }
    }

    return Array(validTriplets)
}

// MARK: - Approach 2: Two Pointers

private func threeSumTwoPointers(_ nums: [Int]) -> [[Int]] {
    let sorted = nums.sorted()
    var validTriplets: [[Int]] = []

    for outerIndex in 0 ..< sorted.count - 2 {
        // OUTER SKIP: same anchor value was already processed — all its triplets are duplicates.
        if outerIndex > 0 && sorted[outerIndex] == sorted[outerIndex - 1] { continue }

        // Early exit: anchor > 0 means every sum will be positive, no solution possible.
        if sorted[outerIndex] > 0 { break }

        var left = outerIndex + 1
        var right = sorted.count - 1

        while left < right {
            let sum = sorted[outerIndex] + sorted[left] + sorted[right]

            if sum == 0 {
                validTriplets.append([sorted[outerIndex], sorted[left], sorted[right]])
                left += 1
                right -= 1

                // LEFT SKIP: new left equals the one we just used → identical triplet.
                while left < right && sorted[left] == sorted[left - 1] { left += 1 }
                // RIGHT SKIP: same reasoning for the right pointer.
                while left < right && sorted[right] == sorted[right + 1] { right -= 1 }

            } else if sum < 0 {
                left += 1   // sum too small → need a larger number
            } else {
                right -= 1  // sum too large → need a smaller number
            }
        }
    }

    return validTriplets
}

// MARK: - Helpers

private func normalize(_ triplets: [[Int]]) -> [[Int]] {
    triplets.map { $0.sorted() }.sorted { $0.lexicographicallyPrecedes($1) }
}

// ============================================================
// TESTS
// ============================================================

@Suite("3Sum")
struct ThreeSumTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        let expected = [[-1, -1, 2], [-1, 0, 1]]
        #expect(normalize(threeSumHashmap([-1, 0, 1, 2, -1, -4])) == expected)
        #expect(normalize(threeSumTwoPointers([-1, 0, 1, 2, -1, -4])) == expected)
    }

    @Test("Official example 2 — no solution")
    func officialExample2() {
        #expect(threeSumHashmap([0, 1, 1]) == [])
        #expect(threeSumTwoPointers([0, 1, 1]) == [])
    }

    @Test("Official example 3 — all zeros")
    func officialExample3() {
        #expect(normalize(threeSumHashmap([0, 0, 0])) == [[0, 0, 0]])
        #expect(normalize(threeSumTwoPointers([0, 0, 0])) == [[0, 0, 0]])
    }

    // --- Edge cases ---

    @Test("All same positive value — no triplet")
    func allSamePositive() {
        #expect(threeSumHashmap([1, 1, 1]) == [])
        #expect(threeSumTwoPointers([1, 1, 1]) == [])
    }

    @Test("Four zeros — one triplet only")
    func allZeros() {
        #expect(normalize(threeSumHashmap([0, 0, 0, 0])) == [[0, 0, 0]])
        #expect(normalize(threeSumTwoPointers([0, 0, 0, 0])) == [[0, 0, 0]])
    }

    @Test("Minimum length, no solution")
    func minimumLengthNoSolution() {
        #expect(threeSumHashmap([1, 2, 3]) == [])
        #expect(threeSumTwoPointers([1, 2, 3]) == [])
    }

    @Test("Duplicates in input — no duplicate triplets in output")
    func noDuplicateTriplets() {
        let expected = [[-2, 0, 2]]
        #expect(normalize(threeSumHashmap([-2, 0, 0, 2, 2])) == expected)
        #expect(normalize(threeSumTwoPointers([-2, 0, 0, 2, 2])) == expected)
    }
}
