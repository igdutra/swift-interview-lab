//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 19/06/26.
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

#Playground {
    let heights = [0,1,0,2,1,0,1,3,2,1,2,1]
    
    var currentMaxLeft = heights[0]
    let maxLefts = heights.map { height in
        currentMaxLeft = max(currentMaxLeft, height)
        return currentMaxLeft
    }
    
    print(currentMaxLeft)
    print(maxLefts)
    
    var currentMaxRight = heights.last!
    let maxRightss = heights.reversed().map { height in
        currentMaxRight = max(currentMaxRight, height)
        return currentMaxRight
    }
    let maxRightReversed = Array(maxRightss.reversed())
    
    print(currentMaxRight)
    print(Array(maxRightReversed))
    
    var totalWaterTrapped = 0
    for (index, currentHeight) in heights.enumerated() {
        let minWall = min(maxLefts[index], maxRightReversed[index])
        print(index, minWall)

        totalWaterTrapped += minWall - currentHeight
        print(index, totalWaterTrapped)
    }
}
