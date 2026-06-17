
import Playgrounds

// ============================================================
// PROBLEM: 11. Container With Most Water
// https://leetcode.com/problems/container-with-most-water/
// Difficulty: Medium
// Topics: Two Pointers, Array, Greedy
//
// Given heights of n vertical lines, find the two lines that
// form a container holding the most water.
//
// Example 1:
//   Input:  height = [1,8,6,2,5,4,8,3,7]
//   Output: 49
//
// Example 2:
//   Input:  height = [1,1]
//   Output: 1
// ============================================================


/*  PLAN
 
 QUESTIONs
 - is it sorted? - no if not would be trivial
 - 3d/diagnoal - no simple area
 - treat empty case to return [] ?
 
 -> MISSED IMPORTANT QUESTION: treat 0 heigHT. but i think that would be handled automatically.
 
 1- Two pointers not sorted - hint: COMPARISON, need two values in opposite
 
 2- LOOP condition: area is min(height) x widht - which is right - left btw without + 1.
 - standard 2two pointes is left < right - we advance ONE single pointer per time.
 - which side to advance? the MINOR wall - that is the only chance to maximaze area
 
 3- states leftPointer/rightPointer, maxArea gets evaluated every scan
 
 4-done.

*/

#Playground {
    let heights = [1,10,1]
    
    func findMaxArea(in container: [Int]) -> Int {
        var leftPointer = 0
        var rightPointer = container.count - 1
        var maxArea = 0
        
        while leftPointer < rightPointer {
//        for _ in container { - debug logic maxArea
            let leftHeight = container[leftPointer]
            let rightHeight = container[rightPointer]
            let currentWidth = rightPointer - leftPointer
            let currentArea = currentWidth * min(leftHeight, rightHeight)
            maxArea = max(maxArea, currentArea)
            
            print("left", leftHeight, "right", rightHeight, "widht", currentWidth, "maxArea", maxArea)
            
            if leftHeight >= rightHeight { // edge case: if they match, just decide on one to move forward
                rightPointer -= 1
            } else {
                leftPointer += 1
            }
        }
        
        return maxArea
    }
    
    print(findMaxArea(in: heights))
}


/* PLAN
 
 GOTCHAS
 - Sorting will break the exercise - you need different values per window.
 
 

 1. PATTERN — Two Pointers (shrinking window from both ends)
    We want the pair of lines that maximises width * min(height).
    Starting with the widest possible window and shrinking is the
    only greedy move that can ever find a better area.

 2. CONDITION — when to move a pointer
    Area = width * shorterWall.
    Width shrinks by 1 every step, so the only hope for a bigger
    area is finding a taller shorterWall.
    Moving the TALLER wall inward can only keep or shrink the
    shorterWall — guaranteed loss.
    Moving the SHORTER wall inward is the only bet that can win.
    → always advance the pointer pointing at the shorter wall.

 3. STATE
    leftPointer  = 0
    rightPointer = height.count - 1
    maxWater     = 0
    Each iteration: compute area, update max, move shorter pointer.

 4. WALK-THROUGH  [1, 8, 6, 2, 5, 4, 8, 3, 7]
     L=0(h=1)  R=8(h=7)  → width=8, min=1 → area=8   → move L (shorter)
     L=1(h=8)  R=8(h=7)  → width=7, min=7 → area=49  → move R (shorter)
     L=1(h=8)  R=7(h=3)  → width=6, min=3 → area=18  → move R
     L=1(h=8)  R=6(h=8)  → width=5, min=8 → area=40  → move R (equal → move L by convention)
     … keeps shrinking; 49 is never beaten.

 5. COMPLEXITY
    O(n) time — left + right share a budget of exactly n-1 steps total.
    O(1) space — no auxiliary storage.

 */

#Playground {
    let heights = [1, 8, 6, 2, 5, 4, 8, 3, 7]

    func maxArea(_ height: [Int]) -> Int {
        var leftPointer  = 0
        var rightPointer = height.count - 1
        var maxWater     = 0

        while leftPointer < rightPointer {
            let width       = rightPointer - leftPointer
            let shorterWall = min(height[leftPointer], height[rightPointer])
            let area        = width * shorterWall

            // Print each candidate to see why greedy moves work
            print("L=\(leftPointer)(h=\(height[leftPointer])) R=\(rightPointer)(h=\(height[rightPointer])) → area=\(area)")

            maxWater = max(maxWater, area)

            if height[leftPointer] <= height[rightPointer] {
                leftPointer  += 1
            } else {
                rightPointer -= 1
            }
        }

        // Final answer print
        print("maxWater = \(maxWater)")
        return maxWater
    }

    print(maxArea(heights))
}
