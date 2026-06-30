import Testing

// ============================================================
// PROBLEM: Car Pooling Optimization
// Difficulty: Medium
// Topics: Greedy, Sorting
//
// Given N cars with P[K] passengers and S[K] seats, return the minimum
// number of cars needed to carry all passengers.
//
// Example 1:
//   Input:  P = [1, 4, 1], S = [1, 5, 1]
//   Output: 2  (person from car 0 moves to car 1)
//
// Example 2:
//   Input:  P = [4, 4, 2, 4], S = [5, 5, 2, 5]
//   Output: 3  (both passengers from car 2 redistribute into cars 0 and 3)
//
// Example 3:
//   Input:  P = [2, 3, 4, 2], S = [2, 5, 7, 2]
//   Output: 2  (cars 0 and 3 empty into cars 1 and 2)
//
// Constraints:
//   - N is an integer within the range [1..100,000]
//   - each element of arrays P and S is an integer within the range [1..9]
//   - P[K] <= S[K] for every K within the range [0..N-1]
//
// ============================================================
// WHY THIS IS GREEDY
//
// A greedy algorithm builds the answer one choice at a time, always taking
// the move that looks best right now and never reconsidering it. It works
// when a locally optimal choice provably leads to a globally optimal answer.
//
// Here, passengers can be shuffled between cars at will, so the only thing
// that matters is total seating capacity, not which seat anyone started in.
// We must carry `totalPassengers` people, so we want the fewest cars whose
// seats add up to at least that. The greedy choice is obvious: always grab
// the car with the most seats next. Each large car buys down the remaining
// demand faster than any smaller one could, so taking the biggest seats
// first can never lose to any other selection of the same size — that is the
// exchange argument that makes greedy correct here.
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity: O(N log N) — dominated by sorting the seat counts.
//   Summing passengers and scanning the sorted seats are both O(N).
//
// Space Complexity: O(N) — we keep a sorted copy of the seat counts.
//   (O(1) extra if we sort in place, ignoring the sort's own overhead.)
// ============================================================

//The Pattern Fingerprint
//
//    -> Passenger counts are noise.
//    -> Seats are the only resource. Minimize cars used = maximize seats consumed per car chosen = pick biggest first.

private func minimumCarsNeeded(passengers passengersPerCar: [Int],
                               seats seatsPerCar: [Int]) -> Int {
    let totalPassengers = passengersPerCar.reduce(0, +)

    // Greedy: spend the largest cars first so demand drops as fast as possible.
    let seatsLargestFirst = seatsPerCar.sorted(by: >)

    var seatsAccumulated = 0
    var carsUsed = 0

    for availableSeats in seatsLargestFirst {
        if seatsAccumulated >= totalPassengers { break }
        seatsAccumulated += availableSeats
        carsUsed += 1
    }

    return carsUsed
}


// ============================================================
// TESTS
// ============================================================

@Suite("Car Pooling Optimization")
struct Car_Pooling_OptimizationTests {

    // --- Official examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(minimumCarsNeeded(passengers: [1, 4, 1], seats: [1, 5, 1]) == 2)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(minimumCarsNeeded(passengers: [4, 4, 2, 4], seats: [5, 5, 2, 5]) == 3)
    }

    @Test("Official example 3")
    func officialExample3() {
        #expect(minimumCarsNeeded(passengers: [2, 3, 4, 2], seats: [2, 5, 7, 2]) == 2)
    }

    // --- Edge cases ---

    @Test("Single car — must keep it")
    func singleCar() {
        #expect(minimumCarsNeeded(passengers: [3], seats: [5]) == 1)
    }

    @Test("All cars full — no redistribution possible")
    func allCarsFull() {
        #expect(minimumCarsNeeded(passengers: [3, 3, 3], seats: [3, 3, 3]) == 3)
    }

    @Test("One large car can absorb everyone")
    func oneLargeCar() {
        #expect(minimumCarsNeeded(passengers: [1, 1, 1, 1], seats: [1, 1, 1, 9]) == 1)
    }

    @Test("Already minimal — two cars both needed")
    func alreadyMinimal() {
        #expect(minimumCarsNeeded(passengers: [5, 5], seats: [5, 5]) == 2)
    }

    @Test("All passengers fit in one car")
    func allFitInOne() {
        #expect(minimumCarsNeeded(passengers: [1, 1, 1], seats: [1, 1, 9]) == 1)
    }
}
