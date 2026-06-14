//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 13/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 209. Minimum Size Subarray Sum
// https://leetcode.com/problems/minimum-size-subarray-sum/
// Difficulty: Medium
// Topics: Array, Binary Search, Sliding Window, Prefix Sum
//
// Find the minimal length contiguous subarray whose sum is >= target;
// return 0 if no such subarray exists.
//
// Example 1:
//   Input:  target = 7, nums = [2,3,1,2,4,3]
//   Output: 2  (subarray [4,3])
//
// Example 2:
//   Input:  target = 4, nums = [1,4,4]
//   Output: 1
//
// Example 3:
//   Input:  target = 11, nums = [1,1,1,1,1,1,1,1]
//   Output: 0
//
// Constraints:
//   - 1 <= target <= 10^9
//   - 1 <= nums.length <= 10^5
//   - 1 <= nums[i] <= 10^4
//
//
// ============================================================

/* PLAN
 
 1- Slinding Window - continousSubarray
 - can have multiple answers, we need to find the MINIMUM, comparison
 
 2- CONDITION: window is VALID - we store the result inside the loop
 - while currentSum >= target
 
 3- state - leftPointer/rightPointer, currentSum, minResult

*/

#Playground {
    let target = 7
    let nums = [2,3,1,2,4,3]
    
    func findMinimumSubarray(target: Int, in nums: [Int]) -> Int {
        var leftPointer = 0
        var currentSum = 0
        var minimumLeght = Int.max
        
        for (rightPointer, num) in nums.enumerated() {
            currentSum += num
            
            // window is valid - record at each step
            while currentSum >= target {
//                print("leftPointer", leftPointer, "sum", currentSum)
                // -> Printing leftPointer and sum made me realize the bug since we want the minimum we were initlaing minimumLeght with 0 instead of Int.max
                minimumLeght = min(minimumLeght, rightPointer - leftPointer + 1)
                let leftNumber = nums[leftPointer]
                currentSum -= leftNumber
                leftPointer += 1
            }
        }
        
        return minimumLeght == Int.max ? 0 : minimumLeght
    }
    
    
    print(findMinimumSubarray(target: target, in: nums))
}
