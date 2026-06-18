//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 17/06/26.
//

import Foundation
import Playgrounds


// ============================================================
// PROBLEM: 125. Valid Palindrome
// https://leetcode.com/problems/valid-palindrome/
// Difficulty: Easy
// Topics: Two Pointers, String
//
// Determine if a string is a palindrome after stripping all
// non-alphanumeric characters and lowercasing.
//
// Example 1:
//   Input:  s = "A man, a plan, a canal: Panama"
//   Output: true
//
// Example 2:
//   Input:  s = "race a car"
//   Output: false
//
// Example 3:
//   Input:  s = " "
//   Output: true
//
// Constraints:
//   - 1 <= s.length <= 2 * 10^5
//   - s consists only of printable ASCII characters
//
//
// ============================================================

/* PLAN
 
 GOTCHAS -> avoid type confusion CAST to
 let stringArray = Array(string) as [Character]

QUESTIONS
- what is non-alphanumeric and lowerecasing?
  - non-alphanumeric: not a letter or digit
  - lowercasing: convert all letters to lowercase
- if i'm comparing PAIRS - great case for HASHMAP right? why not doing so?
  - because we can do it in O(n) time and O(1) space with two pointers, while hashmap would require O(n) space
- if single character?
 
 
 - ok so first thing to do: string preprocessing - remove non-alphanumeric characters and convert to lowercase
- build in lowercase( func)
- to steirng non alpha.. i could make a check ifContains for each but expensive right?
 - there's a property from string themselvs!
 
 also on input sanitization
- .filter works but it allocates a new string — O(n) space.
- we can sanitize the input on the fly
 
 
 
 1- two pointers, unsorted, COMPARING PAIRS. In theory you can compare with hashmaps as well but uses O(n) space - two pointers is constant check as we need to return boolean only
 2- CONDITON
 standard left < right for two pointers, string was sanitized already
 that is the oUTER LOOP
 there will be 2 innerloops -> sanitizdr loops to advance both left and right to the first valid position
 check with isLetter and isNumber
 
 finally: LOWERCASED comparison - if leftChar != rightChar - return false
 
 exit outer loop, return true - all comparisons are valid
 
 3- leftPointer/rightPointer - that is it, early returns
 
 4- ok


*/

#Playground {
    let input = "race a car"
    
    // QUESTION - how to make the WHILE conditions BETTER redable?
    func isValidPalindrome(_ string: String) -> Bool {
        let stringArray = Array(string) as [Character]
        var leftPointer = 0
        var rightPointer = stringArray.count - 1
                
        while leftPointer < rightPointer {
//            print("first left", leftPointer)
            // make this print commenting out the OUTER LOOP
        print(stringArray[leftPointer], "is \(!stringArray[leftPointer].isNumber)")
            while !(stringArray[leftPointer].isLetter || stringArray[leftPointer].isNumber), leftPointer < rightPointer {
                leftPointer += 1
            }
            //            print("outside left", leftPointer)
            
            while !(stringArray[rightPointer].isLetter || stringArray[rightPointer].isNumber), leftPointer < rightPointer {
                rightPointer -= 1
            }
//            
//            // now input is sanitized
            let leftCharacter = stringArray[leftPointer].lowercased()
            let rightCharacter = stringArray[rightPointer].lowercased()
            print(leftCharacter, rightCharacter)
            if leftCharacter != rightCharacter {
                return false
            }
//            
//            // we must now advance both
            leftPointer += 1
            rightPointer -= 1
            print(leftPointer, rightPointer)
        }
        
        return true
    }
    
    print(isValidPalindrome(input))
    
}
