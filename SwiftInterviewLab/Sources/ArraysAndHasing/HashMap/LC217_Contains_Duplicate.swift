//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 16/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 217. Contains Duplicate
// https://leetcode.com/problems/contains-duplicate/
// Difficulty: Easy
// Topics: Array, Hash Table, Sorting
//
// Return true if any value appears at least twice in the array.
//
// Example 1:
//   Input:  nums = [1,2,3,1]
//   Output: true
//
// Example 2:
//   Input:  nums = [1,2,3,4]
//   Output: false
//
// Example 3:
//   Input:  nums = [1,1,1,3,3,4,3,2,4,2]
//   Output: true
//
// Constraints:
//   - 1 <= nums.length <= 10^5
//   - -10^9 <= nums[i] <= 10^9
//
//

/* PLAN
 
 QUESTIONS
 - does not matter then if multiple times? No
 (i'll do a version that will map in a dict and return all the indexes where they apear)
 
 1- boolean check, a hashmap will do-will use a set as no value needs to be associated with
 2- CONDITION:
 Scan array, check before inserting, insert the set
 3- seenNumbers as a set
 4- Scan array, check before inserting - return true if present, finish scan return false - was never present in the set
*/


#Playground {
    let nums = [1,1,1,3,3,4,3,2,4,2]
    
    func hasDuplicates(in nums: [Int]) -> Bool {
        var seenNumbers: Set<Int> = []
        
        for number in nums {
            guard !seenNumbers.contains(number) else {
                return true
            }
            
            seenNumbers.insert(number)
        }
        
        return false
    }
    
    func getApperances(in nums: [Int]) -> [Int: [Int]] {
        var indexApperances: [Int: [Int]] = [:]
        
        for (index, number) in nums.enumerated() {
            indexApperances[number, default: []].append(index)
        }
        
        return indexApperances
    }
    
    print(getApperances(in: nums))
    
    print(hasDuplicates(in: nums))
}
