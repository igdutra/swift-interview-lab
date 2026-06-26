import Testing

// ============================================================
// PROBLEM: 415. Add Strings
// https://leetcode.com/problems/add-strings/
// Difficulty: Easy
// Topics: Math, String, Simulation
//
// Given two non-negative integers num1 and num2 represented as strings,
// return the sum of num1 and num2 as a string.
// You must NOT use built-in big-integer libraries or convert the inputs
// to integers directly.
//
// Example 1:  "11" + "123" → "134"
// Example 2:  "456" + "77"  → "533"
// Example 3:  "0"   + "0"   → "0"
// ============================================================

private func addStrings(_ num1: String, _ num2: String) -> String {
    let array1 = Array(num1), array2 = Array(num2)
    var indexNum1 = array1.count - 1
    var indexNum2 = array2.count - 1
    var carry = 0
    var resultDigits: [Character] = []

    while indexNum1 >= 0 || indexNum2 >= 0 || carry > 0 {
        let digit1 = indexNum1 >= 0 ? array1[indexNum1].wholeNumberValue ?? 0 : 0
        let digit2 = indexNum2 >= 0 ? array2[indexNum2].wholeNumberValue ?? 0 : 0
        let columnSum = digit1 + digit2 + carry
        resultDigits.append(Character(String(columnSum % 10)))
        carry = columnSum / 10
        indexNum1 -= 1
        indexNum2 -= 1
    }

    return String(resultDigits.reversed())
}

@Suite("LC415 Add Strings")
struct LC415Tests {

    @Test("provided examples")
    func providedExamples() {
        #expect(addStrings("11", "123") == "134")
        #expect(addStrings("456", "77") == "533")
        #expect(addStrings("0", "0") == "0")
    }

    @Test("different lengths — shorter on the left")
    func shorterOnLeft() {
        #expect(addStrings("9", "999") == "1008")
    }

    @Test("final carry produces an extra leading digit")
    func finalCarry() {
        #expect(addStrings("99", "1") == "100")
        #expect(addStrings("999", "1") == "1000")
    }

    @Test("single digits")
    func singleDigits() {
        #expect(addStrings("5", "5") == "10")
        #expect(addStrings("1", "9") == "10")
    }

    @Test("one operand is zero")
    func oneOperandZero() {
        #expect(addStrings("0", "123") == "123")
        #expect(addStrings("456", "0") == "456")
    }
}
