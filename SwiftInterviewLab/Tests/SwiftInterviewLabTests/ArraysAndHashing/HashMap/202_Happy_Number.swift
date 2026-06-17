import Testing

// ============================================================
// PROBLEM: 202. Happy Number
// https://leetcode.com/problems/happy-number/
// Difficulty: Easy
// Topics: Hash Table, Math, Two Pointers
//
// Repeatedly replace a number with the sum of squares of its digits;
// return true if the process eventually reaches 1, false if it cycles forever.
//
// Example 1:
//   Input:  n = 19
//   Output: true  (19 → 82 → 68 → 100 → 1)
//
// Example 2:
//   Input:  n = 2
//   Output: false
//
// Constraints:
//   - 1 <= n <= 2^31 - 1
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(log n) — outer loop is bounded by a constant (~243); inner digit
//                   extraction runs once per digit, which is log10(n)
//
// Space Complexity: O(1) — seenSquares set is bounded by the same constant (~243)
// ============================================================

private func isHappyNumber(_ number: Int) -> Bool {
    var seenSquares: Set<Int> = []
    var currentNumber = number

    while currentNumber != 1 {
        var digits: [Int] = []
        var leftDigits = currentNumber

        while leftDigits != 0 {
            digits.append(leftDigits % 10)
            leftDigits /= 10
        }

        let squaresSum = digits.reduce(0) { $0 + $1 * $1 }

        if seenSquares.contains(squaresSum) {
            return false
        }
        seenSquares.insert(squaresSum)
        currentNumber = squaresSum
    }

    return true
}


// ============================================================
// TESTS
// ============================================================

@Suite("Happy Number")
struct Happy_NumberTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(isHappyNumber(19) == true)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(isHappyNumber(2) == false)
    }

    // --- Edge cases ---

    @Test("n = 1 is happy by definition")
    func nEqualsOne() {
        #expect(isHappyNumber(1) == true)
    }

    @Test("n = 7 is a known happy number")
    func knownHappy() {
        #expect(isHappyNumber(7) == true)
    }

    @Test("n = 4 enters the classic unhappy cycle")
    func knownUnhappy() {
        #expect(isHappyNumber(4) == false)
    }

    @Test("Large happy number")
    func largeHappy() {
        #expect(isHappyNumber(100) == true)
    }

    @Test("Large unhappy number")
    func largeUnhappy() {
        #expect(isHappyNumber(116) == false)
    }
}
