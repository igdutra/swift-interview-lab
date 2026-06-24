//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 24/06/26.
//

import Foundation
import Playgrounds

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

/*
 
 QUESTIONS
 - get getHits get timestamps ranmdowly? lie getHits(100) after getHits(50).
    - in theotyr is possible all i need to do is RESET windowStartIndex every time.
 -> ANSWER: timestamps alwyas progresses, no need to reset startIndex.
 
 PLAN
 queue problem - tells: it is a stream. and i must always compare the oldest value, append news at the end (non-decreasing timestamps) - FIFO
 
 SEQUENCE
 
 conditions
 - invariant: valid window = [timestamp - 299, timestamp]
 - hit append simply into my queue. no other op.
 - getHits - the argumemnt is the windowEnd.
 - due to my invariant, my window time spam is 299 - if END is timespam, size is 299, taht amens
queue[startInex] - timestamp < 299 -> this is the while
 
 STATE
 - constant widownTimeSpam is set 299, range is inclusive
 - queue [Int] - always
 - startIndex
 

 WALK
 //   hit(3)        → recorded hits: [1, 2, 3]
 //   getHits(4)    → window [-295..4], all 3 qualify          → returns 3
 4 -> queue[0] - 4 < 299 ? 1 - 4 < 299 -> VALID so we enter whilelopp and increase ... FALSE
 // recorded hits: [1, 2, 3, 300]
 300 -> qeue[0] - 300 < 299
 
 
 -> I HAD IT WRONG -> THE WHOLE POINT IS TO DO
 VALID WINDOW: START - END < 299 OR BETTER START - END <= 300 -> BUT THAT MUST BE ABS! ABS(START-END) <= 300
 HOWEVER THAT IS LITERALLY what sliding window does: SHRINK ON INVALID -> so while abs(start - end) <= 300
 - fix 2: since we now that timestamp > queuestart (always increasing) we actually do timestamp - start <= 300
 THAT IS IT.
 
*/

#Playground("Hit") {
    
    class HitCounter {
        let windowDuration = 300
        var queue: [Int] = []
        var startIndex = 0 // this gets changed each getHits call
        
        init() { }
        
        func hit(_ timestamp: Int) {
            queue.append(timestamp)
            print("queue", queue)
        }
        
        func getHits(_ timestamp: Int) -> Int {
            // DEALING WITH INDEXES WE MUST GUARD IT !!!
            while startIndex < queue.count, abs(queue[startIndex] - timestamp) >= windowDuration { // timestamp always increase, greater then start, so it should be timestamp - queue[startInex]
                startIndex += 1
            }
            return queue.count - startIndex
        }
    }
    
    let counter = HitCounter()
    counter.hit(1)
    counter.hit(2)
    counter.hit(3)
    print("getHits(4):", counter.getHits(4), "— expected 3")
    counter.hit(300)
    print("getHits(300):", counter.getHits(300), "— expected 4")
    print("getHits(301):", counter.getHits(301), "— expected 3")
}
