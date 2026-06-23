//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 23/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 341. Flatten Nested List Iterator
// https://leetcode.com/problems/flatten-nested-list-iterator/
// Difficulty: Medium
// Topics: Stack, Tree, Depth-First Search, Design, Queue, Iterator
//
//  USE THE NestedInteger helper
//
// Design an iterator that flattens a nested list of integers
// (each element is either an integer or a list of integers) and
// yields one integer at a time via next() and hasNext().
//
// Example 1:
//   Input:  nestedList = [[1,1],2,[1,1]]
//   Output: [1,1,2,1,1]
//
// Example 2:
//   Input:  nestedList = [1,[4,[6]]]
//   Output: [1,4,6]
//
// Constraints:
//   - 1 <= nestedList.length <= 500
//   - The values of the integers in the nested list are in the range [-10^6, 10^6]
    
//    Your code will be tested with the following pseudocode:
//
//    initialize iterator with nestedList
//    res = []
//    while iterator.hasNext()
//        append iterator.next() to the end of res
//    return res
//    If res matches the expected flattened list, then your code will be judged as correct..
//    //
// ============================================================

/* PLAN
 
 PATTERN
 nesting is LIFO - we will use a STACK
 
 NOTEs
 - we need a idempotency function that will be called on hasNext and next - since it can be called multiple times
 - advanceToNextInteger -> we will get to a valid "index" position.
 - since that is nested and we don't know if the next element is int or not, we will append that to the stack
 -
 
 SEQUENCE
 - we reverse the input as we will use pop since it is O(1)
 - advanceToNextInteger()
    - while: pop last, last != isInteger
        - we kNOW IT is a list - iterate over the values
        - we APPEND it again to the exact same STACK - REVERSED so that on pop we get the correct order
    - hasNext - simply return if stack is empty
    - next: we now it is int, return the top
 }
    -
 
 - [1,[4,[6]]] -> reversed - -[[4,[6], 1]]
 - next -> stack: [[4,[6]]
 - last = [4, [6]]
 
 WALK
 - [1,[4,[6]]] -> reversed - -[[4,[6], 1]]
 - next -> stack: [[4,[6]]
 - last = [4, [6]]
 
 
 EDGE CASES
 - call next() before hasNext()?
 
 
 */

#Playground {
    let container = NestedInteger()
    container.add(NestedInteger(1))

    let inner2 = NestedInteger()
    inner2.add(NestedInteger(6))
    
    let inner1 = NestedInteger()
    inner1.add(NestedInteger(4))
    inner1.add(inner2)
    container.add(inner1)
//    print(container) // [1,[4,[6]]]
    
    final class NestedListIterator {
        var stack: [NestedInteger]
        
        init(_ input: NestedInteger) {
            stack = input.getList().reversed()
            print("init stack", stack)
        }
        
        func hasNext() -> Bool {
            advanceToNextInteger()
            return !stack.isEmpty
        }
        
        @discardableResult
        func next() -> Int? {
            advanceToNextInteger()
            print("next", stack)
            guard let next = stack.popLast() else { return nil }
            return next.getInteger()
        }
        
        // MARK: - Private
        
        func advanceToNextInteger() {
            // BUG! I WAS ALWYS removing first, before checking if is integer
            while let last = stack.last, !last.isInteger() {
                // We know it is a list and there's a last value
                let popped = stack.removeLast()
                let list = popped.getList()
                print("list", list)
                for value in list.reversed() { // LIFO, must reverse so the order is preserverd on pop
                    print("appending", value)
                    stack.append(value)
                }
            }
            print("advanced", stack)
        }
    }
    
    // MARK: - Testing
    
    let object = NestedListIterator(container)
    print("1)", object.hasNext())
    print("2)", object.next() as Any)
    print("3)", object.hasNext())
    print("4)", object.next() as Any)
    print("5)", object.hasNext())
    print("6)", object.next() as Any)
    print("7)", object.hasNext() as Any)
}
