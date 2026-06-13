
import Playgrounds

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
// ============================================================

// ============================================================

/* PLAN
 
 1. HINT HINT - Longest Substring - Continuous, sliding window
 2.
 - LOOP conditions - NO REPEATED character, count must not exceed 2. if it does, shrink till valid
 - when to track valid - loop makes it valid, count after the loop
 3. My state: leftPointer, rightPointer, windowCharacterCount, longestRange, maxCharacterApperances
 
 // UPDATE: to get O(n), no need to track maxCharacterApperances > 1, simply windowCharacterCount[character]! > 1

 */


#Playground {
    let input = "abcabcbb"
    
    func getLongestSubstringWithoutRepeatingCharacters(_ string: String) -> String {
        let stringArray = Array(string)
        var windowCharacterCount: [Character: Int] = [:]
        var leftPointer = 0
        var longestRange: ClosedRange<Int>? = nil
        
        for (rightPointer, character) in stringArray.enumerated() {
            windowCharacterCount[character, default: 0] += 1
            
            // While invalid - shrink
            while windowCharacterCount[character, default: 0] > 1 {
                let leftCharacter = stringArray[leftPointer]
                windowCharacterCount[leftCharacter, default: 0] -= 1
                leftPointer += 1
            }
            
            let windowLength =  rightPointer - leftPointer + 1
            if longestRange == nil || longestRange!.count < windowLength {
                longestRange = leftPointer ... rightPointer
                // 2nd print
//                print(longestRange)
            }
        }
       
        // 1st print check assumptions before whileloop
//        print(windowCharacterCount)
//        print(currentCharacterMaxApperance)

        guard let range = longestRange else { return "" }
        return String(stringArray[range])
    }
    
    print(getLongestSubstringWithoutRepeatingCharacters(input))
}
