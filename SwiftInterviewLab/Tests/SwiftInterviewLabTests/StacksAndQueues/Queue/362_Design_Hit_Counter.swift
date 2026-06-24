import Testing

// ============================================================
// PROBLEM: 362. Design Hit Counter
// https://leetcode.com/problems/design-hit-counter/
// Difficulty: Medium
// Topics: Queue, Sliding Window, Design
// See also: Design category (stateful object with expiring state)
//
// Design a HitCounter class with two methods:
//
//   hit(timestamp)      — records that one hit occurred at `timestamp`.
//                         Does NOT return anything.
//
//   getHits(timestamp)  — returns the number of hits recorded in the
//                         window [timestamp - 299, timestamp] (inclusive).
//                         This is a pure query — it does NOT record a hit.
//
// The window is always the last 300 seconds ending at `timestamp`.
// Timestamps are guaranteed to arrive in non-decreasing order.
//
// Example (traced step by step):
//   hit(1)        → recorded hits: [1]
//   hit(2)        → recorded hits: [1, 2]
//   hit(3)        → recorded hits: [1, 2, 3]
//   getHits(4)    → window [-295..4], all 3 qualify          → returns 3
//   hit(300)      → recorded hits: [1, 2, 3, 300]
//   getHits(300)  → window [1..300], all 4 qualify           → returns 4
//   getHits(301)  → window [2..301], hit at t=1 expired      → returns 3
//
// Constraints:
//   - 1 <= timestamp <= 2 * 10^9
//   - At most 300 calls will be made to hit and getHits combined
//   - All calls are made with non-decreasing timestamps
//   - Multiple hits at the same timestamp are allowed
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  hit → O(1). getHits → O(n) amortized — each hit is evicted at most once.
// Space Complexity: O(n) — queue grows with total hits recorded.
// ============================================================

private class HitCounter {
    private let windowDuration = 300
    private var queue: [Int] = []
    private var startIndex = 0

    func hit(_ timestamp: Int) {
        queue.append(timestamp)
    }

    func getHits(_ timestamp: Int) -> Int {
        while startIndex < queue.count && timestamp - queue[startIndex] >= windowDuration {
            startIndex += 1
        }
        return queue.count - startIndex
    }
}


// ============================================================
// TESTS
// ============================================================

@Suite("Design Hit Counter")
struct LC362DesignHitCounterTests {
    
    // --- Official LeetCode examples ---
    
    @Test("Official example 1")
    func officialExample1() {
        let counter = HitCounter()
        counter.hit(1)
        counter.hit(2)
        counter.hit(3)
        #expect(counter.getHits(4) == 3)
        counter.hit(300)
        #expect(counter.getHits(300) == 4)
        #expect(counter.getHits(301) == 3)
    }
    
    // --- Edge cases ---
    
    @Test("Single hit")
    func singleHit() {
        let counter = HitCounter()
        counter.hit(1)
        #expect(counter.getHits(1) == 1)
    }
    
    @Test("Multiple hits at same timestamp")
    func multipleHitsAtSameTimestamp() {
        let counter = HitCounter()
        counter.hit(100)
        counter.hit(100)
        counter.hit(100)
        #expect(counter.getHits(100) == 3)
    }
    
    @Test("Hit expires after 300 seconds")
    func hitExpiresAfter300Seconds() {
        let counter = HitCounter()
        counter.hit(1)
        #expect(counter.getHits(1) == 1)
        #expect(counter.getHits(301) == 0)
    }
    
    @Test("Hit exactly at 300 second boundary")
    func hitAt300SecondBoundary() {
        let counter = HitCounter()
        counter.hit(1)
        counter.hit(301)
        #expect(counter.getHits(301) == 1)  // hit at 1 is expired
    }
    
    @Test("No hits recorded")
    func noHitsRecorded() {
        let counter = HitCounter()
        #expect(counter.getHits(100) == 0)
    }
    
}
