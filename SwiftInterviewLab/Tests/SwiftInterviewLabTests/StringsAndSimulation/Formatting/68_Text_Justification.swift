//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 28/06/26.
//

import Foundation
import Testing

//Given an array of strings words and a width maxWidth, format the text such that each line has exactly maxWidth characters and is fully (left and right) justified.
//
//You should pack your words in a greedy approach; that is, pack as many words as you can in each line. Pad extra spaces ' ' when necessary so that each line has exactly maxWidth characters.
//
//Extra spaces between words should be distributed as evenly as possible. If the number of spaces on a line does not divide evenly between words, the empty slots on the left will be assigned more spaces than the slots on the right.
//
//For the last line of text, it should be left-justified, and no extra space is inserted between words.
//
//Note:
//
//A word is defined as a character sequence consisting of non-space characters only.
//Each word's length is guaranteed to be greater than 0 and not exceed maxWidth.
//The input array words contains at least one word.
// 
//
//Example 1:
//
//Input: words = ["This", "is", "an", "example", "of", "text", "justification."], maxWidth = 16
//Output:
//[
//   "This    is    an",
//   "example  of text",
//   "justification.  "
//]
//Example 2:
//
//Input: words = ["What","must","be","acknowledgment","shall","be"], maxWidth = 16
//Output:
//[
//  "What   must   be",
//  "acknowledgment  ",
//  "shall be        "
//]
//Explanation: Note that the last line is "shall be    " instead of "shall     be", because the last line must be left-justified instead of fully-justified.
//Note that the second line is also left-justified because it contains only one word.
//Example 3:
//
//Input: words = ["Science","is","what","we","understand","well","enough","to","explain","to","a","computer.","Art","is","everything","else","we","do"], maxWidth = 20
//Output:
//[
//  "Science  is  what we",
//  "understand      well",
//  "enough to explain to",
//  "a  computer.  Art is",
//  "everything  else  we",
//  "do                  "
//]
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity: O(totalCharacters) = O(wordCount * maxWidth) worst case.
//   We scan the words array once, but the work per word is not constant: building
//   each line with joined() / padding touches every character on that line. Across
//   the whole input each character is copied a constant number of times (into the
//   line buffer, then into the justified string), so the total is the sum of all
//   word lengths plus spaces — i.e. the total character count, not the word count.
//
// Space Complexity: O(totalCharacters) for the output lines, plus O(maxWidth) for
//   the current line buffer we accumulate before committing each line.
// ============================================================

import Foundation
import Testing

private func justifyText(words: [String], toMaxWidth maxWidth: Int) -> [String] {
    var outputLines: [String] = []
    var currentLineWords: [String] = []
    var currentLineLength = 0 // sum of word lengths on the current line, no spaces

    // Fully justify a finished line: spread spaces as evenly as possible, and give
    // the leftmost gaps one extra space when the spaces don't divide evenly.
    func justify(_ lineWords: [String]) -> String {
        let gapCount = lineWords.count - 1

        // A single word can't be spread — left-justify it (word + trailing padding).
        guard gapCount > 0 else {
            let paddingLength = maxWidth - lineWords[0].count
            return lineWords[0] + String(repeating: " ", count: paddingLength)
        }

        let charactersLength = lineWords.reduce(0) { runningTotal, word in runningTotal + word.count }
        let totalSpaces = maxWidth - charactersLength
        let baseSpacePerGap = totalSpaces / gapCount
        let extraSpaceGaps = totalSpaces % gapCount // leftmost gaps that get +1 space

        var line = lineWords[0]
        for gapIndex in 0..<gapCount {
            let spacesForThisGap = baseSpacePerGap + (gapIndex < extraSpaceGaps ? 1 : 0)
            line += String(repeating: " ", count: spacesForThisGap)
            line += lineWords[gapIndex + 1]
        }
        return line
    }

    // Left-justify: single spaces between words, then pad the rest. Used for the
    // last line, which follows a different rule than the fully-justified lines.
    func leftJustify(_ lineWords: [String]) -> String {
        let line = lineWords.joined(separator: " ")
        let paddingLength = maxWidth - line.count
        return line + String(repeating: " ", count: paddingLength)
    }

    for (index, word) in words.enumerated() {
        // Width if we add this word: existing words + their gaps + the new word + one new gap.
        let widthWithWord = currentLineLength + currentLineWords.count + word.count

        if widthWithWord > maxWidth {
            outputLines.append(justify(currentLineWords))
            currentLineWords = []
            currentLineLength = 0
        }

        currentLineWords.append(word)
        currentLineLength += word.count

        // The "count - 1" commit idiom: the last word can never overflow, so its
        // line is committed here instead. It must use leftJustify, NOT justify —
        // the last line is left-justified. This is why the overflow commit above
        // and this final commit are kept as two separate branches: same iteration
        // could see an overflow AND be the last word, and they need different rules.
        if index == words.count - 1 {
            outputLines.append(leftJustify(currentLineWords))
        }
    }

    return outputLines
}

@Suite("LC68 — Text Justification")
struct TextJustificationTests {

    @Test("Example 1 — uneven spaces go to the left gaps first")
    func exampleOne() {
        let words = ["This", "is", "an", "example", "of", "text", "justification."]
        let expected = [
            "This    is    an",
            "example  of text",
            "justification.  "
        ]
        #expect(justifyText(words: words, toMaxWidth: 16) == expected)
    }

    @Test("Example 2 — single-word line and left-justified last line")
    func exampleTwo() {
        let words = ["What", "must", "be", "acknowledgment", "shall", "be"]
        let expected = [
            "What   must   be",
            "acknowledgment  ",
            "shall be        "
        ]
        #expect(justifyText(words: words, toMaxWidth: 16) == expected)
    }

    @Test("Example 3 — wider lines with several uneven distributions")
    func exampleThree() {
        let words = ["Science", "is", "what", "we", "understand", "well", "enough", "to", "explain", "to", "a", "computer.", "Art", "is", "everything", "else", "we", "do"]
        let expected = [
            "Science  is  what we",
            "understand      well",
            "enough to explain to",
            "a  computer.  Art is",
            "everything  else  we",
            "do                  "
        ]
        #expect(justifyText(words: words, toMaxWidth: 20) == expected)
    }

    @Test("Single word that fills the whole width")
    func singleWord() {
        #expect(justifyText(words: ["a"], toMaxWidth: 1) == ["a"])
    }
}
