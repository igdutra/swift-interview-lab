//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 16/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 1. Two Sum
// https://leetcode.com/problems/two-sum/
// Difficulty: Easy
// Topics: Array, Hash Table
//
// Return the indices of the two numbers that add up to target.
//
// Example 1:
//   Input:  nums = [2,7,11,15], target = 9
//   Output: [0,1]
//
// Example 2:
//   Input:  nums = [3,2,4], target = 6
//   Output: [1,2]
//
// Example 3:
//   Input:  nums = [3,3], target = 6
//   Output: [0,1]
//
// Constraints:
//   - 2 <= nums.length <= 10^4
//   - -10^9 <= nums[i] <= 10^9
//   - -10^9 <= target <= 10^9
//   - Only one valid answer exists.
//
//
// ============================================================

/* PLAN
 
 QUESTIONS
 - sorted? no guarantee — hashmap works regardless of order
 - return single valid par? admit that there's only one solution or return all valid pairs? - assume early return in single valid pair
 - empty state - if no case return empty?
 
 1- Complement map - we are looking for pairs
 
 2- what is my CONDITION? instead of brute force we can scan the array only once storing the COMPLEMENTS IN A HASHMAP map[target - x] = num
 
 question: could it be a SET storing target - x only? simple check if contains would be sufficient?
 
 3- STATE: complementaryMap set
 
 4- WALK: scan array once, add to seen set
 
 
 ---- THAT IS WHY is good to do the SCAN - if i use set i can find simply boolean contains or not the pair. if i need to return the INDEXES, THEN I NEED TO STORE THEM
 
 correction:
 
 2- conditon is : map[target - x] =  INDEX
 3- this
 4- WALK: scan, IF present in map, get firstIndex = map[target - x], secondIndex = currentIndex, return both
 
 -> i MISSED THE PRINTS!
 
*/

#Playground {
    let nums = [3,2,4], target = 6
    
    func findPair(in nums: [Int], thatSums target: Int) -> [Int] {
        var complementaryMap: [Int: Int] = [:]
        
        for (currentIndex, num) in nums.enumerated() {
            if let firstIndex = complementaryMap[num] {
                return [firstIndex, currentIndex]
            } else {
                let complement = target - num
                complementaryMap[complement] = currentIndex
            }
            print(complementaryMap)
        }
        
        return []
    }
    
    print(findPair(in: nums, thatSums: target))
}
