import Testing

// ============================================================
// PROBLEM: Container Packing
// Difficulty: Medium
// Topics: Greedy, Sorting, Bin Packing
//
// Given n items with weights and a container capacity c, return the minimum
// number of containers needed to ship all items without exceeding capacity.
//
// Example 1:
//   Input:  n=5, c=10, weights=[2, 3, 8, 3, 5]
//   Output: 2  ([8,2] and [3,3,5])
//
// Example 2:
//   Input:  n=4, c=6, weights=[2, 5, 4, 4]
//   Output: 3  ([2,4], [4], [5])
//
// Constraints:
//   - 1 <= n <= 10,000
//   - 1 <= c <= 10,000
//   - 1 <= weight[i] <= c
//
// Performance expectation:
//   - O(n log n) time or better
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// TODO
//
// Space Complexity:
// TODO
// ============================================================

// TODO: implement 

//private func minContainers(_ weights: [Int], capacity c: Int) -> Int {
//    return 0
//}
//
//
//// ============================================================
//// TESTS
//// ============================================================
//
//@Suite("Container Packing")
//struct Container_PackingTests {
//
//    // --- Official examples ---
//
//    @Test("Official example 1")
//    func officialExample1() {
//        #expect(minContainers([2, 3, 8, 3, 5], capacity: 10) == 2)
//    }
//
//    @Test("Official example 2")
//    func officialExample2() {
//        #expect(minContainers([2, 5, 4, 4], capacity: 6) == 3)
//    }
//
//    // --- Edge cases ---
//
//    @Test("Single item")
//    func singleItem() {
//        #expect(minContainers([7], capacity: 10) == 1)
//    }
//
//    @Test("Each item fills exactly one container")
//    func allItemsExactCapacity() {
//        #expect(minContainers([5, 5, 5], capacity: 5) == 3)
//    }
//
//    @Test("All items fit in one container")
//    func allFitInOne() {
//        #expect(minContainers([1, 2, 3], capacity: 10) == 1)
//    }
//
//    @Test("Two items pair perfectly, one leftover")
//    func pairPlusLeftover() {
//        // [4,4] fill one container of capacity 8, [3] goes in second
//        #expect(minContainers([4, 4, 3], capacity: 8) == 2)
//    }
//
//    @Test("Items already sorted descending")
//    func sortedDescending() {
//        #expect(minContainers([9, 6, 5, 4, 1], capacity: 10) == 3)
//    }
//
//    @Test("All identical weights that pair up evenly")
//    func allIdentical() {
//        #expect(minContainers([3, 3, 3, 3], capacity: 6) == 2)
//    }
//}
