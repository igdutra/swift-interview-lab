import Testing

// ============================================================
// PROBLEM: Relay Handoff Coverage (Prefix/Suffix variant)
// Difficulty: Medium
// Topics: Array, Hash Table, Prefix, Suffix
//
// A mission control team needs continuous support from `startDate`
// through `endDate`, inclusive.
//
// You are given several service teams. Each team is available on a
// sorted, deduplicated list of calendar days.
//
// The mission may be covered by exactly two teams:
//   - Team A covers the first contiguous segment from startDate.
//   - Team B covers the remaining contiguous segment through endDate.
//   - Every day from startDate to endDate must be covered.
//   - There must be no uncovered day between the two segments.
//   - The order matters, so (A, B) is different from (B, A).
//
// Return all valid ordered pairs of team names.
//
// Example 1:
//   Input:
//     startDate = 3, endDate = 11
//     teams = [
//       Team("North", [3,4,5,6,7,10,11,12]),
//       Team("East",  [10,11,12,13]),
//       Team("South", [5,8,9,10,11,15,20])
//     ]
//   Output: [["North", "South"]]
//
// Example 2:
//   Input:
//     startDate = 1, endDate = 8
//     teams = [
//       Team("Red",   [1,2,3,4]),
//       Team("Blue",  [5,6,7,8]),
//       Team("Green", [3,4,5,6,7,8])
//     ]
//   Output: [["Red", "Blue"], ["Red", "Green"]]
//
// Constraints:
//   - startDate <= endDate
//   - Each team's availability list is sorted and has no duplicates.
//   - A valid pair must use two different teams.
//   - If no valid pair exists, return an empty array.
// ============================================================
// TIME AND SPACE COMPLEXITY
//   t = number of teams, d = dates per team
//
// Time:  O(t·d + t²)
//          Precomputation (phases 1 + 2): walk each team's dates once → O(t·d)
//          Pair matching (phase 3): nested loop over teams, dict lookups only → O(t²)
//        Compare to brute force O(t²·d): here the date walk is paid per team,
//        not per pair.
//
// Space: O(t) — two dictionaries, one entry per team.
// ============================================================

private struct Team {
    let name: String
    let availableDates: [Int]
}

// ── ALGORITHM — three phases ────────────────────────────────────────────────
//
// PHASE 1 — Prefix walk  [teamName → handoffDay]
//   For each team containing startDate, walk forward while days are contiguous
//   and strictly before endDate. handoffDay = lastCoveredDay + 1: the first
//   day Team B must own.
//
// PHASE 2 — Suffix walk  [teamName → earliestCoveredDay]
//   Same structure as Phase 1. For each team containing endDate, walk BACKWARD
//   while days are contiguous. earliestCoveredDay is the soonest this team can
//   start and still reach endDate without a gap.
//   (Keying by day instead looked like an O(1) trick, but Phase 3 needs
//   earliestDay <= handoffDay — a threshold, not equality — so O(k) is
//   unavoidable regardless of key choice. Matching structures is cleaner.)
//
// PHASE 3 — Pair matching  O(k²), no date arrays walked
//   Team B is valid when earliestCoveredDay <= handoffDay.
//   Why <=, not ==? If Team B's contiguous run starts at day 3 and handoffDay
//   is 5, Team B still covers [5…endDate] with no gap — extra early coverage
//   is fine.
// ──────────────────────────────────────────────────────────────────────────

private func relayPairsPrefix(
    _ teams: [Team],
    between startDate: Int,
    and endDate: Int
) -> [[String]] {
    var validPairs: [[String]] = []

    // ── PHASE 1: Prefix walk ────────────────────────────────────────────────
    var handoffDayByTeam: [String: Int] = [:]

    for team in teams {
        guard let startIndex = team.availableDates.firstIndex(of: startDate) else { continue }

        var lastCoveredDay = startDate
        for date in team.availableDates[(startIndex + 1)...] {
            guard date == lastCoveredDay + 1, date < endDate else { break }
            lastCoveredDay = date
        }
        handoffDayByTeam[team.name] = lastCoveredDay + 1
    }

    // ── PHASE 2: Suffix walk ────────────────────────────────────────────────
    var earliestDayByTeam: [String: Int] = [:]

    for team in teams {
        guard let endIndex = team.availableDates.firstIndex(of: endDate) else { continue }

        var earliestCoveredDay = endDate
        for date in team.availableDates[..<endIndex].reversed() {
            guard date == earliestCoveredDay - 1 else { break }
            earliestCoveredDay = date
        }
        earliestDayByTeam[team.name] = earliestCoveredDay
    }

    // ── PHASE 3: Pair matching ──────────────────────────────────────────────
    for startingTeam in teams {
        guard let handoffDay = handoffDayByTeam[startingTeam.name] else { continue }

        for finishingTeam in teams {
            guard finishingTeam.name != startingTeam.name else { continue }
            guard let earliestDay = earliestDayByTeam[finishingTeam.name] else { continue }
            if earliestDay <= handoffDay {
                validPairs.append([startingTeam.name, finishingTeam.name])
            }
        }
    }

    return validPairs
}


// ============================================================
// TESTS
// ============================================================

@Suite("Relay Handoff Coverage — Prefix/Suffix")
struct RelayHandoffCoveragePrefixTests {

    // --- Official examples ---

    @Test("Official example 1 — North hands off to South")
    func officialExample1() {
        let teams = [
            Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
            Team(name: "East",  availableDates: [10, 11, 12, 13]),
            Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
        ]
        #expect(relayPairsPrefix(teams, between: 3, and: 11) == [["North", "South"]])
    }

    @Test("Official example 2 — Red hands off to Blue and Green")
    func officialExample2() {
        let teams = [
            Team(name: "Red",   availableDates: [1, 2, 3, 4]),
            Team(name: "Blue",  availableDates: [5, 6, 7, 8]),
            Team(name: "Green", availableDates: [3, 4, 5, 6, 7, 8])
        ]
        // Sort because Phase 3 iterates a dictionary — order is not guaranteed
        let result = relayPairsPrefix(teams, between: 1, and: 8).sorted { $0[1] < $1[1] }
        #expect(result == [["Red", "Blue"], ["Red", "Green"]])
    }

    // --- Edge cases ---

    @Test("Gap between teams — no valid pair")
    func gapBetweenTeams() {
        // A covers [2,3,4], B starts at 6 — day 5 is uncovered
        let teams = [
            Team(name: "A", availableDates: [2, 3, 4]),
            Team(name: "B", availableDates: [6, 7])
        ]
        #expect(relayPairsPrefix(teams, between: 2, and: 7) == [])
    }

    @Test("No team contains startDate — no valid pair")
    func noTeamContainsStartDate() {
        let teams = [
            Team(name: "A", availableDates: [5, 6, 7]),
            Team(name: "B", availableDates: [8, 9, 10])
        ]
        #expect(relayPairsPrefix(teams, between: 1, and: 10) == [])
    }

    @Test("No team contains endDate — no valid pair")
    func noTeamContainsEndDate() {
        let teams = [
            Team(name: "A", availableDates: [1, 2, 3]),
            Team(name: "B", availableDates: [4, 5, 6])
        ]
        #expect(relayPairsPrefix(teams, between: 1, and: 9) == [])
    }

    @Test("Minimum two-day mission — exact single-day handoff")
    func twoDayMission() {
        // A covers day 1, hands off to B who covers day 2
        let teams = [
            Team(name: "A", availableDates: [1]),
            Team(name: "B", availableDates: [2])
        ]
        #expect(relayPairsPrefix(teams, between: 1, and: 2) == [["A", "B"]])
    }

    @Test("Team with internal gap stops at the gap — doesn't jump over it")
    func internalGapStopsRun() {
        // North: [3,4,5,6,7,10,11,12] — gap after 7, so prefix ends at 7, handoff = 8
        // East: [10,11,12,13] — earliest suffix run from 10 (doesn't reach 8) → not valid
        // South: [5,8,9,10,11] — suffix walks back from 11→10→9→8, earliest = 8 → valid
        let teams = [
            Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
            Team(name: "East",  availableDates: [10, 11, 12, 13]),
            Team(name: "South", availableDates: [5, 8, 9, 10, 11])
        ]
        #expect(relayPairsPrefix(teams, between: 3, and: 11) == [["North", "South"]])
    }

    @Test("Multiple teams can be Team A — each finds their own handoff")
    func multipleValidFirstTeams() {
        // Both Red and Purple start at 1 and reach 3, handing off at 4
        // Blue covers [4,5,6] from 4 → valid second team for both
        let teams = [
            Team(name: "Purple", availableDates: [1, 2, 3]),
            Team(name: "Red",    availableDates: [1, 2, 3]),
            Team(name: "Blue",   availableDates: [4, 5, 6])
        ]
        let result = relayPairsPrefix(teams, between: 1, and: 6)
        #expect(result.contains(["Purple", "Blue"]))
        #expect(result.contains(["Red", "Blue"]))
        #expect(result.count == 2)
    }
}
