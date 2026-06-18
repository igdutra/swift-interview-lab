import Testing

// ============================================================
// PROBLEM: 125. Valid Palindrome
// https://leetcode.com/problems/valid-palindrome/
// Difficulty: Easy
// Topics: Two Pointers, String
//
// Determine if a string is a palindrome after stripping all
// non-alphanumeric characters and lowercasing.
//
// Example 1:
//   Input:  s = "A man, a plan, a canal: Panama"
//   Output: true
//
// Example 2:
//   Input:  s = "race a car"
//   Output: false
//
// Example 3:
//   Input:  s = " "
//   Output: true
//
// Constraints:
//   - 1 <= s.length <= 2 * 10^5
//   - s consists only of printable ASCII characters
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:  O(n) — each character visited at most once across all three loops
// Space Complexity: O(n) — Array(string) copies the string into a [Character] buffer
//                          (O(1) is achievable using String.Index directly, skipping the array)
// ============================================================

private func isAlphanumeric(_ character: Character) -> Bool {
    character.isLetter || character.isNumber
}

private func isValidPalindrome(_ string: String) -> Bool {
    let stringArray = Array(string) as [Character]
    var leftPointer = 0
    var rightPointer = stringArray.count - 1

    while leftPointer < rightPointer {
        while leftPointer < rightPointer && !isAlphanumeric(stringArray[leftPointer]) {
            leftPointer += 1
        }
        while leftPointer < rightPointer && !isAlphanumeric(stringArray[rightPointer]) {
            rightPointer -= 1
        }

        if stringArray[leftPointer].lowercased() != stringArray[rightPointer].lowercased() {
            return false
        }

        leftPointer += 1
        rightPointer -= 1
    }

    return true
}


// ============================================================
// TESTS
// ============================================================

@Suite("Valid Palindrome")
struct Valid_PalindromeTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        #expect(isValidPalindrome("A man, a plan, a canal: Panama") == true)
    }

    @Test("Official example 2")
    func officialExample2() {
        #expect(isValidPalindrome("race a car") == false)
    }

    @Test("Official example 3")
    func officialExample3() {
        #expect(isValidPalindrome(" ") == true)
    }

    // --- Edge cases ---

    @Test("Empty string")
    func emptyString() {
        #expect(isValidPalindrome("") == true)
    }

    @Test("Single alphanumeric character")
    func singleChar() {
        #expect(isValidPalindrome("a") == true)
    }

    @Test("All punctuation, no alphanumerics")
    func allPunctuation() {
        #expect(isValidPalindrome(",.!") == true)
    }

    @Test("Mixed case palindrome without non-alphanumerics")
    func mixedCase() {
        #expect(isValidPalindrome("AbBa") == true)
    }

    @Test("Two identical characters")
    func twoIdentical() {
        #expect(isValidPalindrome("aa") == true)
    }

    @Test("Two different characters")
    func twoDifferent() {
        #expect(isValidPalindrome("ab") == false)
    }
}
