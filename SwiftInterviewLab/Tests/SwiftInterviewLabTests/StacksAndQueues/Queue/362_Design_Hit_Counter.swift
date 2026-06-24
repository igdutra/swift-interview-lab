import Testing

// ============================================================
// PROBLEM: 362. Design Hit Counter
// https://leetcode.com/problems/design-hit-counter/
// Difficulty: Medium
// Topics: Design, Queue, Data Stream
//
// Design a class that records hit timestamps and returns the count of hits 
// within the past 5 minutes (300 seconds); timestamps arrive in chronological order.
//
// Example 1:
//   Input:  ["HitCounter", "hit", "hit", "hit", "getHits", "hit", "getHits", "getHits"]
//           [[], [1], [2], [3], [4], [300], [300], [301]]
//   Output: [null, null, null, null, 3, null, 4, 3]
//
// Constraints:
//   - 1 <= timestamp <= 2 * 10^9
//   - At most 300 calls will be made to hit and getHits combined
//   - All calls are made with increasing timestamps
//   - It is possible that several hits arrive at the same timestamp
//
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

class HitCounter {
    
    init() {
        // TODO
    }
    
    func hit(_ timestamp: Int) {
        // TODO
    }
    
    func getHits(_ timestamp: Int) -> Int {
        // TODO
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
    
    @Test("Query before any hits")
    func queryBeforeAnyHits() {
        let counter = HitCounter()
        counter.hit(500)
        #expect(counter.getHits(100) == 0)  // query before first hit (invalid in real system, but defensive)
    }
}
