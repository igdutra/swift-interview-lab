//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 16/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 219. Contains Duplicate II
// https://leetcode.com/problems/contains-duplicate-ii/
// Difficulty: Easy
// Topics: Array, Hash Table, Sliding Window
//
// Return true if there exist two indices i and j such that
// nums[i] == nums[j] and abs(i - j) <= k.
//
// Example 1:
//   Input:  nums = [1,2,3,1], k = 3
//   Output: true
//
// Example 2:
//   Input:  nums = [1,0,1,1], k = 1
//   Output: true
//
// Example 3:
//   Input:  nums = [1,2,3,1,2,3], k = 2
//   Output: false
//
// Constraints:
//   - 1 <= nums.length <= 10^5
//   - -10^9 <= nums[i] <= 10^9
//   - 0 <= k <= 10^5
//
//
// ============================================================

/* PLAN

QUESTIONS
 - sorted? not sorted so maybe two points is not an option - also sorting i'd just do sliding window maybe
 
 1- we can use hash table for it. - we are trying to find PAIRS.
 2- CONDITION
 scan array dict[num] = index -> if dict contains num (they match) i retrieve previous index cOMPARE with k
 3- seenNumberIndexes
 
 4- scan array. save the dict[num] = index -> if dict contains num (they match) i retrieve previous index cOMPARE with k
 
 
*/

#Playground {
    let nums = [1,0,1,1], k = 1
    
    // PRITNS! do pRINTS!
    
    func areNumbersDuplicate(lessThan k: Int, nums: [Int]) -> Bool {
        var seenNumberIndexes: [Int: Int] = [:]
        
        for (currentIndex, number) in nums.enumerated() {
            if let lastSeenIndex = seenNumberIndexes[number] {
                // do i even need this abs here i dont think so - playing safe
                print("current", currentIndex, "last", lastSeenIndex)
                if currentIndex - lastSeenIndex <= k {
                    return true
                }
            }
            seenNumberIndexes[number] = currentIndex
        }
        
        // No number found - return false
        return false
    }
    
    print(areNumbersDuplicate(lessThan: k, nums: nums))
}
