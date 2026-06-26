import Testing

// ============================================================
// PROBLEM: 1041. Robot Bounded In Circle
// https://leetcode.com/problems/robot-bounded-in-circle/
// Difficulty: Medium
// Topics: Math, String, Simulation
//
// A robot starts at (0,0) facing North and repeats a set of instructions
// forever. Return true if the robot is bounded in a circle.
//
// Instructions: G (go 1 step), L (turn left), R (turn right)
//
// Example 1: "GGLLGG" → true  (returns to origin after one cycle)
// Example 2: "GG"     → false (drifts north forever)
// Example 3: "GL"     → true  (traces a square over 4 cycles)
// ============================================================

private func isRobotBounded(_ instructions: String) -> Bool {
    enum Direction {
        case north, south, east, west

        var delta: (x: Int, y: Int) {
            switch self {
            case .north: (0,  1)
            case .south: (0, -1)
            case .east:  (1,  0)
            case .west:  (-1, 0)
            }
        }

        var turnedLeft: Direction {
            switch self {
            case .north: .west
            case .west:  .south
            case .south: .east
            case .east:  .north
            }
        }

        var turnedRight: Direction {
            switch self {
            case .north: .east
            case .east:  .south
            case .south: .west
            case .west:  .north
            }
        }
    }

    var position: (x: Int, y: Int) = (0, 0)
    var direction: Direction = .north

    for instruction in instructions {
        switch instruction {
        case "G":
            position.x += direction.delta.x
            position.y += direction.delta.y
        case "L":
            direction = direction.turnedLeft
        case "R":
            direction = direction.turnedRight
        default: break
        }
    }

    // Not facing north → any turn causes 4 cycles to form a closed polygon back to origin.
    return (position.x == 0 && position.y == 0) || direction != .north
}

@Suite("LC1041 Robot Bounded In Circle")
struct LC1041Tests {

    @Test("provided examples")
    func providedExamples() {
        #expect(isRobotBounded("GGLLGG") == true)
        #expect(isRobotBounded("GG")     == false)
        #expect(isRobotBounded("GL")     == true)
    }

    @Test("returns to origin after one cycle")
    func returnsToOrigin() {
        #expect(isRobotBounded("LRLR")  == true)
        #expect(isRobotBounded("LLLL")  == true)  // spins in place
    }

    @Test("drifts forever — faces north off origin")
    func driftsForever() {
        #expect(isRobotBounded("GG")    == false)
        #expect(isRobotBounded("GLGR")  == false) // net north drift
    }

    @Test("square trace over 4 cycles")
    func squareTrace() {
        #expect(isRobotBounded("GL")  == true)
        #expect(isRobotBounded("GR")  == true)
    }

    @Test("no movement")
    func noMovement() {
        #expect(isRobotBounded("L")   == true)
        #expect(isRobotBounded("LLL") == true)
        #expect(isRobotBounded("R")   == true)
    }
}
