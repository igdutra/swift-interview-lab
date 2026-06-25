//
//  LC336_Palindrome_Pairs.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 24/06/26.
//

import Foundation
import Playgrounds


// ============================================================
// PROBLEM: 336. Palindrome Pairs
// https://leetcode.com/problems/palindrome-pairs/
// Difficulty: Hard
// Topics: Array, Hash Table, String, Trie
//
// You are given a 0-indexed array of UNIQUE strings `words`.
//
// A palindrome pair is a pair of integers (i, j) such that:
//   - 0 <= i, j < words.length,
//   - i != j, and
//   - words[i] + words[j] (the concatenation of the two strings)
//     is a palindrome.
//
// Return an array of all the palindrome pairs of `words`.
// You must write an algorithm with O(sum of words[i].length) runtime
// complexity. (Interview-acceptable target: O(w · L²).)
//
// Example 1:
//   Input:  words = ["abcd","dcba","lls","s","sssll"]
//   Output: [[0,1],[1,0],[3,2],[2,4]]
//   Explanation: palindromes are
//     ["abcddcba","dcbaabcd","slls","llssssll"]
//
// Example 2:
//   Input:  words = ["bat","tab","cat"]
//   Output: [[0,1],[1,0]]
//   Explanation: palindromes are ["battab","tabbat"]
//
// Example 3:
//   Input:  words = ["a",""]
//   Output: [[0,1],[1,0]]
//   Explanation: palindromes are ["a","a"]
//
// Constraints:
//   - 1 <= words.length <= 5000
//   - 0 <= words[i].length <= 300
//   - words[i] consists of lowercase English letters.
//
// ============================================================

// LEETCODE COMPILER NOTE (Swift type inference quirk)
// The playground used `[String: [Int]]` maps with `[key, default: []]` subscript.
// LeetCode's Swift compiler rejected both `as? [Int]` coercion and `?? []` fallback.
// Fix: use `for x in map[word, default: []]` directly — no if-let, no cast.
// Same logic. Result: 134/136 passed (TLE on pathological giant input, not WA).
//
// WORKING LEETCODE SUBMISSION:
//
// class Solution {
//     func palindromePairs(_ words: [String]) -> [[Int]] {
//         func isPalindrome(_ chars: [Character]) -> Bool {
//             String(chars) == String(chars.reversed())
//         }
//         var leftMap: [String: [Int]] = [:]
//         var rightMap: [String: [Int]] = [:]
//         for (index, word) in words.enumerated() {
//             let chars = Array(word)
//             for split in 0...chars.count {
//                 let left = Array(chars.prefix(split))
//                 let right = Array(chars.suffix(chars.count - split))
//                 if isPalindrome(left) {
//                     let key = String(right.reversed())
//                     if key != word { leftMap[key, default: []].append(index) }
//                 }
//                 if isPalindrome(right) {
//                     let key = String(left.reversed())
//                     if key != word { rightMap[key, default: []].append(index) }
//                 }
//             }
//         }
//         var result: Set<[Int]> = []
//         for (index, word) in words.enumerated() {
//             for j in leftMap[word, default: []] where j != index { result.insert([index, j]) }
//             for j in rightMap[word, default: []] where j != index { result.insert([j, index]) }
//         }
//         return Array(result)
//     }
// }


/* PLAN

 ─────────────────────────────────────────────────────────────
 HINTS (the two nudges — not the answer)
 ─────────────────────────────────────────────────────────────

 HINT 1 — the constraint.
   Brute force = test every ORDERED pair's concatenation. With up to
   5000 words that's ~25M pair tests before the per-pair palindrome cost
   — too slow. You need to ask "is there a word that completes THIS word
   into a palindrome?" WITHOUT scanning every other word. Which data
   structure turns a search into an O(1)-ish lookup?

 HINT 2 — the decomposition (the ONE IDEA).
   A concatenation A + B is a palindrome when one piece supplies a
   PALINDROMIC part and the other supplies a MIRROR/REVERSE part.
   So for a word W split as left + right:
     - if one SIDE is itself a palindrome, then the partner you need
       is the REVERSE of the OTHER side.
   Index something derived from each word so that "find the reverse of
   the remainder" becomes a lookup. Scan all split points of each word.


 ─────────────────────────────────────────────────────────────
 GOTCHAS — the difference between "looks right" and Accepted
 ─────────────────────────────────────────────────────────────

 GOTCHA 1 — THE EMPTY STRING "".
   "" is a valid word AND it is a palindrome. It pairs with EVERY
   palindromic word, in BOTH orders. Most failed solutions either miss
   its pairs entirely or mishandle the order. Test ["a",""] → expect
   [[0,1],[1,0]].

 GOTCHA 2 — ORDERED PAIRS.
   (i, j) and (j, i) are DIFFERENT answers. A partner attaching in
   FRONT vs. BEHIND are two separate cases you must check separately.
   Don't assume symmetry collapses them into one.

 GOTCHA 3 — DOUBLE-COUNTING.
   The same pair can be discovered through two different code paths
   (think exact reverses like ["abc","cba"] — you want exactly
   [[0,1],[1,0]], NOT four entries). You need ONE guard to suppress the
   duplicate. Figuring out WHERE the overlap happens is the real puzzle
   (hint: it's the empty-remainder split).

 GOTCHA 4 — SELF-PAIRING.
   A word that is itself a palindrome can "match itself." Guard against
   emitting [i, i]. Test ["a"] → expect [].

 GOTCHA 5 — SWIFT SPECIFICS.
   - String is NOT integer-indexable: do `Array(word)` for O(1) indexing
     in your palindrome check.
   - Watch the RANGE of split points: inclusive vs. exclusive of the
     empty side is exactly where the empty-string bug (GOTCHA 1) hides.
     Off-by-one at the boundary = WA.

*/

/* PLAN
 QUESTIONS
 - why ["", 'a'] valid? a + ""= "a", valid both ways.
 
 // JUDGE THE PLAN FOR THE FIRST PART: I'LL SIMPLY do a two pointers for palinfrome checjk, then 2sum basically to get the reverse: i'll store the keys as the REVERSED: if there's a value, i'll retur the indexes fromt he matches.
 -> that is NOT the full solution but it is something. I'll write this plan.
 
 1 — PATTERN: two pointers + hashmap
two pointers because is palindrome, hashmap to store search lookup
 
 SEQUECE
 first, let me build a RESUSABLE isPalindrome function
 given an array of charactesr, two pointers, move inward compare them. if they are different, return false. default return true
 - EDGE CASE: even array that works, for odd array
 CONDITION - what if while left <= right - that covers for odd, even or empty cases
 
 now to the pairs: the string will be a palindrome if the first stirng itself
 - the string itself is a palindrome
 
 

 2 — CONDITION (when is A+B a palindrome? the two split cases): ...

 3 — STATE (data structures: the lookup map, the result, helpers): ...

 4 — WALK-THROUGH (trace ["bat","tab","cat"] in your head): ...

 5 — EDGE CASES
 - Test against
    - ["abc","cba"]
    - ["a",""]
    - and ["a"] before you trust it.
 
 COMPLEXITY

*/

/// NEW PLAN
///
/*
 lls
 
 ll (ok) "s" (ok)
 
 */

/* PLAN
 
 # PATTERN
 - two pointer to identify palindromes
 - prefix hashmap storing precomputed answers - all possible values that would turn that a palindrome.
 
 # SEQUENCE
 we will grab each word.
 for each word, we will precompute all possible values that - if appended to the word - makes it a palindrome = slice it in all possible ways - that is count + 1 => for slicing using native .prefix/suffix
 > if one side is palindrome, then we just need the other side .reversed() to match
 e.g for "abc"
 "", "abc" - "" OK, if i append "abc".reversed() to the LEFT of "abc", we have ourselvs a palindrome.
    -> store leftComplementaryStrings["abc".reversed()] = currentIndex
 "a", "bc" - "a" OK, "bc".reversed() apeeding LEFT will give us palindrome
 "ab", "c"
 "abc", ""
 
 # STATE
 leftComplemextatyStirngs: [String: Int] where we store the complementary RIGHT index.
 rigthComplementarystrings: [String: Int] where we store the complementary LEFT index.
 
 if let rightIndex = leftComplementaryStrings[word], the current word must be in the left, and then we have right index so we return [currentIndex, rigthIndex] is a valid palindrome pair.
 

 # WALK
 input: "abcd", "dcba",
 leftMap: ["dcba": 0]
 rightMap: ["abcd": 1]
 final loop: for (currentIndex, word) in input.enumerated() {
 if let rightIndex = leftMap[word] { - [current
    output.append([ currentIndex, rightIndex)
 ..
 if let leftIndex = rigthMap[word] {
    outout.append([leftIndex, currentIdex)]
 
 that makes [1,0] and [1,0]
 -> NOW: i need to TRACE IT fundamentaliy for DUPLICATES -> i might return a set instead of array if the oRDER IS NOT IMPORTANT.

 EDGE CASES
 
 COMPLEXITY
- fully analalise when doing code but sounds line 3n - n + n for each map + final n to get indexes
 - space: O(k) where k is the max quantity of possible palindromes
 
*/

// MARK: - SHOW TIME

#Playground("Show time") {
    
    // MARK: - Helpers
    
    func isPalindrome(_ characters: [Character]) -> Bool {
        let string = String(characters)
        let reversed = String(string.reversed())
        return string == reversed
    }
    
    func isPalindrome2Pointers(_ characters: [Character]) -> Bool {
        let array = Array(characters)
        var leftPointer = 0, rightPointer = characters.count - 1
        while leftPointer <= rightPointer {
            if array[leftPointer] != array[rightPointer] { return false }
            leftPointer += 1
            rightPointer -= 1
        }
        return true
    }

    // MARK: - Main
    
//    let input = ["abc", "cba"]
//    let input = ["", "a"]
//    let input = ["lls", "s"]
//    let input = ["abcd","dcba","lls","s","sssll"]
//    let input = ["a",""]
//    let input = ["a","abc","aba",""]
    let input = ["abcd","dcba","lls","s","sssll"]




    func getPalindromePairIndexes(_ input: [String]) -> [[Int]] { // Set?
        var outputIndexes: Set<[Int]> = [] // handles duplicates out of the box
        
        // 1st. compute left/right maps
        var leftWordToRightIndex: [String: [Int]] = [:]
        var rightWordToLeftIndex: [String: [Int]] = [:]
        for (complementaryIndex, word) in input.enumerated() {
            // get all splits
            let wordArray = Array(word)
            for splitPoint in 0...wordArray.count {
                let leftSplit = Array(wordArray.prefix(splitPoint))
                let rightSplit = Array(wordArray.suffix(wordArray.count - splitPoint))
//                print(leftSplit, rightSplit) // check
                
                let leftIsPalindrome = isPalindrome(leftSplit)
                let rightIsPalindrome = isPalindrome(rightSplit)
                
                // safety check: make sure to not override/append our own duplicate
                let currentWord = word
                
                // eg "", "abc" -> "" leftIsPalindrome, so we append 'abc`.reversed() to the left, and the output right index is the current
                if leftIsPalindrome {
                    let targetLeft = String(rightSplit.reversed())
                    if word != targetLeft {
                        leftWordToRightIndex[targetLeft, default: []].append(complementaryIndex)
                    }
                }
                
                if rightIsPalindrome {
                    let targetRight = String(leftSplit.reversed())
                    if targetRight != word {
                        rightWordToLeftIndex[targetRight, default: []].append(complementaryIndex)
                    }
                }
                
                print(leftSplit, rightSplit)
                print(leftWordToRightIndex, rightWordToLeftIndex)
                print("END - ")
                print()
            }
        }
        
        // final loop
        
        for (currentIndex, word) in input.enumerated() {
            if let rightIndexes = leftWordToRightIndex[word] as? [Int] {
                for rightIndex in rightIndexes where rightIndex != currentIndex {
                    outputIndexes.insert([currentIndex, rightIndex])
                }
            }
            
            if let leftIndexes = rightWordToLeftIndex[word] as? [Int] {
                for leftIndex in leftIndexes where leftIndex != currentIndex {
                    outputIndexes.insert([leftIndex, currentIndex])
                }
            }
        
//            print(word, outputIndexes)
        }
        
        return Array(outputIndexes)
    }

    print(getPalindromePairIndexes(input))
}


// MARK: - END SHOW

#Playground("isPalindrome") {
//    EXAMPLE
//    isPalindrome(["r", "a", "c", "e", "c", "a", "r"], 2, 4) → true
    let even: [Character] = ["a", "b", "b", "a"]
    let odd: [Character] = ["a", "b", "c", "b", "a"]
    let empty: [Character] = []
    
// even.reversed() // hum swift syntax says o(1) to get string reversed. is that true?!
//    that is even better then waht i wanted
    
    func isPalindromeO1(_ characters: [Character], _ low: Int, _ high: Int) -> Bool {
        let string = String(characters)
        let reversed = String(string.reversed())
        return string == reversed
    }
    
    let array = empty
    print(isPalindromeO1(array, 0, array.count - 1))
    
    func isPalindrome(_ characters: [Character], _ low: Int, _ high: Int) -> Bool {
        var left = low, right = high
        while left <= right { // left <= right checks for BOTH EMPTY + ODD cases.
            
            
//            -> HERE  annotate bug/edge canse handling
            // claude said it is missing check low > high return true. i must understand the rest of the problem
            // curring slices and comparing them reversed is the SAME complexity as the two pointers one.
            
            
            if characters[left] != characters [right] { return false }
            left += 1
            right -= 1
        }
        return true
    }
    
    let array2 = empty
    print(isPalindrome(array2, 0, array2.count - 1))
}

#Playground("Major testing") {
    func isPalindromeO1(_ characters: [Character]) -> Bool {
        let string = String(characters)
        let reversed = String(string.reversed())
        return string == reversed
    }
    
//    "", "lls"
//    "l", "ls"
//    "ll", "s"
//    "lls", ""
//    -> FREQUEING 0 DEFAULT CASE ON PREFIX
    let array = Array("lls")
    for splitPoint in 0...array.count {
        let leftSplit = Array(array.prefix(splitPoint))
        let rigthSplit = Array(array.suffix(array.count - splitPoint))
        print(leftSplit, rigthSplit)
        
        print("left is", leftSplit, isPalindromeO1(leftSplit))
        print("rightIs is", rigthSplit, isPalindromeO1(rigthSplit))
    }
    
    for (index, _) in array.enumerated() {
      
    }
    
    
    
    
    
}


#Playground {
    let words = ["abcd", "dcba", "lls", "s", "sssll"]

    // Reusable two-pointer palindrome check — decide what it returns
    // for an EMPTY range (low > high). That choice drives everything.
    func isPalindrome(_ characters: [Character], _ low: Int, _ high: Int) -> Bool {
        // TODO: implement
        return true
    }

    func palindromePairs(_ words: [String]) -> [[Int]] {
        // TODO: this is yours to make history with.
        return []
    }

    print(palindromePairs(words))
    // expected: [[0,1],[1,0],[3,2],[2,4]]  (order of pairs may differ)
}
