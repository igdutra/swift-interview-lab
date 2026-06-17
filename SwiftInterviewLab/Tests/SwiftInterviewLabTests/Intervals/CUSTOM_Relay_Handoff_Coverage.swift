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
//   - Team availability lists is sorted and do not contain duplicated days.
//   - A valid pair must use two different teams
//   - If no valid pair exists, return an empty array
// ============================================================


// ============================================================
// SOLUTION 1 — BRUTE FORCE
// ============================================================
// TIME AND SPACE COMPLEXITY:
//   Time:  O(t² · d) — for every ordered pair (t²), try every
//          split point in the mission window (d = endDay - startDay).
//          For each split, verify both segments by walking days (d).
//   Space: O(t · a) for the availability sets, where a is the average
//          number of available days per team.
// ============================================================

private func relayPairsBruteForce(
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
            if canCoverMissionBruteForce(
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

private func canCoverMissionBruteForce(
    startDay: Int,
    endDay: Int,
    firstTeam: String,
    secondTeam: String,
    availability: [String: Set<Int>]
) -> Bool {
    guard let firstDays = availability[firstTeam],
          let secondDays = availability[secondTeam]
    else { return false }

    // Try every possible split point: firstTeam covers [startDay…splitDay],
    // secondTeam covers [splitDay+1…endDay].
    for splitDay in startDay..<endDay {
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

        if secondCovers { return true }
    }

    return false
}


// ============================================================
// SOLUTION 2 — OPTIMAL: prefix-suffix precompute (Variant 8.5)
// ============================================================
// KEY INSIGHT:
//   Each team can only play one of two roles in a valid pair:
//     - First team  → must cover [startDay … someHandoffDay] contiguously.
//                     Only the rightmost contiguous reach from startDay matters.
//                     This is prefixEnd[team].
//     - Second team → must cover [someHandoffDay+1 … endDay] contiguously.
//                     Only the leftmost contiguous reach back to endDay matters.
//                     This is suffixStart[team].
//
//   Valid pair condition: prefixEnd[A] + 1 == suffixStart[B]  (A ≠ B)
//   A hands off exactly where B picks up — no gap, no overlap.
//
// ALGORITHM (three steps):
//   1. For each team, compute prefixEnd and suffixStart (O(t · d)).
//   2. Build a lookup: suffixStart value → [team names] (O(t)).
//   3. For each team A with a valid prefixEnd, look up matching B in O(1).
//
// TIME AND SPACE COMPLEXITY:
//   Time:  O(t · d) — precompute walks at most d days per team (t teams).
//                     Step 3 is O(t) total across all teams.
//          Compare to brute force O(t² · d): here we pay O(d) once per team,
//          not once per ordered pair.
//   Space: O(t) — two dictionaries of size t for prefixEnd/suffixStart.
// ============================================================

private func relayPairs(
    startDay: Int,
    endDay: Int,
    teams: [String: [Int]]
) -> [[String]] {
    guard startDay < endDay else { return [] }

    let sortedTeamNames = teams.keys.sorted()

    // Step 1 — precompute prefixEnd and suffixStart for every team.
    var prefixEnd: [String: Int] = [:]     // team → last day it covers from startDay
    var suffixStart: [String: Int] = [:]   // team → first day it covers back to endDay

    for teamName in sortedTeamNames {
        let days = Set(teams[teamName] ?? [])

        // prefixEnd: walk startDay…endDay; stop at the first gap.
        if days.contains(startDay) {
            var reachDay = startDay
            while reachDay < endDay && days.contains(reachDay + 1) {
                reachDay += 1
            }
            prefixEnd[teamName] = reachDay
        }
        // If team doesn't cover startDay, it can never be the first team — skip.

        // suffixStart: walk endDay backwards until the first gap.
        // suffixStart[B] is the earliest day B can start and still cover
        // contiguously through endDay. B is a valid second team for any
        // handoff where prefixEnd[A]+1 >= suffixStart[B] — meaning B already
        // covers the handoff point (and everything after it) contiguously.
        if days.contains(endDay) {
            var reachDay = endDay
            while reachDay > startDay && days.contains(reachDay - 1) {
                reachDay -= 1
            }
            suffixStart[teamName] = reachDay
        }
        // If team doesn't cover endDay, it can never be the second team — skip.
    }

    // Step 2 — build suffix lookup: suffixStart value → [team names].
    // B is a valid second team for handoff day h when suffixStart[B] <= h+1,
    // meaning B already covers day h+1 (and everything through endDay) contiguously.
    // We bucket by suffixStart so Step 3 can query: "who can start at or before h+1?"
    var suffixMap: [Int: [String]] = [:]
    for (teamName, startValue) in suffixStart {
        suffixMap[startValue, default: []].append(teamName)
    }
    for key in suffixMap.keys { suffixMap[key]?.sort() }

    // Step 3 — for each valid first team, find all second teams whose suffixStart
    // is <= prefixEnd[A]+1, meaning they cover from the handoff point to endDay.
    // We iterate suffixStart values that are <= handoff+1 to collect candidates.
    var result: [[String]] = []

    for firstTeam in sortedTeamNames {
        guard let handoffDay = prefixEnd[firstTeam] else { continue }
        let handoffPoint = handoffDay + 1  // B must cover from this day onward

        // Collect all teams whose contiguous-to-endDay reach starts at or before
        // handoffPoint. They all cover [handoffPoint…endDay] contiguously.
        var candidates: [String] = []
        for (startValue, bucket) in suffixMap where startValue <= handoffPoint {
            candidates.append(contentsOf: bucket)
        }
        candidates.sort()

        for secondTeam in candidates where secondTeam != firstTeam {
            result.append([firstTeam, secondTeam])
        }
    }

    return result
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

    @Test("Brute force and optimal agree on official example 1")
    func bruteForceMatchesOptimalExample1() {
        let startDay = 3
        let endDay = 11
        let teams: [String: [Int]] = [
            "North": [3, 4, 5, 6, 7, 10, 11, 12],
            "East": [10, 11, 12, 13],
            "South": [5, 8, 9, 10, 11, 15, 20]
        ]
        #expect(relayPairsBruteForce(startDay: startDay, endDay: endDay, teams: teams) ==
                relayPairs(startDay: startDay, endDay: endDay, teams: teams))
    }

    @Test("Brute force and optimal agree on official example 2")
    func bruteForceMatchesOptimalExample2() {
        let startDay = 1
        let endDay = 8
        let teams: [String: [Int]] = [
            "Red": [1, 2, 3, 4],
            "Blue": [5, 6, 7, 8],
            "Green": [3, 4, 5, 6, 7, 8]
        ]
        #expect(relayPairsBruteForce(startDay: startDay, endDay: endDay, teams: teams) ==
                relayPairs(startDay: startDay, endDay: endDay, teams: teams))
    }
}
