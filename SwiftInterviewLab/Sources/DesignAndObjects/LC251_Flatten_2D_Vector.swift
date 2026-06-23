//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 22/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 251. Flatten 2D Vector
// https://leetcode.com/problems/flatten-2d-vector/
// Difficulty: Medium
// Topics: Array, Design, Two Pointers, Iterator
//
// Design an iterator over a 2D integer array that yields
// one integer at a time in row-major order via next() and
// hasNext(), silently skipping any empty inner arrays.
//
// Example 1:
//   Input:  vec = [[1,2],[3],[4]]
//   Output: [1,2,3,4]
//
// Example 2:
//   Input:  vec = [[1,2,3],[4,5,6]]
//   Output: [1,2,3,4,5,6]
//
// Constraints:
//   - 0 <= vec.length <= 200
//   - 0 <= vec[i].length <= 500
//   - -500 <= vec[i][j] <= 500
//   - At most 10^5 calls will be made to next and hasNext.
//
//        protocol Vector2D {
//            init()
//
//            func hasNext() -> Bool
//
//            func next() -> Int
//        }
// ============================================================

/* PLAN
 
 PATTERN
 - stack-based iterator.
 
 SEQUENCE
 - idempotency: we need a function that will be called both in hasNext and next so that our states are always valid, independent of the order of the operations
 - advanceToNextVector()
    - [[1,2],[3]] -> reversed stack, becomes  [[3],[1, 2]]
    - WHILE input is != empty and stack == empty -> that is our guardrail.
    - pop [1, 2]. WHILE !popped.isEmoty -> append result.
        - honestly that is the exact same as appending in our stack with .reversed() - same time complexity
        - get stack
    - hasnext is trivial - checks if input || stack is empty

 
 STATE
  - input array [[Int]]
 - stack [Int]
 
 [[1,2],[3],[4]]
 WALK

 
 EDGE CASES
 - call hasNext 2x - saved on while conditiom
 - empty - returns false on hasNext, stack and input are emptu
 
 
*/

#Playground("stack based") {
    var input = [[1,2],[3],[4]]
    
    class Vector2D {
        var input: [[Int]]
        var stack: [Int]
        
        init(input: [[Int]]) {
            self.input = input.reversed() // NOTE: LIFO strategy must be reversed.
            stack = []
            advanceToNextVector()
//            print(stack)
        }

        @discardableResult
        func hasNext() -> Bool {
            advanceToNextVector()
            print("hasNext", !stack.isEmpty || !input.isEmpty)
            return !stack.isEmpty || !input.isEmpty
        }

        @discardableResult
        func next() -> Int? {
            advanceToNextVector()
            guard let next = stack.popLast() else { return nil }
//            let next = stack.popLast()! // assume hasNext will be called before
            print("next", next)
            return next
        }
        
        // MARK: private
        
        func advanceToNextVector() {
            // We must find only while stack is empty
            while !input.isEmpty && stack.isEmpty {
                // EDGE CASE: INPUT [[], []] ->
                if let popped = input.popLast(), !popped.isEmpty {
                    stack.append(contentsOf: popped.reversed())
                }
            }
        }
    }
    
    let object = Vector2D(input: [[], []])
    object.hasNext()
    object.next()
    object.hasNext()
    object.next()
    object.next()
    object.next()
    object.hasNext() // false
}

#Playground("pointer based") {
    
}
