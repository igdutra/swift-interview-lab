//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 17/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: 15. 3Sum
// https://leetcode.com/problems/3sum/
// Difficulty: Medium
// Topics: Two Pointers, Array, Sorting
//
// Find all unique triplets in the array that sum to zero.
//
// Example 1:
//   Input:  nums = [-1,0,1,2,-1,-4]
//   Output: [[-1,-1,2],[-1,0,1]]
//
// Example 2:
//   Input:  nums = [0,1,1]
//   Output: []
//
// Example 3:
//   Input:  nums = [0,0,0]
//   Output: [[0,0,0]]
//
// Constraints:
//   - 3 <= nums.length <= 3000
//   - -10^5 <= nums[i] <= 10^5 ->
//
//
// ============================================================

/* PLAN
 
 QUESTIONS
 - Numbers sorted? -> no. we should sort so that we can use two pointers
 - 3 <= nums.length <= 3000 -> brute force ok? i get so
 - ok so none found - return empty
 - deduplicate answers? i'll assume is not necessary, if it was i'd use a set
 
 1. Since this is triplets, we will need brute force. We will scan array once, for each element we will try to find pairs that sum up to current number reversed - so 2sum injested.
 - first I'll do 2sum hashmap - then I'll optimize with the 2 pointers approach as we will sort it. -
 - hashmap : space n
 - pointers: same thing space 1 -> in here we can use pointers as the array will be sorted (n logn) and that loses for O(n^2) which is the algo overall complexity
 
 2. CONDITIONS
 - outer loop: for outerNumber in n...
 - innerloop: call 2sum function with -outerNumber: we need to find 2 numenbrs that togeer will anulate the outernumber
 - 2sum: find valid pairs, hashMap that will reutrn the NUMEBR ITSELF - plain set. WIAT i need to think: there might be, for the same outer number, mORE THAN 2 that returns it. hum. for 2sum have a validPairs, append pair to it, flush current pair on valid pair found.
 for number in..
 -> deduplicate current with OUTER number.
 -> injest 2sum with -outerNumber as target.
    - then scan the array -> if possiblePairsContains currentInnerNumber -> append validPaids[inner, target -x, -target]. do that until complets
 - when 2sum is done, get the outerloop MAP it to append the outerAH! i dont need -> i literally akreayd save the VALID TRIPLES i dont need to append that, i've the yES.
 
 3. state
 validTriplets
 possiblePairElements - 2sum set
 
 4. waling[-1,0,1,2,-1,-4]
 - target --1 -> 1
 2sum: need 2 numbers that add to 1
 skip -1
 check: has possible contains 0? no -> inser 0 - target = 1
 then 1- has possible contais 1? yes -> record [1, 1 - 1 (0), -1] -> valid!
 
 when on 2
 - outer2
 - target -2
 -
 
*/

#Playground {
    let nums = [-1,0,1,2,-1,-4]
    
    func findAllTripletsToSumZero(in nums: [Int]) -> Set<[Int]> {
        // CANNOT be a set - we get [-1, 2] instead of [-1, 2, -1] -> can't duplicate -1
        var validTriplets: Set<[Int]> = []
        
        for (outerIndex, outerNumber) in nums.enumerated() {
            // 2Sum -> must find pairs -outer
            let target = -outerNumber
            var possiblePairElements: Set<Int> = []
            
            for (innerIndex, innerNumber) in nums.enumerated() {
                // Skip same number
                // HWAT OTHER CONDITION we must skip
                // NICE! caught a bug, we must check the iNDEX NOT THE NUMBER
    //                print(outerNumber, innerNumber)
                guard innerIndex != outerIndex else { continue }
                    
                if possiblePairElements.contains(innerNumber) {
                    // ✦ DEDUPLICATION STRATEGY: sort the triplet before inserting so
                    //   [-1,0,1] and [1,0,-1] collapse to the same key in the Set.
                    let validTriplet: [Int] = [innerNumber, target - innerNumber, -target]
                    validTriplets.insert(validTriplet.sorted())
                } else {
                    // BUG 1- I had that inverse
                    // full count is: (target - innerNumber) + innerNumber = target
                    possiblePairElements.insert(target - innerNumber)
                }
            }
        }
        
        return validTriplets
    }
    
    print(findAllTripletsToSumZero(in: nums))
}

// ============================================================
// APPROACH 2: Two Pointers (Optimal)
//
// Why is this better than the hashmap approach above?
//
// Space: the hashmap approach allocates a Set<[Int]> for deduplication
//   AND a Set<Int> per outer iteration for possiblePairElements.
//   Here we need neither — deduplication is handled structurally
//   by sorting + skip conditions, and pair lookup is done in-place
//   with two index pointers. Space = O(1) auxiliary (ignoring output).
//
// Time: same O(n²) overall — the sort is O(n log n) which is dominated.
//   But in practice this is faster because we avoid Set hashing and
//   eliminate all duplicate work up front via the skip conditions.
//
// The elegance: a sorted array gives us *direction*.
//   sum too large → move right pointer left (shrink)
//   sum too small → move left pointer right (grow)
//   We never need to store "possible pairs" because we can steer
//   toward the target deterministically.
//
// Deduplication without a Set — three skip conditions:
//
//   1. OUTER SKIP: if nums[i] == nums[i-1], we already explored every
//      triplet anchored at this value → skip to avoid exact re-runs.
//
//   2. LEFT SKIP: after recording a valid triplet and advancing left,
//      if the new left equals the old left value, it would produce the
//      same triplet again → skip.
//
//   3. RIGHT SKIP: same reasoning for the right pointer moving inward.
//
// ============================================================

#Playground {
    let nums = [-1, 0, 1, 2, -1, -4]

    func findAllTripletsToSumZeroTwoPointers(in nums: [Int]) -> [[Int]] {
        let sorted = nums.sorted()
        var validTriplets: [[Int]] = []

        for outerIndex in 0 ..< sorted.count - 2 {
            // OUTER SKIP (condition 1): same anchor value was already processed
            // in the previous iteration — every triplet it can form is a duplicate.
            if outerIndex > 0 && sorted[outerIndex] == sorted[outerIndex - 1] {
                continue
            }

            // Early exit: smallest possible sum is sorted[i] + sorted[i+1] + sorted[i+2].
            // Since the array is sorted, if the anchor is already > 0 no triplet can sum to 0.
            if sorted[outerIndex] > 0 { break }

            var left = outerIndex + 1
            var right = sorted.count - 1

            while left < right {
                let sum = sorted[outerIndex] + sorted[left] + sorted[right]

                if sum == 0 {
                    validTriplets.append([sorted[outerIndex], sorted[left], sorted[right]])

                    // Move both pointers inward to search for more pairs.
                    left += 1
                    right -= 1

                    // LEFT SKIP (condition 2): new left has the same value as the one
                    // we just used — would produce an identical triplet with the same anchor
                    // and the same right value → skip.
                    while left < right && sorted[left] == sorted[left - 1] { left += 1 }

                    // RIGHT SKIP (condition 3): same reasoning for the right pointer.
                    while left < right && sorted[right] == sorted[right + 1] { right -= 1 }

                } else if sum < 0 {
                    // Sum too small → we need a larger number → advance left.
                    left += 1
                } else {
                    // Sum too large → we need a smaller number → shrink right.
                    right -= 1
                }
            }
        }

        return validTriplets
    }

    print(findAllTripletsToSumZeroTwoPointers(in: nums))
}
