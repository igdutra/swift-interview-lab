import Testing

// ============================================================
// PROBLEM: 3. Longest Substring Without Repeating Characters
// https://leetcode.com/problems/longest-substring-without-repeating-characters/
// Difficulty: Medium
// Topics: Hash Table, String, Sliding Window
//
// Given a string s, find the length of the longest substring
// without repeating characters.
//
// Example 1:
//   Input:  s = "abcabcbb"
//   Output: 3  ("abc")
//
// Example 2:
//   Input:  s = "bbbbb"
//   Output: 1  ("b")
//
// Example 3:
//   Input:  s = "pwwkew"
//   Output: 3  ("wke")
//
// Constraints:
//   - 0 <= s.length <= 5 * 10^4
//   - s consists of English letters, digits, symbols and spaces
//
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// O(n)
// 
// Space Complexity: 
// 0(k) where k is the size of the character set (number of distinct characters in the string)
// ============================================================

private func lengthOfLongestSubstring(_ s: String) -> Int {
    var leftPointer = 0
    var windowSeenCharactersCount: [Character: Int] = [:]
    let stringArray = Array(s)
    var maxLenght = 0
    var maxCountInWindow = 0
    
    for (rightPointer, rightNumber) in stringArray.enumerated() {
        windowSeenCharactersCount[rightNumber, default: 0] += 1
        maxCountInWindow = max(maxCountInWindow, windowSeenCharactersCount[rightNumber] ?? 0)
        
        // TIP! Before I used `while windowSeenCharactersCount.values.contains(2)` which is O(n)
        // That gives me n * n which is nˆ2
        // Usually this loop can be switched by computing another local variable as we are doing with maxCountInWindow
        while maxCountInWindow >= 2 {
            let leftNumber = stringArray[leftPointer]
            if let count = windowSeenCharactersCount[leftNumber], count > 1 {
                windowSeenCharactersCount[leftNumber, default: 0] -= 1
                maxCountInWindow = windowSeenCharactersCount[leftNumber] ?? maxCountInWindow
            } else {
                windowSeenCharactersCount[leftNumber, default: 0] -= 1
            }
            leftPointer += 1
        }
        
        maxLenght = max(maxLenght, rightPointer - leftPointer + 1)
    }
    
    return maxLenght
}


// ============================================================
// TESTS
// ============================================================

@Suite("Longest Substring Without Repeating Characters")
struct LongestSubstringTests {
    
    // --- Official LeetCode examples ---
    
    @Test("Official example 1")
    func officialExample1() {
        #expect(lengthOfLongestSubstring("abcabcbb") == 3)
    }
    
    @Test("Official example 2")
    func officialExample2() {
        #expect(lengthOfLongestSubstring("bbbbb") == 1)
    }
    
    @Test("Official example 3")
    func officialExample3() {
        #expect(lengthOfLongestSubstring("pwwkew") == 3)
    }
    
    // --- Edge cases ---
    
    @Test("Empty string")
    func emptyString() {
        #expect(lengthOfLongestSubstring("") == 0)
    }
    
    @Test("Single character")
    func singleCharacter() {
        #expect(lengthOfLongestSubstring("a") == 1)
    }
    
    @Test("Two identical characters")
    func twoIdentical() {
        #expect(lengthOfLongestSubstring("aa") == 1)
    }
    
    @Test("Two distinct characters")
    func twoDistinct() {
        #expect(lengthOfLongestSubstring("au") == 2)
    }
    
    @Test("Palindrome trap — abba")
    func palindromeTrap() {
        #expect(lengthOfLongestSubstring("abba") == 2)
    }
    
    @Test("No repeats at all")
    func noRepeats() {
        #expect(lengthOfLongestSubstring("abcdefg") == 7)
    }
    
    @Test("Repeat at the start")
    func repeatAtStart() {
        #expect(lengthOfLongestSubstring("aab") == 2)
    }
    
    @Test("Non-contiguous repeat — dvdf")
    func nonContiguousRepeat() {
        #expect(lengthOfLongestSubstring("dvdf") == 3)
    }
    
    @Test("Repeat in the middle — tmmzuxt")
    func repeatInMiddle() {
        #expect(lengthOfLongestSubstring("tmmzuxt") == 5)
    }
    
    @Test("Best window at the end")
    func bestWindowAtEnd() {
        #expect(lengthOfLongestSubstring("aaabc") == 3)
    }
    
    @Test("Best window at the start")
    func bestWindowAtStart() {
        #expect(lengthOfLongestSubstring("abcaaa") == 3)
    }
    
    @Test("Space character counts as distinct")
    func spaceCharacter() {
        #expect(lengthOfLongestSubstring("a b") == 3)
    }
    
    @Test("Digits and letters mixed")
    func digitsAndLetters() {
        #expect(lengthOfLongestSubstring("a1b2c3") == 6)
    }
}
