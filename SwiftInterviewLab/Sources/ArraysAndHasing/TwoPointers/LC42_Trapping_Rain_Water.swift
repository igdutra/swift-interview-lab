//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 18/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 42. Trapping Rain Water
// https://leetcode.com/problems/trapping-rain-water/
// Difficulty: Hard
// Topics: Two Pointers, Array, Dynamic Programming, Stack, Monotonic Stack
//
// Given an elevation map as an array of bar heights, compute
// how much rainwater can be trapped between the bars.
//
// Example 1:
//   Input:  height = [0,1,0,2,1,0,1,3,2,1,2,1]
//   Output: 6
//
// Example 2:
//   Input:  height = [4,2,0,3,2,5]
//   Output: 9
//
// Constraints:
//   - n == height.length
//   - 1 <= n <= 2 * 10^4
//   - 0 <= height[i] <= 10^5
//
//
// ============================================================

/* PLAN

QUESITONs
- no negative
 - can be 0? yes
 - water trapping on edges? - no -> that means that we only care about left and right
 
 1. TWO POINTERS
 - not sliding window: we compute only in one direction we need comparison between left and right the entire time
 - is the EXACT same logic from LC11 - the twist is: since we dont knwo what happens int he middle, compute only the current index that you kNOW FOR A FACT that is trapped - the at every single iteration you compute WHICH SIDE IS THE CEALING.
 
 2. CONDITIONS
 - plain two pointers loop: leftPointer < rightPointer
 how to choose the Ceiling? if maxWallLeft < maxWallRight {
 if they are equal, choose one, does not matter.
 ok so what happens: if left is LESS than right -> lEFT IS CEILING.

- skipping walls: The way we skip them is by advancing the pointer first, then computing water at the new position. The loop only ever computes water at height[leftPointer] after it has moved inward — so it never touches index 0 or index n-1.
- we must ADVANCE LEFT
 - COMPUTE the current wall: max = max(max, currentHeight)
 - currentWaterTrapped = currentWall - curentHeight -> if ehight is the new wall, nO WATER TRAPPED!
 - accumulate total
 flipped logic to
 
 
 3. STATES
 leftPointer/RightPointer
 maxWallLeft/maxWallRight - initialize the current values
 totalWaterTrapped
 
 4.  [0,1,0,2,1,0,1,3,2,1,2,1]
 - It. 1)
 0 < 1 ? yes so we advance left
 left = 1
 maxLeft = 1
 waterTrapped 1 - 1 = 0 total -
 - It. 2)
 1 < 1 ? NO we advance right
 right - 1
 maxright = 2
 waterTrapped 2 - 2 = 0
 
 1 < 2 - yes
 leftpointer = 2, value 0
 maxleft = 1
 water trapped = 1 - 0 = 1 -> water trppaed!

*/

#Playground {
    let input = [0,1,0,2,1,0,1,3,2,1,2,1]
    
    func getTotalTrappedWater(in container: [Int]) -> Int {
        var leftPointer = 0
        var rightPointer = container.count - 1
        var maxWallLeft = container[leftPointer]
        var maxWallRight = container[rightPointer]
        var totalWaterTrapped = 0
        
        while leftPointer < rightPointer {
            if maxWallLeft < maxWallRight {
                // shrink left
                leftPointer += 1
                let currentLeftHeight = container[leftPointer]
                maxWallLeft = max(maxWallLeft, currentLeftHeight)
//                print(leftPointer, currentLeftHeight, maxWallLeft)
                let currentWaterTrapped = maxWallLeft - currentLeftHeight
                totalWaterTrapped += currentWaterTrapped
            } else {
                // shrink right
                rightPointer -= 1
                let currentRightHeight = container[rightPointer]
                maxWallRight = max(maxWallRight, currentRightHeight)
//                print(rightPointer, currentRightHeight, maxWallRight)
                let currentWaterTrapped = maxWallRight - currentRightHeight
                totalWaterTrapped += currentWaterTrapped
            }
        }
        
        return totalWaterTrapped
    }
    
    print(getTotalTrappedWater(in: input))
}
