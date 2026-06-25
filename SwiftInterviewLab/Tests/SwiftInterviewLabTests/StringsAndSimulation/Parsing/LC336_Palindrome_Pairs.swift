import Testing

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
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time:  O(w · L²) — w words × L split points × L palindrome check
// Space: O(w · L)  — map stores up to L keys per word
// ============================================================

// isPalindrome — two variants, same O(L) time complexity.
//
// Variant A — string reversal:
//   String(chars)         → O(L) allocation
//   string.reversed()     → O(1) lazy ReversedCollection (no copy yet)
//   String(...)           → O(L) materializes the reversed copy
//   ==                    → O(L) character-by-character compare
//   Total: O(L), but 2 heap allocations per call.
//
// Variant B — two pointers:
//   Same O(L) worst case, zero allocations.
//   Early exit on first mismatch = faster in practice.
//   Preferred when called inside a tight loop (as here: w × L times).
private func isPalindromeStringReversal(_ characters: [Character]) -> Bool {
    let string = String(characters)
    return string == String(string.reversed())
}

private func isPalindromeTwoPointers(_ characters: [Character]) -> Bool {
    var left = 0, right = characters.count - 1
    while left <= right {  // covers empty ([]), odd, and even lengths
        if characters[left] != characters[right] { return false }
        left += 1
        right -= 1
    }
    return true
}

private func palindromePairs(_ words: [String]) -> [[Int]] {
    func isPalindrome(_ characters: [Character]) -> Bool {
        isPalindromeTwoPointers(characters)
    }

    // leftWordToRightIndex[key] = [i] means: word[i] needs `key` appended to its LEFT to form a palindrome
    // rightWordToLeftIndex[key] = [i] means: word[i] needs `key` appended to its RIGHT to form a palindrome
    var leftWordToRightIndex: [String: [Int]] = [:]
    var rightWordToLeftIndex: [String: [Int]] = [:]

    for (complementaryIndex, word) in words.enumerated() {
        let wordArray = Array(word)
        for splitPoint in 0...wordArray.count {
            let leftSplit = Array(wordArray.prefix(splitPoint))
            let rightSplit = Array(wordArray.suffix(wordArray.count - splitPoint))

            // if left is a palindrome, we need reverse(right) to appear as a word to our LEFT
            if isPalindrome(leftSplit) {
                let targetLeft = String(rightSplit.reversed())
                if word != targetLeft {
                    leftWordToRightIndex[targetLeft, default: []].append(complementaryIndex)
                }
            }

            // if right is a palindrome, we need reverse(left) to appear as a word to our RIGHT
            if isPalindrome(rightSplit) {
                let targetRight = String(leftSplit.reversed())
                if targetRight != word {
                    rightWordToLeftIndex[targetRight, default: []].append(complementaryIndex)
                }
            }
        }
    }

    var outputIndexes: Set<[Int]> = [] // Set handles duplicates from overlapping split paths
    for (currentIndex, word) in words.enumerated() {
        for rightIndex in leftWordToRightIndex[word, default: []] where rightIndex != currentIndex {
            outputIndexes.insert([currentIndex, rightIndex])
        }
        for leftIndex in rightWordToLeftIndex[word, default: []] where leftIndex != currentIndex {
            outputIndexes.insert([leftIndex, currentIndex])
        }
    }
    return Array(outputIndexes)
}

// ============================================================
// OPTIMIZED: single-map variant
// ============================================================
//
// WHY two maps can collapse into one:
//   Both maps answer the same question — "reverse of the remainder"
//   — just used in two output directions (partner goes LEFT vs RIGHT).
//   The key is always the same kind of thing: a string to look up.
//   The only difference is what pair we emit when we find a hit.
//
//   Instead of two [String: [Int]] maps, we store one:
//     complementMap[key] = [Match]
//   where Match carries the word index AND a direction flag that
//   says whether the partner belongs on the left or the right.
//
// HOW the direction flag works:
//   .needsLeft  — word[i] needs its partner prepended (partner, word[i])
//   .needsRight — word[i] needs its partner appended  (word[i], partner)
//
//   When the final loop finds a hit for word[currentIndex]:
//     .needsLeft  → emit [storedIndex, currentIndex]
//     .needsRight → emit [currentIndex, storedIndex]

private enum PartnerDirection { case needsLeft, needsRight }
private struct PalindromeMatch { let index: Int; let direction: PartnerDirection }

private func palindromePairsOptimized(_ words: [String]) -> [[Int]] {
    func isPalindrome(_ characters: [Character]) -> Bool {
        isPalindromeTwoPointers(characters)
    }

    var complementMap: [String: [PalindromeMatch]] = [:]

    for (wordIndex, word) in words.enumerated() {
        let wordArray = Array(word)
        for splitPoint in 0...wordArray.count {
            let leftSplit = Array(wordArray.prefix(splitPoint))
            let rightSplit = Array(wordArray.suffix(wordArray.count - splitPoint))

            // left palindrome → need reverse(right) to come from the LEFT
            if isPalindrome(leftSplit) {
                let key = String(rightSplit.reversed())
                if key != word {
                    complementMap[key, default: []].append(PalindromeMatch(index: wordIndex, direction: .needsLeft))
                }
            }

            // right palindrome → need reverse(left) to come from the RIGHT
            if isPalindrome(rightSplit) {
                let key = String(leftSplit.reversed())
                if key != word {
                    complementMap[key, default: []].append(PalindromeMatch(index: wordIndex, direction: .needsRight))
                }
            }
        }
    }

    var outputIndexes: Set<[Int]> = []
    for (currentIndex, word) in words.enumerated() {
        for match in complementMap[word, default: []] where match.index != currentIndex {
            switch match.direction {
            // stored word needs a partner on its LEFT → pair is (currentIndex, storedIndex)
            case .needsLeft:  outputIndexes.insert([currentIndex, match.index])
            // stored word needs a partner on its RIGHT → pair is (storedIndex, currentIndex)
            case .needsRight: outputIndexes.insert([match.index, currentIndex])
            }
        }
    }
    return Array(outputIndexes)
}

@Suite("LC336 Palindrome Pairs")
struct LC336Tests {
    private func sorted(_ pairs: [[Int]]) -> [[Int]] {
        pairs.sorted { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
    }

    @Test("Example 1 — mixed lengths")
    func example1() {
        let result = palindromePairs(["abcd", "dcba", "lls", "s", "sssll"])
        #expect(sorted(result) == [[0,1],[1,0],[2,4],[3,2]])
    }

    @Test("Example 2 — exact reverses only")
    func example2() {
        let result = palindromePairs(["bat", "tab", "cat"])
        #expect(sorted(result) == [[0,1],[1,0]])
    }

    @Test("Example 3 — empty string pairs with palindrome")
    func example3() {
        let result = palindromePairs(["a", ""])
        #expect(sorted(result) == [[0,1],[1,0]])
    }

    @Test("Single word — no pairs")
    func singleWord() {
        #expect(palindromePairs(["a"]) == [])
    }

    @Test("Palindrome word + empty string")
    func palindromeWithEmpty() {
        let result = palindromePairs(["aba", ""])
        #expect(sorted(result) == [[0,1],[1,0]])
    }

    @Test("Mixed — palindrome word among others with empty")
    func mixedWithEmpty() {
        let result = palindromePairs(["a", "abc", "aba", ""])
        #expect(sorted(result) == [[0,3],[2,3],[3,0],[3,2]])
    }
}

@Suite("LC336 Palindrome Pairs — optimized single map")
struct LC336OptimizedTests {
    private func sorted(_ pairs: [[Int]]) -> [[Int]] {
        pairs.sorted { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
    }

    @Test("Example 1 — mixed lengths")
    func example1() {
        let result = palindromePairsOptimized(["abcd", "dcba", "lls", "s", "sssll"])
        #expect(sorted(result) == [[0,1],[1,0],[2,4],[3,2]])
    }

    @Test("Example 2 — exact reverses only")
    func example2() {
        #expect(sorted(palindromePairsOptimized(["bat", "tab", "cat"])) == [[0,1],[1,0]])
    }

    @Test("Example 3 — empty string pairs with palindrome")
    func example3() {
        #expect(sorted(palindromePairsOptimized(["a", ""])) == [[0,1],[1,0]])
    }

    @Test("Single word — no pairs")
    func singleWord() {
        #expect(palindromePairsOptimized(["a"]) == [])
    }

    @Test("Mixed — palindrome word among others with empty")
    func mixedWithEmpty() {
        let result = palindromePairsOptimized(["a", "abc", "aba", ""])
        #expect(sorted(result) == [[0,3],[2,3],[3,0],[3,2]])
    }
}
