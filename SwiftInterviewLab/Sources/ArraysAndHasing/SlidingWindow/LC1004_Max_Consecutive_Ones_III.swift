//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 14/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 1004. Max Consecutive Ones III
// https://leetcode.com/problems/max-consecutive-ones-iii/
// Difficulty: Medium
// Topics: Array, Binary Search, Sliding Window, Prefix Sum
//
// Find the maximum number of consecutive 1s in a binary array
// if you can flip at most k 0s to 1s.
//
// Example 1:
//   Input:  nums = [1,1,1,0,0,0,1,1,1,1,0], k = 2
//   Output: 6
//
// Example 2:
//   Input:  nums = [0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], k = 3
//   Output: 10
//
// Constraints:
//   - 1 <= nums.length <= 10^5
//   - nums[i] is either 0 or 1
//   - 0 <= k <= nums.length
//
//
// ============================================================

/* PLAN

 QUESTIONS:
 - output all possible values? no, just the length of the longest window

 1- PATTERN: sliding window — we want the longest *contiguous* subarray, so a variable window fits.

 2- CONDITION (when is the window invalid?):
    - track how many 0s we've flipped (currentReplacementCount)
    - window is INVALID when currentReplacementCount > k
    - shrink from the left until valid again: if the element leaving is a 0, decrement the count
    - record the max OUTSIDE the shrink loop, on every step (not only when we see a 0 — the window
      can grow on 1s too, and we'd miss those updates)

 3- STATE: leftPointer, rightPointer (loop index), currentReplacementCount, maxConsecutivesCount

 4- WALK-THROUGH confirmed: recording maxReplacementCount must happen every iteration, regardless
    of whether the current element is 0 or 1. Using `guard num == 0 else { continue }` is the bug —
    it skips the update on every 1.

 5- OPTIMIZATIONS:
    - Pre-store indexes of all 0s → when shrinking, jump leftPointer directly to the next 0 index
      instead of scanning one by one. Saves the inner while-loop steps when there are many 1s between
      zeros. Still O(n) overall but fewer iterations in practice.
    - Not worth it here: the current solution is already O(n) time / O(1) space and each element is
      visited at most twice (once by right, once by left). The pre-store approach trades O(1) space
      for O(z) where z = number of zeros, with no asymptotic gain.
 */


#Playground {
    let nums = [1,1,1,0,0,0,1,1,1,1,0], k = 2
    
    func findConsecutiveOnes(in nums: [Int], with k: Int) -> Int {
        var leftPointer = 0
        var currentReplacementCount = 0
        var maxReplacementCount = 0
        
        for (rightPointer, num) in nums.enumerated() {
            // guard num == 0 else { continue }
            // Bug: skips maxReplacementCount update when num == 1; window size must be recorded on every step.
            if num == 0 {
                currentReplacementCount += 1
            }
            
            while currentReplacementCount > k {
                print("right", rightPointer)
                let leftNumber = nums[leftPointer]
                if leftNumber == 0 {
                    print("left", leftPointer)
                    currentReplacementCount -= 1
                }
                leftPointer += 1
            }
            
            maxReplacementCount = max(maxReplacementCount, rightPointer - leftPointer + 1)
        }
        
        return maxReplacementCount
    }
    
    print(findConsecutiveOnes(in: nums, with: k))
}
