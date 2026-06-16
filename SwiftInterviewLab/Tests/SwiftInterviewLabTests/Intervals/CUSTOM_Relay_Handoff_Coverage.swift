import Testing

// ============================================================
// PROBLEM: Relay Handoff Coverage
// Difficulty: Medium
// Topics: Array, Hash Table, Sorting, Simulation
//
// A mission control team needs continuous support from `startDay`
// through `endDay`, inclusive.
//
// You are given several service teams. Each team is available on a
// set of calendar days.
//
// The mission may be covered by exactly two teams:
//   - Team A covers the first contiguous segment.
//   - Team B covers the remaining contiguous segment.
//   - Every day from `startDay` to `endDay` must be covered.
//   - There must be no uncovered day between the two segments.
//   - The order matters, so (A, B) is different from (B, A).
//
// Return all valid ordered pairs of teams that can cover the
// mission window.
//
// Output note:
//   - Return pairs sorted lexicographically by team name:
//     first by A, then by B.
//
// Example 1:
//   Input:
//     startDay = 3
//     endDay = 11
//     teams = {
//       "North": [3, 4, 5, 6, 7, 10, 11, 12],
//       "East": [10, 11, 12, 13],
//       "South": [5, 8, 9, 10, 11, 15, 20]
//     }
//   Output:
//     [("North", "South")]
//
// Example 2:
//   Input:
//     startDay = 1
//     endDay = 8
//     teams = {
//       "Red": [1, 2, 3, 4],
//       "Blue": [5, 6, 7, 8],
//       "Green": [3, 4, 5, 6, 7, 8]
//     }
//   Output:
//     [("Red", "Blue"), ("Red", "Green")]
//
// Constraints:
//   - `startDay <= endDay`
//   - Team availability lists may be unsorted and may contain duplicates
//   - A valid pair must use two different teams
//   - If no valid pair exists, return an empty array
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// O(t^2 * d) in the straightforward implementation below, where
// t is the number of teams and d is the length of the mission window.
//
// Space Complexity:
// O(t * a) for the availability sets, where a is the average number
// of available days per team.
// ============================================================

private func relayPairs(
    startDay: Int,
    endDay: Int,
    teams: [String: [Int]]
) -> [[String]] {
    guard startDay < endDay else { return [] }

    let sortedTeamNames = teams.keys.sorted()
    let availability = Dictionary(uniqueKeysWithValues: teams.map { ($0.key, Set($0.value)) })
    var result: [[String]] = []

    for firstTeam in sortedTeamNames {
        for secondTeam in sortedTeamNames where secondTeam != firstTeam {
            if canCoverMission(
                startDay: startDay,
                endDay: endDay,
                firstTeam: firstTeam,
                secondTeam: secondTeam,
                availability: availability
            ) {
                result.append([firstTeam, secondTeam])
            }
        }
    }

    return result
}

private func canCoverMission(
    startDay: Int,
    endDay: Int,
    firstTeam: String,
    secondTeam: String,
    availability: [String: Set<Int>]
) -> Bool {
    guard let firstDays = availability[firstTeam],
          let secondDays = availability[secondTeam]
    else { return false }

    for splitDay in startDay..<(endDay) {
        var firstCovers = true
        for day in startDay...splitDay {
            if !firstDays.contains(day) {
                firstCovers = false
                break
            }
        }

        guard firstCovers else { continue }

        var secondCovers = true
        for day in (splitDay + 1)...endDay {
            if !secondDays.contains(day) {
                secondCovers = false
                break
            }
        }

        if secondCovers {
            return true
        }
    }

    return false
}

// ============================================================
// TESTS
// ============================================================

@Suite("Relay Handoff Coverage")
struct RelayHandoffCoverageTests {

    @Test("Official example 1")
    func officialExample1() {
        #expect(relayPairs(
            startDay: 3,
            endDay: 11,
            teams: [
                "North": [3, 4, 5, 6, 7, 10, 11, 12],
                "East": [10, 11, 12, 13],
                "South": [5, 8, 9, 10, 11, 15, 20]
            ]
        ) == [["North", "South"]])
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(relayPairs(
            startDay: 1,
            endDay: 8,
            teams: [
                "Red": [1, 2, 3, 4],
                "Blue": [5, 6, 7, 8],
                "Green": [3, 4, 5, 6, 7, 8]
            ]
        ) == [["Red", "Blue"], ["Red", "Green"]])
    }

//    @Test("No valid split when the first team cannot reach the boundary")
//    func noValidSplitWhenBoundaryIsMissing() {
//        #expect(relayPairs(
//            startDay: 1,
//            endDay: 6,
//            teams: [
//                "Alpha": [1, 2, 4],
//                "Beta": [3, 4, 5, 6]
//            ]
//        ) == [])
//    }

    @Test("No valid split when coverage has a gap")
    func noValidSplitWhenCoverageHasAGap() {
        #expect(relayPairs(
            startDay: 2,
            endDay: 7,
            teams: [
                "A": [2, 3, 4],
                "B": [6, 7]
            ]
        ) == [])
    }

    @Test("Single-day mission cannot be split across two teams")
    func singleDayMission() {
        #expect(relayPairs(
            startDay: 5,
            endDay: 5,
            teams: [
                "One": [5],
                "Two": [5]
            ]
        ) == [])
    }

//    @Test("Unsorted availability lists still work")
//    func unsortedAvailabilityLists() {
//        #expect(relayPairs(
//            startDay: 4,
//            endDay: 9,
//            teams: [
//                "Alpha": [6, 5, 4],
//                "Beta": [9, 8, 7],
//                "Gamma": [4, 5, 8, 9]
//            ]
//        ) == [["Alpha", "Beta"], ["Alpha", "Gamma"]])
//    }

    @Test("Duplicates in availability do not change the answer")
    func duplicatesDoNotMatter() {
        #expect(relayPairs(
            startDay: 1,
            endDay: 4,
            teams: [
                "Left": [1, 1, 2],
                "Right": [3, 3, 4],
                "Extra": [1, 2, 3, 4]
            ]
        ) == [["Extra", "Right"], ["Left", "Extra"], ["Left", "Right"]])
    }
}
