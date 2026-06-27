import Testing

// ============================================================
// PROBLEM: 755. Pour Water
// https://leetcode.com/problems/pour-water/
// Difficulty: Medium
// Topics: Array, Simulation
//
// Given an elevation map, V units of water dropped one at a time at index K.
// Each unit flows left to the lowest reachable spot (stopping at first rise),
// then right by the same rule, then stacks at K. Return the final heights.
//
// Example 1: heights=[2,1,1,2,1,2,2], V=4, K=3 → [2,2,2,3,2,2,2]
// Example 2: heights=[1,2,3,4],       V=2, K=2 → [2,3,3,4]
// Example 3: heights=[3,1,3],         V=5, K=1 → [4,4,4]
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(V * N) — for each of the V water units we scan left and
//                   right from K, visiting at most N elements total per drop.
//                   In the worst case (e.g. K at one end, water always flows
//                   all the way to the other end) every drop costs O(N).
//
// Space Complexity: O(N) — we copy the input array into currentHeightMap.
//                   The helper closure uses O(1) extra space (a single index
//                   variable), and no auxiliary data structures are allocated.
// ============================================================

private func pourWater(_ heights: [Int], _ volume: Int, _ dropIndex: Int) -> [Int] {
    var currentHeightMap = heights

    func getReachableMinIndex(scanning range: ClosedRange<Int>, leftward: Bool) -> Int? {
        var bestIndex: Int? = nil
        let indices = leftward ? Array(range.reversed()) : Array(range)
        for index in indices {
            if let currentBest = bestIndex, currentHeightMap[index] > currentHeightMap[currentBest] { break }
            if bestIndex == nil || currentHeightMap[index] < currentHeightMap[bestIndex!] { bestIndex = index }
        }
        return bestIndex
    }

    for _ in 1...volume {
        let kHeight = currentHeightMap[dropIndex]

        let lowestIndexLeft: Int? = dropIndex > 0
            ? getReachableMinIndex(scanning: 0...(dropIndex - 1), leftward: true)
            : nil
        let lowestIndexRight: Int? = dropIndex < currentHeightMap.count - 1
            ? getReachableMinIndex(scanning: (dropIndex + 1)...(currentHeightMap.count - 1), leftward: false)
            : nil

        if let leftIndex = lowestIndexLeft, currentHeightMap[leftIndex] < kHeight {
            currentHeightMap[leftIndex] += 1
        } else if let rightIndex = lowestIndexRight, currentHeightMap[rightIndex] < kHeight {
            currentHeightMap[rightIndex] += 1
        } else {
            currentHeightMap[dropIndex] += 1
        }
    }

    return currentHeightMap
}

@Suite("755 Pour Water")
struct PourWaterTests {

    // ── Canonical examples ──────────────────────────────────────────────────

    @Test("Example 1 — fills two left valleys then right then stacks at K")
    func example1() {
        #expect(pourWater([2,1,1,2,1,2,2], 4, 3) == [2,2,2,3,2,2,2])
    }

    @Test("Example 2 — right side all uphill, both drops flow left to index 0")
    func example2() {
        #expect(pourWater([1,2,3,4], 2, 2) == [2,3,3,4])
    }

    @Test("Example 3 — valley fills to wall height, then stacks at K")
    func example3() {
        #expect(pourWater([3,1,3], 5, 1) == [4,4,4])
    }

    // ── Wall reachability (the bug fixed in third try) ──────────────────────

    @Test("Wall blocks low valley — water stops before the peak, not at global min")
    func wallBlocksValley() {
        // heights=[0,2,1], K=0: global min is index 2 (height 1) but it's
        // behind a wall at index 1 (height 2). Water can only go right to
        // index 1 — but index 1 is higher than K (height 0), so it stacks at K.
        #expect(pourWater([0,2,1], 1, 0) == [1,2,1])
    }

    @Test("Wall on left — valley behind wall is unreachable, water goes right")
    func wallOnLeft() {
        // heights=[1,3,0,2], K=1: left scan hits index 0 (height 1 < height 3 at K) → bestIndex=0.
        // right scan: index 2 (height 0 < height 3) → bestIndex=2, index 3 (height 2 > height 0) → stop.
        // Left wins (lower): settle at index 0 first drop.
        #expect(pourWater([1,3,0,2], 1, 1) == [2,3,0,2])
    }

    // ── Left-before-right tie-break ─────────────────────────────────────────

    @Test("Symmetric valley — equal low on both sides, left wins")
    func symmetricValleyLeftWins() {
        #expect(pourWater([1,2,1], 1, 1) == [2,2,1])
    }

    // ── Edge cases: K at array boundary ────────────────────────────────────

    @Test("K at left edge — no left side, water flows right or stacks")
    func kAtLeftEdge() {
        #expect(pourWater([1,2,3], 1, 0) == [2,2,3])
    }

    @Test("K at right edge — no right side, water is already the minimum, stacks at K")
    func kAtRightEdge() {
        // heights=[3,2,1], K=2: heights[K]=1 is already the lowest, left side is all higher → stacks at K
        #expect(pourWater([3,2,1], 1, 2) == [3,2,2])
    }

    // ── Flat terrain ─────────────────────────────────────────────────────────

    @Test("Flat terrain — first drop stacks at K, then spreads as K becomes the local peak")
    func flatTerrain() {
        // Drop 1: all equal → stacks at K=1 → [2,3,2,2]
        // Drop 2: left index 0 (height 2) < kHeight 3 → settles left → [3,3,2,2]
        // Drop 3: left blocked, right index 2 (height 2) < kHeight 3 → settles right → [3,3,3,2]
        #expect(pourWater([2,2,2,2], 3, 1) == [3,3,3,2])
    }

    // ── Valley fills mid-pour ────────────────────────────────────────────────

    @Test("Valley fills and levels mid-pour, later drops stack at K")
    func valleyFillsMidPour() {
        // [3,1,3], V=2: first two drops fill to [3,3,3], remaining stack at K=1
        #expect(pourWater([3,1,3], 3, 1) == [3,4,3])
    }
}
