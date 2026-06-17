//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 16/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 202. Happy Number
// https://leetcode.com/problems/happy-number/
// Difficulty: Easy
// Topics: Hash Table, Math, Two Pointers
//
// Repeatedly replace a number with the sum of squares of its digits;
// return true if the process eventually reaches 1, false if it cycles forever.
//
// Example 1:
//   Input:  n = 19
//  Explanation:
//  1^2 + 9^2 = 82
//  8^2 + 2^2 = 68
//  6^2 + 8^2 = 100
//   Output: true  (19 → 82 → 68 → 100 → 1)
//
// Example 2:
//   Input:  n = 2
//   Output: false
//
// Constraints:
//   - 1 <= n <= 2^31 - 1
//
//
// ============================================================

/* PLAN
 
QUESTIONS
squares -> no need to handle zero or negative
 1. No need to handle zero or negative — skip that guard.
 2. Watch for intermediate overflow in your computation, not just the input value.
 
 1- cycle detection - have i seen this before? - hashmap - set is fine no associated value is needed
 2- CONDITION: 2 LOOPS
 we also need a secondary loop to decode the digits - leftDigits
 and OUTERLOOp - current number -> while currentNumber != 1
 if seen - return false. seen just basically says we have been throuj this input - and the results will be deterministic so it is a loop
 3- State: seenSquares as a set
 4- get the digits array, loop through it accumulating the result.
 - store it in seen - if seen, return false. return true case 1
 
*/


// Floyd's cycle detection — O(log n) time, O(1) space
// slow takes one step, fast takes two; if there's a cycle they must meet
func isHappyNumberFloyd(_ number: Int) -> Bool {
    func nextSquaresSum(_ current: Int) -> Int {
        var remaining = current
        var sum = 0
        while remaining > 0 {
            let digit = remaining % 10
            sum += digit * digit
            remaining /= 10
        }
        return sum
    }

    var slow = number
    var fast = nextSquaresSum(number)

    while fast != 1 && slow != fast {
        slow = nextSquaresSum(slow)
        fast = nextSquaresSum(nextSquaresSum(fast))
    }

    return fast == 1
}

#Playground {
    let number = 145
    
    func isHappyNumer(_ number: Int) -> Bool {
        var seenSquares: Set<Int> = []
        var currentNumber = number
        
        while currentNumber != 1 {
            var digits: [Int] = []
            // FIRST BUG: before the outer loop i had leftDigits = number instead of CURENT NUMBER
            var leftDigits = currentNumber
            
            while leftDigits != 0 {
                let unit = leftDigits % 10
                digits.append(unit)
                leftDigits /= 10
            }

            let squaresSum = digits.reduce(0) { $0 + $1 * $1 }
            print(squaresSum)
            
            if seenSquares.contains(squaresSum) {
                print(seenSquares)
                return false
            } else {
                seenSquares.insert(squaresSum)
                currentNumber = squaresSum
            }
        }
        
        // Number is 1
        return true
    }
    
    func alternateNumberExtraction(_ number: Int) -> [Int] {
        let stringArray = Array(String(number))
        let digits: [Int] = stringArray.map { Int(String($0))! }
        return digits
    }
    print(alternateNumberExtraction(number))
    
    print(isHappyNumer(number))
}
