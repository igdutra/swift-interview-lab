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

/* FOLLOW-UP: what if we add a remove() method?

 -> stack-based: trivial, remove() == next() (pop is already the removal)
 -> 2-pointers: you need to mutate the input array (remove at innerIndex),
    then carefully re-adjust outerIndex/innerIndex so they still point
    at the element before the one just removed

    func remove() -> Int {
        // innerIndex is currently ON the last-returned element (next() did not advance past it)
        let removed = input[outerIndex][innerIndex]
        input[outerIndex].remove(at: innerIndex)

        // after removal, innerIndex now points at the NEXT element (or is out of bounds).
        // step back one so the iterator cursor sits "before" that next element,
        // matching the invariant that advanceToNext() will move forward on the next call.
        innerIndex -= 1

        // if we stepped before the start of this row, walk back to the previous non-empty row
        while innerIndex < 0 && outerIndex > 0 {
            outerIndex -= 1
            innerIndex = input[outerIndex].count - 1
        }

        return removed
    }
 */

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

        @discardableResult
        func remove() -> Int? {
            // no advanceToNextVector() — calling it would load the next row into the stack,
            // making remove() "always safe" but wrong: you'd remove an element never visited by next().
            // nil when stack is empty is intentional: next() was never called (or called twice).
            // same contract as Java Iterator.remove() throwing IllegalStateException.
            guard let removed = stack.popLast() else { return nil }
            print("remove", removed)
            return removed
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
    var input = [[1,2],[3],[4]]
    
    class Vector2D {
        var input: [[Int]]
        var outerIndex: Int = 0 // acts as my input in the above solution
        var innerIndex: Int = 0 // acts as my int stack
        
        init(input: [[Int]]) {
            self.input = input
            advanceToNextVector()
//            print(stack)
        }

        @discardableResult
        func hasNext() -> Bool {
            advanceToNextVector()
            // fix: only check outerIndex - when outerIndex overflows that is the indication of exhaustion
            print("hasNext", outerIndex < input.count)
            return outerIndex < input.count
        }

        @discardableResult
        func next() -> Int? {
            advanceToNextVector()
            guard outerIndex < input.count else { return nil }
            let next = input[outerIndex][innerIndex]
            innerIndex += 1
            print("next", next)
            return next
        }

        // MARK: private

        func advanceToNextVector() {
            // fix: only check outerIndex - when outerIndex overflows that is the indication of exhaustion
            while outerIndex < input.count, innerIndex >= input[outerIndex].count {
                outerIndex += 1
                innerIndex = 0
            }
        }
    }
    
    let object = Vector2D(input: [[1,2],[3],[4]])
    print("1)", object.hasNext())
    print("2)", object.next() as Any)
    print("3)", object.hasNext())
    print("4)", object.next() as Any)
    print("5)", object.hasNext() as Any)
    print("6)", object.next() as Any)
    print("7)", object.hasNext() as Any)
    print("8)", object.next() as Any)
    print("9)", object.hasNext() as Any) // must be false
    print("10)", object.next() as Any)
}
