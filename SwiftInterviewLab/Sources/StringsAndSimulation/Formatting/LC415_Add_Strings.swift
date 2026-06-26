//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 25/06/26.
//

import Foundation
import Playgrounds

// ============================================================
//Given two non-negative integers, num1 and num2 represented as string, return the sum of num1 and num2 as a string.
//
//You must solve the problem without using any built-in library for handling large integers (such as BigInteger). You must also not convert the inputs to integers directly.
//
//
//Example 1:
//
//Input: num1 = "11", num2 = "123"
//Output: "134"
//Example 2:
//
//Input: num1 = "456", num2 = "77"
//Output: "533"
//Example 3:
//
//Input: num1 = "0", num2 = "0"
//Output: "0"
// ============================================================

/* PLAN
 
 PATTERN
 single scan with digit's buffer
 
 SEQUENCE
 mimic natural "paper" sum -> write a carry, control left and right digits
 while leftIndex >= 0, rightIndex >=0, carry > 0 -> final carry must append
 math:
 carry = columnSum / 10 // 0 or 1
 columnSum % 10 -> digit.
 start FROM RIGHT -> LEFT, as we do by hand
 
 "105" + "77"
 WALK
 5 + 7 = 12
 digit = 12 % 10  = 2
 carry = 12 / 10 = 1
 ...
 
 STATE
 leftIndex, rightIndex, carry, columnSum, resultDigits
 
 EDGE CASES
 input empty? wholeNumber should be nil
 
 COMPLEXITY
 o(max(n,m)) for both space and time
 
*/


#Playground {
    let num1 = "105", num2 = "77"
    let array1 = Array(num1), array2 = Array(num2)
    var indexNum1 = num1.count - 1, indexNum2 = num2.count - 1
    var resultDigits: [Character] = []
    var columnSum = 0
    var carry = 0
    
    // instead of for, we break ehich exausts firts
    while indexNum1 >= 0 || indexNum2 >= 0 || carry > 0 {
        print(indexNum1, indexNum2, carry)
        // since multiple, we need to check
        let digit1 = indexNum1 >= 0 ? array1[indexNum1].wholeNumberValue ?? 0 : 0
        let digit2 = indexNum2 >= 0 ? array2[indexNum2].wholeNumberValue ?? 0 : 0
        columnSum = digit1 + digit2 + carry
        
        let currentDigit = columnSum % 10 // current unit
        carry = columnSum / 10 // 0 or 1
        
        resultDigits.append(Character(String(currentDigit)))
        
        indexNum1 -= 1
        indexNum2 -= 1
    }
    
    print(String(resultDigits.reversed()))
    
    // output should be reversed
}


/* CLAUDE PLAN

 PATTERN: simulate paper addition right-to-left — can't convert to Int (arbitrarily large)

 SEQUENCE
 - scan both from the right with two index cursors
 - each column: digit1 + digit2 + carry → % 10 is the digit, / 10 is next carry
 - loop while either index is valid OR carry > 0 (catches final carry like "99"+"1")
 - append digits reversed → flip at the end

 STATE: indexNum1, indexNum2, carry, resultDigits: [Character]

 EDGE CASES: different lengths (guard index before reading), "0"+"0"
*/

/// TESTS

#Playground {
    // No such thing as empty character.
//    let string: String = "aaa"
//    let prefix = string.prefix(0)
//    for char in prefix {
//        print("passei?")
//    }
//    print(prefix as? Character)
//    for char in prefix {
//        print("nao passou", char.wholeNumberValue as Any)
//    }
//    print("passou")
}
