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
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// TODO
//
// Space Complexity:
// TODO
// ============================================================

// TODO: implement

//private func solution(_ P: inout [Int], _ S: inout [Int]) -> Int {
//    return 0
//}
//
//
//// ============================================================
//// TESTS
//// ============================================================
//
//@Suite("Car Pooling Optimization")
//struct Car_Pooling_OptimizationTests {
//
//    // --- Official examples ---
//
//    @Test("Official example 1")
//    func officialExample1() {
//        var P = [1, 4, 1]
//        var S = [1, 5, 1]
//        #expect(solution(&P, &S) == 2)
//    }
//
//    @Test("Official example 2")
//    func officialExample2() {
//        var P = [4, 4, 2, 4]
//        var S = [5, 5, 2, 5]
//        #expect(solution(&P, &S) == 3)
//    }
//
//    @Test("Official example 3")
//    func officialExample3() {
//        var P = [2, 3, 4, 2]
//        var S = [2, 5, 7, 2]
//        #expect(solution(&P, &S) == 2)
//    }
//
//    // --- Edge cases ---
//
//    @Test("Single car — must keep it")
//    func singleCar() {
//        var P = [3]
//        var S = [5]
//        #expect(solution(&P, &S) == 1)
//    }
//
//    @Test("All cars full — no redistribution possible")
//    func allCarsFull() {
//        var P = [3, 3, 3]
//        var S = [3, 3, 3]
//        #expect(solution(&P, &S) == 3)
//    }
//
//    @Test("One large car can absorb everyone")
//    func oneLargeCar() {
//        var P = [1, 1, 1, 1]
//        var S = [1, 1, 1, 9]
//        #expect(solution(&P, &S) == 1)
//    }
//
//    @Test("Already minimal — two cars both needed")
//    func alreadyMinimal() {
//        var P = [5, 5]
//        var S = [5, 5]
//        #expect(solution(&P, &S) == 2)
//    }
//
//    @Test("All passengers fit in one car")
//    func allFitInOne() {
//        var P = [1, 1, 1]
//        var S = [1, 1, 9]
//        #expect(solution(&P, &S) == 1)
//    }
//}
