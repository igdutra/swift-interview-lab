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
//   Output: 3  ([8,2], [5,3], [3])
//   Note: the total weight is 21, so even a perfect packing needs at least
//         ceil(21 / 10) = 3 containers. (The originally stated output of 2
//         was impossible — 21 units cannot fit in two containers of cap 10.)
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
// WHY THIS IS GREEDY
//
// A greedy algorithm builds the answer one decision at a time, each time
// taking the choice that looks best locally and committing to it for good.
// It pays off when those local choices compose into a globally optimal whole.
//
// Bin packing is NP-hard to solve exactly, so in practice we lean on a greedy
// heuristic: First-Fit Decreasing. The intuition is to place the bulky items
// while we still have empty containers to receive them, then let the small
// items trickle into whatever gaps remain. So we sort the weights largest
// first and, for each item, drop it into the first container it still fits;
// only when none can hold it do we open a new container. Handling the big
// items first prevents the classic failure where a fat item arrives last and
// is forced to start a fresh, mostly empty container.
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity: O(n^2) — for each of n items we scan the open containers
//   (up to n of them) looking for the first that fits. Sorting is O(n log n),
//   so the linear scan per item dominates.
//
// Space Complexity: O(n) — in the worst case every item opens its own
//   container, so we track up to n remaining-capacity values.
// ============================================================

private func minimumContainersNeeded(_ weights: [Int], capacity containerCapacity: Int) -> Int {
    // Greedy heuristic: First-Fit Decreasing — place heavy items first.
    let weightsHeaviestFirst = weights.sorted(by: >)

    // Each entry is the remaining free space in one opened container.
    var remainingCapacityPerContainer: [Int] = []

    for itemWeight in weightsHeaviestFirst {
        var placedExisting = false

        for containerIndex in remainingCapacityPerContainer.indices {
            if remainingCapacityPerContainer[containerIndex] >= itemWeight {
                remainingCapacityPerContainer[containerIndex] -= itemWeight
                placedExisting = true
                break
            }
        }

        if !placedExisting {
            remainingCapacityPerContainer.append(containerCapacity - itemWeight)
        }
    }

    return remainingCapacityPerContainer.count
}


// ============================================================
// TESTS
// ============================================================

@Suite("Container Packing")
struct Container_PackingTests {

    // --- Official examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(minimumContainersNeeded([2, 3, 8, 3, 5], capacity: 10) == 3)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(minimumContainersNeeded([2, 5, 4, 4], capacity: 6) == 3)
    }

    // --- Edge cases ---

    @Test("Single item")
    func singleItem() {
        #expect(minimumContainersNeeded([7], capacity: 10) == 1)
    }

    @Test("Each item fills exactly one container")
    func allItemsExactCapacity() {
        #expect(minimumContainersNeeded([5, 5, 5], capacity: 5) == 3)
    }

    @Test("All items fit in one container")
    func allFitInOne() {
        #expect(minimumContainersNeeded([1, 2, 3], capacity: 10) == 1)
    }

    @Test("Two items pair perfectly, one leftover")
    func pairPlusLeftover() {
        // [4,4] fill one container of capacity 8, [3] goes in second
        #expect(minimumContainersNeeded([4, 4, 3], capacity: 8) == 2)
    }

    @Test("Items already sorted descending")
    func sortedDescending() {
        #expect(minimumContainersNeeded([9, 6, 5, 4, 1], capacity: 10) == 3)
    }

    @Test("All identical weights that pair up evenly")
    func allIdentical() {
        #expect(minimumContainersNeeded([3, 3, 3, 3], capacity: 6) == 2)
    }
}
