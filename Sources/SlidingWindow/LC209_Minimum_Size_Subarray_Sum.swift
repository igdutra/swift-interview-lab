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
    
    func findMinimumSubarrayLENGHT(target: Int, in nums: [Int]) -> Int {
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
    
    // ❌ FIRST ATTEMPT — broken range update logic
    // Two bugs:
    // 1. Line `minRange = minRange == nil ? currentRange : minRange` sets minRange once and never
    //    updates it again on the else branch — it just falls through to the if.
    // 2. The if condition `minimumLeght <= currentRange.count` is ALWAYS true: minimumLeght was
    //    just set to min(minimumLeght, currentRange.count) one line above, so it is always <=.
    //    Result: minRange gets overwritten on every shrink step — you always keep the LAST valid
    //    window, not the SMALLEST.
//    func findMinimumSubarrayRANGE(target: Int, in nums: [Int]) -> [Int] {
//        var leftPointer = 0
//        var currentSum = 0
//        var minimumLeght = Int.max
//        var minRange: ClosedRange<Int>? = nil
//
//        for (rightPointer, num) in nums.enumerated() {
//            currentSum += num
//
//            while currentSum >= target {
//                minimumLeght = min(minimumLeght, rightPointer - leftPointer + 1)
//                let currentRange = leftPointer ... rightPointer
//                print("before", minRange)
//                minRange = minRange == nil ? currentRange : minRange
//                print("after", minRange)
//
//                print("minimumLeght", minimumLeght, "range count", currentRange.count)
//                print("conditon", minimumLeght < currentRange.count)
//                if minimumLeght <= currentRange.count {
//                    minRange = leftPointer ... rightPointer
//                }
//
//                let leftNumber = nums[leftPointer]
//                currentSum -= leftNumber
//                leftPointer += 1
//            }
//        }
//        print(minRange)
//        guard let range = minRange else { return [] }
//        return Array(nums[range])
//    }

    // ✅ FIX — length and range updated together, atomically
    // Key insight: don't update length and range separately. Check if the current window is
    // strictly smaller than the best, and if so update BOTH in the same if-block.
    // This avoids the split-brain where minimumLeght and minRange can refer to different windows.
    func findMinimumSubarrayRANGE(target: Int, in nums: [Int]) -> [Int] {
        var leftPointer = 0
        var currentSum = 0
        var minimumLength = Int.max
        var minRange: ClosedRange<Int>? = nil

        for (rightPointer, num) in nums.enumerated() {
            currentSum += num

            while currentSum >= target {
                let currentLength = rightPointer - leftPointer + 1
                print("leftPointer", leftPointer, "rightPointer", rightPointer, "sum", currentSum, "currentLength", currentLength, "bestLength", minimumLength)
                if currentLength < minimumLength {
                    minimumLength = currentLength
                    minRange = leftPointer ... rightPointer
                    print("→ new best range", minRange!)
                }
                currentSum -= nums[leftPointer]
                leftPointer += 1
            }
        }
        print("final minRange", minRange as Any)
        guard let range = minRange else { return [] }
        return Array(nums[range])
    }
    
    
    print(findMinimumSubarrayRANGE(target: target, in: nums))
}
