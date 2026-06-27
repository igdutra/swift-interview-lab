//
//  LC755_Pour_Water.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 26/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// 755. Pour Water
// Difficulty: Medium
// Topics: Array, Simulation
//
// We have an elevation map, heights[i] representing the height of the
// terrain at that index. The width at each position is 1. After V units
// of water fall at index K, how much water is at each index?
//
// Water first drops at index K and rests according to the following rules:
//   - If the droplet would eventually fall by moving left, then move left.
//   - Otherwise, if the droplet would eventually fall by moving right,
//     then move right.
//   - Otherwise, rise at its current position.
//
// Here, "eventually fall" means that the droplet will eventually be at a
// lower level if it moves in that direction. Also, "level" means the height
// of the terrain plus any water in that column.
//
// We can assume there's infinitely high terrain on the two sides out of
// bounds of the array. Also, there could not be partial water being spread
// out evenly on more than one grid block — each unit of water has to be in
// exactly one block.
//
// Example 1:
//   Input:  heights = [2,1,1,2,1,2,2], V = 4, K = 3
//   Output: [2,2,2,3,2,2,2]
//   Explanation:
//     Drop 1: water at K=3, scans left → finds lower spot at index 2 → settles at 2.
//             heights = [2,1,2,2,1,2,2]
//     Drop 2: water at K=3, scans left → finds lower spot at index 1 → settles at 1.
//             heights = [2,2,2,2,1,2,2]
//     Drop 3: water at K=3, scans left → nothing lower. Scans right → finds lower spot at index 4 → settles at 4.
//             heights = [2,2,2,2,2,2,2]
//     Drop 4: water at K=3, no lower spot on either side → rises at K.
//             heights = [2,2,2,3,2,2,2]
//
// Example 2:
//   Input:  heights = [1,2,3,4], V = 2, K = 2
//   Output: [2,3,3,4]
//   Explanation:
//     The terrain slopes up to the right of K, so both drops flow left and
//     settle at index 0 (the lowest reachable point on the left).
//
// Example 3:
//   Input:  heights = [3,1,3], V = 5, K = 1
//   Output: [4,4,4]
//   Explanation:
//     The valley at K=1 is bounded by walls of height 3 on each side.
//     The first two drops fill the valley to height 3. After that, the
//     whole surface is flat, so every subsequent drop rises at K.
//
// Constraints:
//   - 1 <= heights.length <= 100
//   - 0 <= heights[i] <= 99
//   - 0 <= V <= 2000
//   - 0 <= K < heights.length
// ============================================================

// MARK: - THIRD TRY - Fixed wall bug: reachable min, not global min

/* PLAN

 PATTERN  simulation, V times: roll unit to lowest REACHABLE spot, L then R, else rise@K.
          reachable = scan outward from K, BREAK on rise (wall hides what's behind). O(V*N).

 SEQUENCE  per unit: minL = scanOut(left); minR = scanOut(right)
                     map[minL]<map[K] ? +1 : map[minR]<map[K] ? +1 : map[K]+1

 STATE  map:[Int] (mutated)   scanOut → bestIndex:Int?

 CONDITIONS
   for _ in 0..<V:
       l = scanOut(leftward); r = scanOut(rightward)        // nil at edges
       if l, map[l]<map[K] -> map[l]+=1
       elif r, map[r]<map[K] -> map[r]+=1
       else map[K]+=1
   scanOut: for i outward { if best, map[i]>map[best] {break}; if map[i]<map[best] {best=i} }

 WALK [2,1,1,2,1,2,2] V4 K3:  @2 -> @1 -> @4(R) -> rise@K  => [2,2,2,3,2,2,2] ✓

 EDGES  K=0 noL / K=last noR / wall->break / tie->nearest wins / flat->rise@K
*/

#Playground("Reachable min") {
    let heights = [2,1,1,2,1,2,2], v = 4, k = 3

    // KEY FIX: stop at first rise — a wall blocks everything beyond it.
    // We scan outward tracking bestIndex; the moment terrain goes UP we break.
    // This is reachable-min, not global-min.
    func getReachableMinIndex(in array: [Int], scanning range: ClosedRange<Int>, leftward: Bool) -> Int? {
        var bestIndex: Int? = nil
        let indices = leftward ? Array(range.reversed()) : Array(range)
        for index in indices {
            if let currentBest = bestIndex, array[index] > array[currentBest] { break }
            if bestIndex == nil || array[index] < array[bestIndex!] { bestIndex = index }
        }
        return bestIndex
    }

    func getFinalElevationMap(for heigths: [Int], pouring volume: Int, at kIndex: Int) -> [Int] {
        var currentHeightMap = heigths

        for _ in 1...volume {
            let kHeight = currentHeightMap[kIndex]

            let lowestIndexLeft: Int? = kIndex > 0
                ? getReachableMinIndex(in: currentHeightMap, scanning: 0...(kIndex - 1), leftward: true)
                : nil
            let lowestIndexRight: Int? = kIndex < currentHeightMap.count - 1
                ? getReachableMinIndex(in: currentHeightMap, scanning: (kIndex + 1)...(currentHeightMap.count - 1), leftward: false)
                : nil

//            print("left:", lowestIndexLeft as Any, "right:", lowestIndexRight as Any)

            if let leftIndex = lowestIndexLeft, currentHeightMap[leftIndex] < kHeight {
                currentHeightMap[leftIndex] += 1
            } else if let rightIndex = lowestIndexRight, currentHeightMap[rightIndex] < kHeight {
                currentHeightMap[rightIndex] += 1
            } else {
                currentHeightMap[kIndex] += 1
            }
        }

        return currentHeightMap
    }

    print(getFinalElevationMap(for: heights, pouring: v, at: k)) // [2,2,2,3,2,2,2]
}

// MARK: - SECOND TRY - Found the bug - but i can make it beeter.

#Playground("Prefix try") {
    let heights = [2,1,1,2,1,2,2], v = 4, k = 3

    // WORKING WITH CLOSED RAGES!
    func getSmallerHeightIndex(in array: [Int], considering range: ClosedRange<Int>) -> Int {
        var currentMin = Int.max
        var currentMinIndex = 0

        for index in range {
            if array[index] < currentMin {
                currentMin = array[index]
                currentMinIndex = index
            }
        }
        return currentMinIndex
    }
    // Testing
//    let range = (k+1)...(heights.count - 1)
//    print(getSmallerIndex(in: heights, considering:(range)))

    func getFinalElevationMap(for heigths: [Int], pouring v: Int, at kIndex: Int) -> [Int] {
        var lowestIndexLeft: Int? = 0
        var lowestIndexRight: Int? = 0
        var currentHeightMap = heights

        let leftRange = 0...(k-1)
        let rightRange = (k+1)...(currentHeightMap.count - 1)

        for _ in 1...v {

            lowestIndexLeft = kIndex > 0 ? getSmallerHeightIndex(in: currentHeightMap, considering: leftRange) : nil
            lowestIndexRight = kIndex < (currentHeightMap.count - 1) ? getSmallerHeightIndex(in: currentHeightMap, considering: rightRange) : nil

            let kHeight = currentHeightMap[kIndex]
            let leftMinHeight = currentHeightMap[lowestIndexLeft ?? 0]
            let rightMinHeight = currentHeightMap[lowestIndexRight ?? 0]

    //        print(lowestIndexLeft, lowestIndexRight)

            // 1st: check to pour on k
            if leftMinHeight > kHeight, rightMinHeight > kHeight {
                currentHeightMap[kIndex] += 1
            }

            // 2nd

//            ...
        }

        return currentHeightMap
    }
}

//
//#Playground {
//    let kIndex = 2
//    let test = [1,2, 3,4]
//    let leftSlice = test[...(kIndex-1)]
//    let rigthSlice = test[(kIndex+1)...]
//    
//    // TAKEAWAY: slice PRESERVES INDEXES! Casting to Array we lose them.
//    print(rigthSlice.indices)
//    print(Array(rigthSlice).indices)
//}


// MARK: - First try


/* PLAN + understanding rough 15 minutes ok
 
 # QUESTIONS;
    - no negavtive values? yes
    - need to sanitze the input somehow? accept ints right.
    - guard k belongs to array?
 
 # PATTERN
 string scan + state accumulation
 
 heights = [1,2, ->3,4], V = 2, K = 2
 # CONDITION
 - first, try to drop on k-index
 - second look left
 - thrid, look right
 - else -> drop on k
 
 STATES
 lowestIndexLeft
 lowestIdexRight
 currentHeightMap
 
 
 # WALK
 - is k the LOWEST? if not -> is left < k-height?
    - yes - drop at LOWEST left
 - right > k-height?
 
 # EDGE CASES
 - on flat surface: 2, 2 ,3 -> dropping one should be 2, 3, 3 or 3,2, 3 ?
 
 # COMPLEXITY
 
*/

// BUG FOUND!
//let rightSlice = Array(currentHeightMap[(kIndex+1)...])
//var currentMinRightHeight = rightSlice.min()!
//var currentMinRightHeightIndex = rightSlice.lastIndex(of: currentMinRightHeight)!
//-> when we do such opertion Array( kills ORIGINAL index value
//                                   -> solutin is
//var currentMinRightHeightIndex = currentHeightMap.lastIndex(of: currentMinRightHeight)!

//TAKEAWAY -> after EACH OPERATUON DO PRINT STATEMENTS, litearlly, to verify.actor
// ADTER EVERY SINGLE ONE.


#Playground("first try - BUGS - NOT checking when all is flat should ove to next one") {
//    let heights = [1,2,3,4], V = 2, K = 2
//    let heights = [2,1,1,2,1,2,2], V = 4, K = 3
    let heights = [3,1,3], V = 5, K = 1
    
    func getFinalElevationMap(for heigths: [Int], pouring v: Int, at kIndex: Int) -> [Int] {
//        print(heights, kIndex, heigths[kIndex])
        var lowestIndexLeft = 0
        var lowestIndexRight = 0
        var currentHeightMap = heights
        var currentMinHeightIndex = kIndex
        
        var currentMinHeight = Int.max
        
        for _ in 1...V {
            // o(n) scan 2x - can make it better later min height
            currentMinHeight = currentHeightMap.min()! // TODO: handle force unwrap
            currentMinHeightIndex = currentHeightMap.firstIndex(of: currentMinHeight)! // TODO: handle force unwrap
            let kHeight = currentHeightMap[kIndex]
                        
//            print(currentMinHeight, currentMinHeightIndex)
            
            // 1st try
            if currentMinHeightIndex == kIndex {
                currentHeightMap[kIndex] += 1
                continue // check that
            }
            
            // 2nd try left
            let leftSlice = Array(currentHeightMap.prefix(kIndex))
//            print(leftSlice)
            var currentMinLeftHeight = leftSlice.min()!
            var currentMinLeftHeightIndex = currentHeightMap.firstIndex(of: currentMinLeftHeight)!
            if currentHeightMap[currentMinLeftHeightIndex] < kHeight {
//                print("bumpin left", currentHeightMap[currentMinLeftHeightIndex], kHeight)
                currentHeightMap[currentMinLeftHeightIndex] += 1
//                print("result ", currentHeightMap)
                continue
                // check that
            }
            
            // 3rd try
            let rightSlice = Array(currentHeightMap[(kIndex+1)...])
            var currentMinRightHeight = rightSlice.min()!
            var currentMinRightHeightIndex = currentHeightMap.lastIndex(of: currentMinRightHeight)!
//            print("height", currentMinRightHeight, "index", currentMinRightHeightIndex)
            if currentHeightMap[currentMinRightHeightIndex] < kHeight {
                currentHeightMap[currentMinRightHeightIndex] += 1
                continue
            }

            // 4th fallback
//            print("bumping !!!! ", currentHeightMap[currentMinRightHeightIndex])
            currentHeightMap[kIndex] += 1
        }
        
        return currentHeightMap
    }
    
    print(getFinalElevationMap(for: heights, pouring: V, at: K))
}
