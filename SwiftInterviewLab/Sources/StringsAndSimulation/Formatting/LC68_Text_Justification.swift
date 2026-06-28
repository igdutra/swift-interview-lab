//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 27/06/26.
//

import Foundation
import Playgrounds
// Given an array of strings words and a width maxWidth, format the text such that each line has exactly maxWidth characters and is fully (left and right) justified.

// You should pack your words in a greedy approach; that is, pack as many words as you can in each line. Pad extra spaces ' ' when necessary so that each line has exactly maxWidth characters.

// Extra spaces between words should be distributed as evenly as possible. If the number of spaces on a line does not divide evenly between words, the empty slots on the left will be assigned more spaces than the slots on the right. ()left first)

// For the last line of text, it should be left-justified, and no extra space is inserted between words.

// Note:

// A word is defined as a character sequence consisting of non-space characters only.
// Each word's length is guaranteed to be greater than 0 and not exceed maxWidth.
// The input array words contains at least one word.
 

// Example 1:

// Input: words = ["This", "is", "an", "example", "of", "text", "justification."], maxWidth = 16
// Output:
// [
//    "This    is    an",
//    "example  of text",
//    "justification.  "
// ]
// Example 2:

// Input: words = ["What","must","be","acknowledgment","shall","be"], maxWidth = 16
// Output:
// [
//   "What   must   be",
//   "acknowledgment  ",
//   "shall be        "
// ]
// Explanation: Note that the last line is "shall be    " instead of "shall     be", because the last line must be left-justified instead of fully-justified.
// Note that the second line is also left-justified because it contains only one word.
// Example 3:

// Input: words = ["Science","is","what","we","understand","well","enough","to","explain","to","a","computer.","Art","is","everything","else","we","do"], maxWidth = 20
// Output:
// [
//   "Science  is  what we",
//   "understand      well",
//   "enough to explain to",
//   "a  computer.  Art is",
//   "everything  else  we",
//   "do                  "
// ]


/* PLAN

QUESTIONS
- no need to validade input
- ASCII characaters - no need to filter the array
- no append '\n' - return is array

# PATTERN
scan + accumulators

// Input: words = ["This", "is", "an", "example", "of", "text", "justification."], maxWidth = 16
// Output:
// [
//    "This    is    an",
//    "example  of text",
//    "justification.  "
// ]
# SEQUENCE
- scan words
    - for each word -> character array -> append to line bufferCount
        - when scanning the NEXT word - ADD in the bufferCount +1 for the space (min requirement)
        - compare against maxWidht
        - if currentBufferCount exceedes maxWidht -> COMMIT sentence with ' ' as joined()
    - On Commit line: could be a separate function, justify()
        - receive the slicedArray "This, is, an".
        - spaceCount = 2
        - joined("").count = 8 - target 16
        - eachSpace = (target - currentCOunt / spaceCount
        - IF (target - currentCount) % 2 > 0 -> append to the firstSpace.
        - reset current states -> careful that the cURRENTWORD scan must be the firsst in the newLine AFTER the reset.
    - last line
        - check index if last - isLastLine = true - commit.
        - on commit i can have a guard to isLastLine.
        - if isLastLine -> avoid
        
# WALK
"This", "is", "an"
- 4 + 1 + 2 + 1 + 2 = 10
- 10 + 1 + 7 -> overflow. commit "thisisan"
- justify -> 16 - 8 / 2 = space = 4
- join wors with spcace =. 4 - appedn

"example", "of", "text"
- 7 + 1 + 2 + 4 - 14
- justif -> overflow
14-16

"justification" -> no nextLine

# EDGE CASES
- left/right spaces need to be different -> add left  "example  of text"
- handle LAST line -> left justification -> aware of words end, isLastLine or something.
 
 # TIME AND SPACE COMPLEXITY
 words x
*/

/* REVIEW NOTES — bugs found in the first attempt below

 1. loop: `currentLineCount += 1` adds a trailing space for EVERY word, including
    the first one on a line. The first word on a line has no gap before it, so the
    fit count is off by one. (n words => n-1 gaps, not n.)

 2. loop: after committing, `currentLineCount` is reset to 0 but the overflowing
    `word` IS appended to currentLineWords — its own length is never added back to
    the fresh count. The new line starts undercounted by the first word's length.

 3. last line: the `index == words.count - 1` branch runs in the SAME iteration as
    a possible commit, so the final line can be double-handled (committed once by
    the overflow check and again as the last line).

 4. justify(): `words[...augmentedSpacesCount]` is a closed range with an index that
    can run out of bounds, and the prefix/suffix split is more complex than needed.
    The standard move is: distribute one extra space to the leftmost `remainingCount`
    gaps, left-first — no array splitting required.

 5. single-word line: spaceCount == 0 => division by zero in spaceWidth. A line with
    one word must be left-justified (word + padding), not run through justify().

 NOTE FOR THE PLAN: the decomposition was correct — greedy scan + accumulator +
 a justify() helper + special last-line handling is exactly right, and that is the
 hard part. The misses were all arithmetic-detail bugs, not strategy. For next time,
 add two explicit lines to the PLAN's STATE/EDGE sections:
   - "gaps = words.count - 1" (NOT words.count) and guard the single-word case
   - "the word that overflows belongs to the NEXT line — count it after reset"
*/

#Playground("Everythig") {
    let words = ["This", "is", "an", "example", "of", "text", "justification."]
    // let words = ["This", "is", "an", "example", "of"]

    func justifyText(words: [String], toMaxWidth maxWidht: Int) -> [String] {
        var isLastLine = false
        var outputText: [String] = []
        
        func justify(_ words: [String]) -> String {
            let spaceCount = words.count - 1
            let currentCharactersCount = words.joined().count
            let spaceWidht = (maxWidht - currentCharactersCount) / spaceCount
            let spaceSeparator = String(repeating: " ", count: spaceWidht)
            
            let remainingCount = (maxWidht - currentCharactersCount) % spaceCount
            if remainingCount != 0 {
                var augmentedSpacesCount = spaceCount - remainingCount
                augmentedSpacesCount = (augmentedSpacesCount + 1) <= words.count ? augmentedSpacesCount : 1 // TODO CHECK THIS
                let prefixArray = words[...augmentedSpacesCount]
                let suffixArray = words[(augmentedSpacesCount+1)...]
                
                let augmentedSpaceSeparator = String(repeating: " ", count: (spaceWidht+1))
    //            print("\(augmentedSpaceSeparator)a")
                let firstChunk = prefixArray.joined(separator: augmentedSpaceSeparator)
                let secondChunk = suffixArray.joined(separator: spaceSeparator)
                
                let response = [firstChunk, secondChunk].joined(separator: " ")
    //            print(response)
            }
            
            return words.joined(separator: spaceSeparator)
        }
        
        // print(justify(["This", "is", "an"]))
        
        var lineCharacterCount = 0
        var currentLineWords: [String] = []
        var currentLineCount = 0
        for (index, word) in words.enumerated() {
            let characatersArray = Array(word)
            currentLineCount += characatersArray.count
            currentLineCount += 1 // TODO space: that is wrong on single line we must not do that.
            // print("RUNNING", word)
            // print(currentLineCount, maxWidht, currentLineCount >= maxWidht)
            if currentLineCount >= maxWidht {
                // print("justifiying")
                let justified = justify(currentLineWords)
                outputText.append(justified)
                // RESET
                // print("resetting")
                currentLineWords = []
                currentLineCount = 0
            }
                   
            currentLineWords.append(word)
            
            if index == words.count - 1 {
                // print(word, print(currentLineWords))
                let finalLine = currentLineWords.joined(separator: " ")
                let finalLineSpaceCount = maxWidht - finalLine.count
                let finalSpaceString = String(repeating: " ", count: finalLineSpaceCount)
                let finalLineString = [finalLine, finalSpaceString].joined()
                outputText.append(finalLineString)
            }
        }
            
        return outputText
    }

    print(justifyText(words: words, toMaxWidth: 16))

}


// MARK: - Helpers

#Playground("Simply justification func") {
    let words = ["example", "of", "text"]
    let maxWidht = 16
        
    func justify(_ words: [String]) -> String {
        let spaceCount = words.count - 1
        let currentCharactersCount = words.joined().count
        let spaceWidht = (maxWidht - currentCharactersCount) / spaceCount
        let spaceSeparator = String(repeating: " ", count: spaceWidht)
        
        let remainingCount = (maxWidht - currentCharactersCount) % spaceCount
        if remainingCount != 0 {
            var augmentedSpacesCount = spaceCount - remainingCount
            augmentedSpacesCount = (augmentedSpacesCount + 1) <= words.count ? augmentedSpacesCount : 1 // TODO CHECK THIS
            let prefixArray = words[...augmentedSpacesCount]
            let suffixArray = words[(augmentedSpacesCount+1)...]
            
            let augmentedSpaceSeparator = String(repeating: " ", count: (spaceWidht+1))
//            print("\(augmentedSpaceSeparator)a")
            let firstChunk = prefixArray.joined(separator: augmentedSpaceSeparator)
            let secondChunk = suffixArray.joined(separator: spaceSeparator)
            
            let response = [firstChunk, secondChunk].joined(separator: " ")
//            print(response)
        }
        
        return words.joined(separator: spaceSeparator)
    }
    
    print(justify(words))
}



//
////complexity like w * lenght (joined loop) ver isso ai ente der
//
//let words = ["This", "is", "an", "example"]
//
//func justifyText(words: [String], toMaxWidth maxWidht: Int) -> [String] {
//    var isLastLine = false
//    var outputText: [String] = []
//    
//    func justify(_ words: [String]) -> String {
//        let spaceCount = words.count - 1
//        let currentCharactersCount = words.joined().count
//        let spaceWidht = (maxWidht - currentCharactersCount) / spaceCount
//        let spaceSeparator = String(repeating: " ", count: spaceWidht)
//        // TODO: edge case, unequal
//        return words.joined(separator: spaceSeparator)
//    }
//    
//    // print(justify(["This", "is", "an"]))
//    
//    var lineCharacterCount = 0
//    var currentLineWords: [String] = []
//    var currentLineCount = 0
//    for (index, word) in words.enumerated() {
//        let characatersArray = Array(word)
//        currentLineCount += characatersArray.count
//        currentLineCount += 1 // TODO space: that is wrong on single line we must not do that.
//        print("RUNNING", word)
//        print(currentLineCount, maxWidht, currentLineCount >= maxWidht)
//        if currentLineCount >= maxWidht {
//            print("justifiying")
//            let justified = justify(currentLineWords)
//            outputText.append(justified)
//            // RESET
//            print("resetting")
//            currentLineWords = []
//        } else {
//            print("test")
//        }
//        
//        currentLineWords.append(word)
//        
//        // can i use the index to ADD the sapace count?
//    }
//    
//    print("here", outputText)
//    
//    return outputText
//}
//
//print(justifyText(words: words, toMaxWidth: 16))




