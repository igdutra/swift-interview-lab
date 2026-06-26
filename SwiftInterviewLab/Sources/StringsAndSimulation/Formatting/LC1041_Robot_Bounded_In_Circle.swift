//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 26/06/26.
//

import Foundation
import Playgrounds

//On an infinite plane, a robot initially stands at (0, 0) and faces north. Note that:
//
//The north direction is the positive direction of the y-axis.
//The south direction is the negative direction of the y-axis.
//The east direction is the positive direction of the x-axis.
//The west direction is the negative direction of the x-axis.
//The robot can receive one of three instructions:
//
//"G": go straight 1 unit.
//"L": turn 90 degrees to the left (i.e., anti-clockwise direction).
//"R": turn 90 degrees to the right (i.e., clockwise direction).
//The robot performs the instructions given in order, and repeats them forever.
//
//Return true if and only if there exists a circle in the plane such that the robot never leaves the circle.
//
// 
//
//Example 1:
//
//Input: instructions = "GGLLGG"
//Output: true
//Explanation: The robot is initially at (0, 0) facing the north direction.
//"G": move one step. Position: (0, 1). Direction: North.
//"G": move one step. Position: (0, 2). Direction: North.
//"L": turn 90 degrees anti-clockwise. Position: (0, 2). Direction: West.
//"L": turn 90 degrees anti-clockwise. Position: (0, 2). Direction: South.
//"G": move one step. Position: (0, 1). Direction: South.
//"G": move one step. Position: (0, 0). Direction: South.
//Repeating the instructions, the robot goes into the cycle: (0, 0) --> (0, 1) --> (0, 2) --> (0, 1) --> (0, 0).
//Based on that, we return true.
//Example 2:
//
//Input: instructions = "GG"
//Output: false
//Explanation: The robot is initially at (0, 0) facing the north direction.
//"G": move one step. Position: (0, 1). Direction: North.
//"G": move one step. Position: (0, 2). Direction: North.
//Repeating the instructions, keeps advancing in the north direction and does not go into cycles.
//Based on that, we return false.
//Example 3:
//
//Input: instructions = "GL"
//Output: true
//Explanation: The robot is initially at (0, 0) facing the north direction.
//"G": move one step. Position: (0, 1). Direction: North.
//"L": turn 90 degrees anti-clockwise. Position: (0, 1). Direction: West.
//"G": move one step. Position: (-1, 1). Direction: West.
//"L": turn 90 degrees anti-clockwise. Position: (-1, 1). Direction: South.
//"G": move one step. Position: (-1, 0). Direction: South.
//"L": turn 90 degrees anti-clockwise. Position: (-1, 0). Direction: East.
//"G": move one step. Position: (0, 0). Direction: East.
//"L": turn 90 degrees anti-clockwise. Position: (0, 0). Direction: North.
//Repeating the instructions, the robot goes into the cycle: (0, 0) --> (0, 1) --> (-1, 1) --> (-1, 0) --> (0, 0).
//Based on that, we return true.

/* PLAN

 PATTERN: state machine simulation — track position + direction through one cycle

 SEQUENCE
 - iterate instructions once
 - G: add direction's (dx, dy) to position
 - L/R: transition direction enum to the next cardinal

 - AFTER ONE CYCLE:
   - at origin → bounded ✓
   - not facing north → bounded ✓ (any turn means 4 cycles form a closed polygon)
   - facing north + not at origin → drifts forever ✗

 STATE
 - position: (x: Int, y: Int)
 - direction: enum { north, south, east, west } with computed (dx, dy)

 EDGE CASE
 - "GL": ends off-origin but facing east → still loops (4 cycles draw a square back to origin)
 - "GG": ends off-origin facing north → false

 COMPLEXITY
 - Time O(n) — single scan
 - Space O(1) — only position + direction; iterating String directly avoids the O(n) Array conversion
*/

#Playground {
    let instructions = "GL"
    
    enum Direction {
        case north
        case south
        case east
        case west
        
        var incrementPosition: (x: Int, y: Int) {
            switch self {
            case .north:
                (0, 1)
            case .south:
                (0, -1)
            case .east:
                (1, 0)
            case .west:
                (-1, 0)
            }
        }
    }
    
    func areInstructionsInfiniteLoop(_ instructions: String) -> Bool {
        var position: (x: Int, y: Int) = (0, 0)
        var direction: Direction = .north
        let stringArray = Array(instructions)
        
        for instruction in stringArray {
            print(instruction)
            switch instruction {
            case "G":
                position.x += direction.incrementPosition.x
                position.y += direction.incrementPosition.y
                print(direction, "incrementing", direction.incrementPosition)
                dump(position)
                
            case "L":
                switch direction {
                case .north:
                    direction = .west
                case .south:
                    direction = .east
                case .east:
                    direction = .north
                case .west:
                    direction = .south
                }
                print(direction)
                
            case "R":
                switch direction {
                case .north:
                    direction = .east
                case .south:
                    direction = .west
                case .east:
                    direction = .south
                case .west:
                    direction = .north
                }
                print(direction)
                
            default: break // throw error, should not occur
            }
            
            print()
        }
        
        print("final", direction, position)

        // Not facing north means each repeat rotates the net displacement 90°,
        // so 4 cycles always cancel out and the robot returns to origin.
        return (position.x == 0 && position.y == 0) || direction != .north
    }
        
    print(areInstructionsInfiniteLoop(instructions))
}
