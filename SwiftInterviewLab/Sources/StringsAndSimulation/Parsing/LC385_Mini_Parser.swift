//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 21/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 385. Mini Parser
// https://leetcode.com/problems/mini-parser/
// Difficulty: Medium
// Topics: Stack, Depth-First Search, String
//
// Given a string s representing a serialization of a nested
// list, parse and deserialize it into a NestedInteger object.
//
// Example 1:
//   Input:  s = "324"
//   Output: 324
//
// Example 2:
//   Input:  s = "[123,[456,[789]]]"
//   Output: [123,[456,[789]]]
//
// Constraints:
//   - 1 <= s.length <= 5 * 10^4
//   - s consists of digits, square brackets "[]", negative sign '-', and commas ','
//   - s is the serialization of valid NestedInteger
//   - All the values in the input are in the range [-10^6, 10^6]
// ============================================================



// LESSON: in the EDGE CASE - GET SOME EDGE CASE INPUTS TO GET VERIFIED AFTER
// [3, [4]] - double quoats
// [-3] - negative
// 234 - plain number


/*

 QUESTIONS & ANSWERS

 Q: When I see a number like "456", how do I know when it ends — is it always followed by ',' or ']'?
 A: Yes. A number always terminates on a comma (more siblings) or close-bracket (list ends).
    Those are the only two boundaries in a well-formed string.

 Q: What happens with empty lists like "[]" — do I create an empty NestedInteger or skip it?
 A: Create an empty NestedInteger. Empty lists are valid elements and must be preserved in the output.

 Q: What does 'well-formed' guarantee me — can I assume brackets are always balanced and syntax is valid?
 A: Yes. Input is guaranteed valid: balanced brackets, no malformed syntax, every '[' has a matching ']'.
    No validation needed — assume every pop finds a matching container on the stack.

 -> EDGE CASE: negative value - need one more state, isNegative

 1. PATTERN
 -  stack-based parser - nesting is LIFO. will use sigle loop and have if conditions inside it

 2. SEQUENCE
- my stack is an array of [NestedIntegers].
 - completing the INNER object, pop, add to LAST (object before - nesting) object.
 - return: on last ] - the stack is empty after pop -> popped is the result.
 - also looping the string, we have a accumulator currentInteger
 - edge case: isNegative
 - loop on string, operations:
    - [ -> append new object NestedInteger to stack
    - , -> commit currentInteger to last object in the stack - RESET isNegative, currentNumber
    - ] -> commit currentInteger to last object in the stack - RESET isNegative, currentNumber - AND pop and pour - act of nesting.
    - "-" - isNegative to true
 
 3. STATE
 - stack [NestedInteger]
 - current integrer -> digit magic
 - isNegative

 4. CONDITIONS / LOOP
 - loop main string - enumerated
 - commit into stack - REUSED CODE - currentNumber * (isNegative ? -1 : 1)
 - [ -> append new object NestedInteger to stack
 - , -> commit currentInteger to last object in the stack - RESET isNegative, currentNumber
 - ] -> commit currentInteger to last object in the stack - RESET isNegative, currentNumber - AND pop and pour - act of nesting.

 "[123,[456,[789]]]"
 5. WALK
 

 6. EDGE CASES
 - isNegative - ok

*/


/*
 PLAN 2

 Pattern:
 stack-based parser. Nesting is physically LIFO — innermost bracket always closes first,
 so a stack of NestedInteger lists is the natural fit. Single pass, one character at a time.

 Condition:
 - on [ push a new empty list.
 - On ] (and ,) commit any pending number into stack.last,
 - then on ] also pop and pour into the new top.
 - "-", isNegative true
 -  Stack empty after pop means we have the final answer.

 State:
 stack [NestedInteger],
 currentNumber Int,
 isNegative Bool,
- edge case on empty stack?
 - commiting in sequecen ]]

 Walk: "[12,[13,14]]"
   [        push A                    stack: [A]
   1,2      accumulate 12
   ,        commit 12→A  reset        stack: [A:[12]]
   [        push B                    stack: [A:[12], B]
   1,3      accumulate 13
   ,        commit 13→B  reset        stack: [A:[12], B:[13]]
   1,4      accumulate 14
   ]        commit 14→B               stack: [A:[12], B:[13,14]]
            pop B → stack.last.add(B) stack: [A:[12,[13,14]]]
   ]        pop A → stack empty → result = A

 Edge cases:
 - plain number input (no brackets) → return NestedInteger wrapping currentNumber after loop.
 - negative numbers → isNegative flag, reset alongside currentNumber.
*/

// Why LIFO? Nesting is inherently LIFO: the innermost bracket closes before the outer one. An expression stack evaluates the most recently deferred sub-expression first. A DFS explores the most recently discovered path before backtracking. In every case, "what I saw most recently" determines what to do right now — that is Last In, First Out.
#Playground {
    let input = "[123,[456,[789]]]"
    
    // testing
////        print(string)
//    let a = NestedInteger()
//    let b = NestedInteger(3)
//    let c = NestedInteger(4)
//    a.add(b)
//    a.add(c)
//    print("a", a)
//    stack.append(a)
//    print("stack before", stack)
//    currentInteger = 5
//    commitInteger()
//    print("after", stack)
        
    func getNestedNumber(_ string: String) -> NestedInteger {
        let stringArray = Array(string)
        var currentInteger = 0 // should it be optinal to handle empty? maybe
        var isNegative = false
        var hasSeenNumber = false
        var result = NestedInteger() // if there's nothing to commit, return it empty
        var stack: [NestedInteger] = [result]
        
        // Single source of truth
        func resetAccumulators() {
            currentInteger = 0
            isNegative = false
            hasSeenNumber = false
        }
        
        func commitInteger() {
//            print("commiting", hasSeenNumber)
            guard hasSeenNumber else { return }
            // ATTENTION! IT DEPENDS ON THE IMPLEMENTAITON
            // IF NESTEDINTEGER = class, this is fine - we get a reference
            // IF STRUCT, THEN IT IS A VALUE TYPE and we actually need
                //  stack[stack.count - 1].add(...) - mutate the object directly!
            var lastObject = stack.last
//            print(lastObject)
            let integer = isNegative ? currentInteger * -1 : currentInteger
            lastObject?.add(NestedInteger(integer))
            resetAccumulators()
        }

        for (index, character) in stringArray.enumerated() { // do we need to commit on last index? YES "342"
            // make it work, then make it better
            // ATTENTION to fallthrough
            
            // Accumulate multi-digit numbers properly
            if let digit = character.wholeNumberValue {
                currentInteger = currentInteger * 10 + digit
                hasSeenNumber = true
            }
            
            if character == "-" {
                isNegative = true
            }
            
            // Append new list/object to the stack
            if character == "[" {
                stack.append(NestedInteger())
            }
            
            if character == "," {
                commitInteger()
            }
            
            if character == "]" {
                commitInteger() // ATTENTION to edge cases - verify
                // yup -> commitig in sequecne ]] - solution - hasSeenNumber
                if let popped = stack.popLast() {
                    if let lastObject = stack.last {
                        lastObject.add(popped)
                    } else {
                        return popped // stack is empty
                    }
                } // string end handled when there's no []. with brackts we guarantee that there's string end.
            }
            
            if index == stringArray.count - 1 { // string end - commit.
                guard hasSeenNumber else { break }
                commitInteger()
                return result
            }
        }
        
        return result
    }
    
    print(getNestedNumber("666"))
}
