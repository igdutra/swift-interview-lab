//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 29/06/26.
//

import Foundation
import Playgrounds

//Given a string s containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.
//
//An input string is valid if:
//
//Open brackets must be closed by the same type of brackets.
//Open brackets must be closed in the correct order.
//Every close bracket has a corresponding open bracket of the same type.
// 
//
//Example 1:
//
//Input: s = "()"
//
//Output: true
//
//Example 2:
//
//Input: s = "()[]{}"
//
//Output: true
//
//Example 3:
//
//Input: s = "(]"
//
//Output: false
//
//Example 4:
//
//Input: s = "([])"
//
//Output: true
//
//Example 5:
//
//Input: s = "([)]"
//
//Output: false
//
//
//Constraints:
//
//1 <= s.length <= 104
//s consists of parentheses only '()[]{}'


/* PLAN
 
 QUESTIONS
 - do i need to guard? no assume valid input
 -
 
 PATTERN
 - stack base: LIFO - nesting is LIFO
 - PAIR MATCHING = hashmap
 
 
 let input = "([{)))"
    - return
 - reversed )))){[(
 CONDITIONS
 - because we get the reversed FIRST, we will use that as key: so for CLOSING ) as key, we get (.
 - 2 operations: CLOSE / POP.
 - on OPEN, we CREATE A NEW nested level - that, if the next operation is a CLOSE, MUST CLOSE FIRST.
 
 SEQUECE
 - we scan elements
 - is opener?
    - add nesting level
 - is a closer?
    - detect if matches LAST elemtn in the stack - if it does not -re turn false
 
 STATE
 - matchingPairs -
 
 
 WALK
 - check
 
 
 EDGE CASES
 - no edge cases, valid input
 
 */


#Playground {
    var input =  "()[]"
    
    func isStringValid(string: String) -> Bool {
        var stack: [Character] = []
        let stringArray = Array(string)
        let openCharacterForClosingCharacter: [Character: Character] = [
            ")": "(",
            "}": "{",
            "]": "["
        ]
        
        for character in stringArray {
            if let openerCharacter = openCharacterForClosingCharacter[character] {
                // dict found a match - it is a closing character. could use better names
                if stack.last != openerCharacter { return false } // must close the nested value first
                stack.removeLast()
            } else { // it is a opener
                stack.append(character)
            }
        }
        
        // return true only if there are no openings left
        return stack.isEmpty
    }
    
    print(isStringValid(string: input))
}

