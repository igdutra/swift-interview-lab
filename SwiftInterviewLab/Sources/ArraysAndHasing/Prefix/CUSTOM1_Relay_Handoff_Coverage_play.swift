//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 20/06/26.
//

import Foundation
import Playgrounds

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

/* PLAN
 
 - What if a team covers the entire range? → it gets a valid prefix AND suffix, but it can't pair with itself
 - alwyas return pairs? not 3 teams? - yes, always pairs
 
 1. We could leverage a precomputation using prefix/suffix such that we will store the anseers for two questions
 "What does the first team need to know?" → how far forward can it reach from startDay.
 "What does the second team need to know?" → how far backward can it reach from endDay.
 
 2. CONDITIONS / LOOP
 prefix: it is a map [String: Int] where we have the team and map it to (starting on startday) what is the FURTHEST DAY, continously, it contais.
 then, suffix: same map, but we will map it backwars: given endDate for all the teams, what is the EARLIEST continous date?
 
now, we loop through every team
- for each team we GET HE VALUE out of the prefix array: means, handoff date
 
 
 -> CHANGE PLAN HERE - when we get the optimal solution
 - OK SAME BRUTE FORCE: i wanna loop to get the OTHER 2 teams such that i get the suffix and compare with the outer one. bam.
 if handOffDate >= eariestdate -> record answer
 
 3. latestStartRange / earliestEndRange (bad names do better) / missionTeams
 
 3-11
"North": [3, 4, 5, 6, 7, 10, 11, 12],
"East": [10, 11, 12, 13],
"South": [5, 8, 9, 10, 11, 15, 20]
 4. WLAK
 latest
 - north: 7
 - east: X
 - south: X
 handoff = this + 1
 earlies = handoff is 7 + 1 = 8 , enddate is 11
 - north: 10
 - east: 10
 - south: 8
 
 handoff >= 8? yes - record them
 
 */

// ============================================================
// OPTIMAL VERSION — O(t·d + t log t)
//
// Phases 1 & 2 are identical to the O(t·d + t²) version.
// Phase 3 is where we improve:
//   - Sort finishing teams by earliestCoveredDay ascending.
//   - For each starting team, binary search for the rightmost
//     finishing team whose earliestDay <= handoffDay.
//   - Every team from index 0 up to that position is valid.
//   This replaces the O(t²) nested scan with O(t log t) sort + O(t log t) searches.
// ============================================================

// MARK: - NOTE: with time, try to understand this binary serach optimization. for now, skip

#Playground("Optimal") {
    struct Team {
        let name: String
        let availableDates: [Int]
    }

    let teams = [
        Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
        Team(name: "East",  availableDates: [10, 11, 12, 13]),
        Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
    ]

    func getMissionTeamsOptimal(_ teams: [Team], between startDate: Int, and endDate: Int) -> [[String]] {
        var validPairs: [[String]] = []

        // ── PHASE 1: Prefix walk — O(t·d) ────────────────────────────────
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

        // ── PHASE 2: Suffix walk — O(t·d) ────────────────────────────────
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

        // ── PHASE 3: Pair matching — O(t log t) ──────────────────────────
        // Sort finishing teams by earliestDay so we can binary-search the threshold.
        // A finishing team is valid when earliestDay <= handoffDay.
        // Binary search finds the rightmost valid index; everything left of it qualifies.
        let sortedFinishers = teams
            .compactMap { team -> (name: String, earliestDay: Int)? in
                guard let day = earliestDayByTeam[team.name] else { return nil }
                return (team.name, day)
            }
            .sorted { $0.earliestDay < $1.earliestDay }

        for startingTeam in teams {
            guard let handoffDay = handoffDayByTeam[startingTeam.name] else { continue }

            // Binary search: find rightmost index where earliestDay <= handoffDay
            var low = 0, high = sortedFinishers.count - 1, threshold = -1
            while low <= high {
                let mid = (low + high) / 2
                if sortedFinishers[mid].earliestDay <= handoffDay {
                    threshold = mid
                    low = mid + 1
                } else {
                    high = mid - 1
                }
            }

            // All finishers from 0...threshold satisfy the condition
            for index in 0...threshold {
                let finisherName = sortedFinishers[index].name
                guard finisherName != startingTeam.name else { continue }
                validPairs.append([startingTeam.name, finisherName])
            }
        }

        return validPairs
    }

    print(getMissionTeamsOptimal(teams, between: 3, and: 11))
    // Expected: [["North", "South"]]

    let teams2 = [
        Team(name: "Red",   availableDates: [1, 2, 3, 4]),
        Team(name: "Blue",  availableDates: [5, 6, 7, 8]),
        Team(name: "Green", availableDates: [3, 4, 5, 6, 7, 8])
    ]
    print(getMissionTeamsOptimal(teams2, between: 1, and: 8))
    // Expected: [["Red", "Blue"], ["Red", "Green"]]
}

// ============================================================

#Playground {
    struct Team {
        let name: String
        let availableDates: [Int]
    }

    let teams = [
        Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
        Team(name: "East", availableDates: [10, 11, 12, 13]),
        Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
    ]

    func getMissionTeamsPREFIX(_ teams: [Team], beetween startDate: Int, and endDate: Int) -> [[String]] {
        var missionTeams: [[String]] = []
        
        // build prefix and suffix
        var startDateLongestRange: [String: Int] = [:]
        var endDateEarliestRange: [String: Int] = [:]
        for team in teams {
            let availableDates = team.availableDates
            
            let startIndex = availableDates.firstIndex(of: startDate)
            let endIndex = availableDates.firstIndex(of: endDate)
            
            if let startIndex {
                var currentDate = availableDates[startIndex]

                for date in availableDates[(startIndex+1)...] {
                    if date == currentDate + 1, date < endDate {
                        currentDate = date
                    } else {
                        startDateLongestRange[team.name, default: 0] = currentDate
                        break
                    }
                }
            }
            
            if let endIndex {
                var currentDate = availableDates[endIndex]
                // so here i start at endDate and progress until it breaks
//                print(Array(availableDates[...(endIndex-1)].reversed()))
                for date in availableDates[...(endIndex-1)].reversed() {
                    
                    if date == endDate {
                        endDateEarliestRange[team.name, default: 0] = date
                        break
                    }
                    
                    if date == currentDate - 1, date <= endDate { // CHECK <=
                        currentDate = date
                    } else {
                        endDateEarliestRange[team.name, default: 0] = currentDate
                        break
                    }
                }
            }
        }
        
        // finally, loop throgh teams, get values, take conclusions
        
        for startingTeam in teams {
            if let lastCoverageDay = startDateLongestRange[startingTeam.name] {
                let handOffDate = lastCoverageDay + 1
                
                for finishingTeam in teams {
                    guard finishingTeam.name != startingTeam.name else { continue }
                    
                    if let earliestCoverageDay = endDateEarliestRange[finishingTeam.name] {
                        if handOffDate >= earliestCoverageDay {
                            missionTeams.append([startingTeam.name, finishingTeam.name])
                        }
                    }
                }
            }
        }
        
        return missionTeams
    }
    
    print(getMissionTeamsPREFIX(teams, beetween: 3, and: 11))
}

// ============================================================
// CLEAN PREFIX/SUFFIX VERSION — O(k·n + k²) → effectively O(k·n + k)
//
// KEY INSIGHT vs brute force:
//   Brute force walks the dates array for EVERY pair → O(k² · n)
//   Here we walk each team's dates exactly ONCE during precomputation,
//   then pair-matching is just dictionary lookups → O(k·n + k²)
//
// FURTHER INSIGHT (the O(1) trick):
//   Instead of keying the suffix map by team name and scanning all teams
//   to find who matches the handoff date, we key it by the EARLIEST date
//   itself: [earliestCoverageDay: teamName].
//   Then for each starting team we do ONE lookup: suffixMap[handoffDate].
//   The pair step becomes O(k) instead of O(k²).
//
// TWO MAPS WE BUILD:
//   handoffDayByTeam   [teamName: Int]  — "starting from startDate, how far
//                                          contiguously does this team reach?"
//                                          Value = last covered day + 1 (the
//                                          handoff day the second team must start on)
//
//   teamByEarliestDay  [Int: [String]]  — "which teams cover endDate AND
//                                          start their continuous backward
//                                          run from exactly this day?"
//                                          Key = earliest contiguous day reaching endDate
//                                          (a team can start covering on different days,
//                                          so we use an array to handle ties)
// ============================================================

#Playground {
    struct Team {
        let name: String
        let availableDates: [Int]
    }

    let teams = [
        Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
        Team(name: "East",  availableDates: [10, 11, 12, 13]),
        Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
    ]

    func getMissionTeamsCLAUDE(_ teams: [Team], between startDate: Int, and endDate: Int) -> [[String]] {
        var validPairs: [[String]] = []

        // ── PHASE 1: Prefix walk ─────────────────────────────────────────
        // For each team that contains startDate, walk forward while dates
        // are contiguous and strictly before endDate (Team B must own at
        // least endDate itself). Record the handoff day = lastCoveredDay + 1.
        // [teamName → handoffDay]
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

        // ── PHASE 2: Suffix walk ─────────────────────────────────────────
        // For each team that contains endDate, walk BACKWARD while dates are
        // contiguous. Record the earliest day this team can start and still
        // reach endDate without a gap.
        // Same structure as Phase 1: [teamName → earliestCoveredDay].
        // (Keying by day instead of team name looked like an O(1) lookup trick,
        // but Phase 3 needs earliestDay <= handoffDay — a threshold, not exact
        // equality — so an O(k) scan is unavoidable either way.)
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

        // ── PHASE 3: Pair matching — O(k²), no date arrays walked ────────
        // Team B is valid when its earliestCoveredDay <= handoffDay.
        // Why <=, not ==? Because if Team B's contiguous run starts at day 3
        // and handoffDay is 5, Team B still covers day 5 through endDate with
        // no gap — it just has extra coverage before the handoff, which is fine.
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

    print(getMissionTeamsCLAUDE(teams, between: 3, and: 11))
    // Expected: [["North", "South"]]

    let teams2 = [
        Team(name: "Red",   availableDates: [1, 2, 3, 4]),
        Team(name: "Blue",  availableDates: [5, 6, 7, 8]),
        Team(name: "Green", availableDates: [3, 4, 5, 6, 7, 8])
    ]
    print(getMissionTeamsCLAUDE(teams2, between: 1, and: 8))
    // Expected: [["Red", "Blue"], ["Red", "Green"]]
}



// ============================================================

// CODEX SOLUTION
//
// This version keeps the same prefix/suffix preprocessing, but improves
// the matching phase with a sorted sweep:
//
// - starters are sorted by handoffDay
// - finishers are sorted by earliestCoverageDay
// - one pointer walks the finisher list only once
//
// Why this helps:
// - current prefix/suffix version does O(T^2) matching
// - this version does O(T log T + outputSize) matching
// - outputSize matters because if the answer itself has T^2 pairs,
//   no algorithm can avoid spending quadratic time to return them
//
// Final complexity:
// - preprocessing: O(T * D)
// - sorting + sweep: O(T log T + outputSize)
// - total: O(T * D + T log T + outputSize)

#Playground {
    struct Team {
        let name: String
        let availableDates: [Int]
    }

    struct Starter {
        let teamName: String
        let handoffDay: Int
    }

    struct Finisher {
        let teamName: String
        let earliestCoverageDay: Int
    }

    let teams = [
        Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
        Team(name: "East",  availableDates: [10, 11, 12, 13]),
        Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
    ]

    func getMissionTeamsCodex(_ teams: [Team], between startDate: Int, and endDate: Int) -> [[String]] {
        var starters: [Starter] = []
        var finishers: [Finisher] = []

        for team in teams {
            if let startIndex = team.availableDates.firstIndex(of: startDate) {
                var lastCoveredDay = startDate

                for date in team.availableDates[(startIndex + 1)...] {
                    guard date == lastCoveredDay + 1, date < endDate else { break }
                    lastCoveredDay = date
                }

                starters.append(Starter(teamName: team.name, handoffDay: lastCoveredDay + 1))
            }

            if let endIndex = team.availableDates.firstIndex(of: endDate) {
                var earliestCoveredDay = endDate

                for date in team.availableDates[..<endIndex].reversed() {
                    guard date == earliestCoveredDay - 1 else { break }
                    earliestCoveredDay = date
                }

                finishers.append(Finisher(teamName: team.name, earliestCoverageDay: earliestCoveredDay))
            }
        }

        let sortedStarters = starters.sorted {
            if $0.handoffDay == $1.handoffDay {
                return $0.teamName < $1.teamName
            }
            return $0.handoffDay < $1.handoffDay
        }

        let sortedFinishers = finishers.sorted {
            if $0.earliestCoverageDay == $1.earliestCoverageDay {
                return $0.teamName < $1.teamName
            }
            return $0.earliestCoverageDay < $1.earliestCoverageDay
        }

        var validPairs: [[String]] = []
        var eligibleFinishers: [String] = []
        var finisherIndex = 0

        for starter in sortedStarters {
            while finisherIndex < sortedFinishers.count,
                  sortedFinishers[finisherIndex].earliestCoverageDay <= starter.handoffDay {
                eligibleFinishers.append(sortedFinishers[finisherIndex].teamName)
                finisherIndex += 1
            }

            for finisherTeamName in eligibleFinishers where finisherTeamName != starter.teamName {
                validPairs.append([starter.teamName, finisherTeamName])
            }
        }

        return validPairs
    }

    print(getMissionTeamsCodex(teams, between: 3, and: 11))
    // Expected: [["North", "South"]]

    let teams2 = [
        Team(name: "Red",   availableDates: [1, 2, 3, 4]),
        Team(name: "Blue",  availableDates: [5, 6, 7, 8]),
        Team(name: "Green", availableDates: [3, 4, 5, 6, 7, 8])
    ]
    print(getMissionTeamsCodex(teams2, between: 1, and: 8))
    // Expected: [["Red", "Blue"], ["Red", "Green"]]
}

/* BRUTE FORCE PLAN
 
 QUESTIONS
 - do i need to sort in the end, even though it should be (B, A)? no - order matters
 - It always must be pairs? - correct
 - And i should return them all? - yes
 
 1. First I want the brute force solution - for each team
 
 2. CONDITIONs / LOOP
 - outerloop throgh all teams / innerLoop throguh all teams again - skip current team
 - make sure startTeam team CONTAINS startDate - else skip (firstIndexOf - O(n)) - ARGUARBLY if i do while date != startDate? that can too loop the entire array... oH yes it is n * (n + n)
 - make sure endTeam contains endDate - else skip (firstIndexOf)
 - with that, we loop UNTIL we get NOT CONTINOUS -> previous + 1 = current.
 - with that, the LAST date = the new startDate. AND endDate must be present. in the same loop we will now get the other team.
 
3. STATES
 - startDate / endDate / currentPreviousDate / missionTeams / startTeam (will be appended to missionTeams)
 
4. WALK
 -
 
*/

#Playground {
    struct Team {
        let name: String
        let availableDates: [Int]
    }
    
    let teams = [
        Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
        Team(name: "East", availableDates: [10, 11, 12, 13]),
        Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
    ]
    
    func getMissionTeams(_ teams: [Team], beetween startDate: Int, and endDate: Int) -> [[Team]] {
        var missionTeams: [[Team]] = []
        
        for outerTeam in teams {
            let outerTeamDates = outerTeam.availableDates
            
            // Check if startTeam is valid
            let outerStartIndex = outerTeamDates.firstIndex(of: startDate) as Int?
            guard let outerStartIndex else { continue }
            
            // Carry-on States
            var startTeam: Team?
            var innerTeamStartDate: Int?
            
            // Loop startTeam until continuity stops
            var outerTeamPreviousDate = outerTeamDates[outerStartIndex]
            for date in Array(outerTeamDates[outerStartIndex+1..<outerTeamDates.count]) {
                if date == outerTeamPreviousDate + 1, date < endDate { // make sure that startteam won't have it all
                    outerTeamPreviousDate = date
                } else {
                    startTeam = outerTeam
                    innerTeamStartDate = outerTeamPreviousDate + 1
                    break
                }
            }
            
            // PPPRRRIIINTS!
            
            // Defensive programming
            guard let startTeam, let innerTeamStartDate else { continue }
            
            print(startTeam, innerTeamStartDate)
            
            // Inner loop
            print("iinerloop")
            for innerTeam in teams {
                print("inside loop")

                // Validate 2nd team - must have newStartDate and endDate
                guard innerTeam.name != outerTeam.name else { continue }
                print("continue")
                
                let innerTeamDates = innerTeam.availableDates
                let innerStartIndex = innerTeamDates.firstIndex(of: innerTeamStartDate)
                print(innerStartIndex as Any, innerTeamStartDate)

                guard let innerStartIndex,
                      innerTeamDates.contains(endDate)
                else { continue }
                                
                // Loop endTeam undtil found
                var innerCurrentPreviousDate = innerTeamDates[innerStartIndex]
                let innerSlicedDates = Array(innerTeamDates[innerStartIndex+1..<innerTeamDates.count])
                print(innerSlicedDates)
                for date in innerSlicedDates {
                    if date == endDate {
                        print("appending", startTeam.name, innerTeam.name)
                        missionTeams.append([startTeam, innerTeam])
                    }
                    
                    // NEED TO GUAD that endDate is not in the first too
                    if date == innerCurrentPreviousDate + 1, date < endDate {
                        innerCurrentPreviousDate = date
                    } else {
                        break // no need to keep going
                    }
                    //else {
//                        // BUG1 - we need to check right in the beggining!
//                        if date == endDate {
//                            print("appending", startTeam.name, innerTeam.name)
//                            missionTeams.append([startTeam, innerTeam])
//                        }
//                        break
//                    }
                }
            }
        }
        return missionTeams
    }
    
    print(getMissionTeams(teams, beetween: 3, and: 11))
}

// ============================================================
// CLEAN VERSION — same brute force, no prints, descriptive names
// Key fix: handoffDate == endDate is checked BEFORE the inner loop,
// so a one-day second segment is never missed.
// ============================================================

#Playground {
    struct Team {
        let name: String
        let availableDates: [Int]
    }

    let teams = [
        Team(name: "North", availableDates: [3, 4, 5, 6, 7, 10, 11, 12]),
        Team(name: "East",  availableDates: [10, 11, 12, 13]),
        Team(name: "South", availableDates: [5, 8, 9, 10, 11, 15, 20])
    ]

    func getMissionTeams(_ teams: [Team], between startDate: Int, and endDate: Int) -> [[Team]] {
        var validPairs: [[Team]] = []

        for outerTeam in teams {
            let outerDates = outerTeam.availableDates

            // Outer team must contain startDate
            guard let outerStartIndex = outerDates.firstIndex(of: startDate) else { continue }

            // Walk forward while dates are contiguous AND haven't reached endDate
            var outerLastCoveredDate = startDate
            for date in outerDates[(outerStartIndex + 1)...] {
                guard date == outerLastCoveredDate + 1, date < endDate else { break }
                outerLastCoveredDate = date
            }
            // State: outerTeam covers [startDate ... outerLastCoveredDate]

            let handoffDate = outerLastCoveredDate + 1

            for innerTeam in teams {
                guard innerTeam.name != outerTeam.name else { continue }
                let innerDates = innerTeam.availableDates

                // Inner team must start exactly at handoffDate
                guard let innerStartIndex = innerDates.firstIndex(of: handoffDate) else { continue }

                // Fast path: if handoffDate IS endDate, inner team only needs that one day
                if handoffDate == endDate {
                    validPairs.append([outerTeam, innerTeam])
                    continue
                }

                // Inner team must also contain endDate (early exit before walking)
                guard innerDates.contains(endDate) else { continue }

                // Walk inner team forward — must stay contiguous up through endDate
                var innerLastCoveredDate = handoffDate
                for date in innerDates[(innerStartIndex + 1)...] {
                    guard date == innerLastCoveredDate + 1, date <= endDate else { break }
                    innerLastCoveredDate = date
                }
                // State: innerTeam covers [handoffDate ... innerLastCoveredDate]

                if innerLastCoveredDate == endDate {
                    validPairs.append([outerTeam, innerTeam])
                }
            }
        }

        return validPairs
    }

    print(getMissionTeams(teams, between: 3, and: 11))
    // Expected: [("North", "South")]

    let teams2 = [
        Team(name: "Red",   availableDates: [1, 2, 3, 4]),
        Team(name: "Blue",  availableDates: [5, 6, 7, 8]),
        Team(name: "Green", availableDates: [3, 4, 5, 6, 7, 8])
    ]
    print(getMissionTeams(teams2, between: 1, and: 8))
    // Expected: [("Red", "Blue"), ("Red", "Green")]
}
