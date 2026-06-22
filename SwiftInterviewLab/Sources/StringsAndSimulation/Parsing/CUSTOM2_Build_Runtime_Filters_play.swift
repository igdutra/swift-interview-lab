//
//  File.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 21/06/26.
//

import Foundation
import Playgrounds

// ============================================================
// PROBLEM: Decode Runtime Filters
// Difficulty: Easy
// Topics: Hash Table, String
//
// A dashboard sends a compact filter line to the backend. Each
// token represents either:
//   - a named value such as "theme=dark"
//   - a feature flag such as "debug", which should decode as
//     "debug=true"
//
// Parse the input into a map from filter name to every value seen
// for that filter, preserving the original order.
//
// Example 1:
//   Input:  "?theme=dark&view=compact&view=expanded"
//   Output: ["theme": ["dark"], "view": ["compact", "expanded"]]
//
// Example 2:
//   Input:  "?debug"
//   Output: ["debug": ["true"]]
//
// Example 3:
//   Input:  "region=us-east&&region=eu-west&empty="
//   Output: ["region": ["us-east", "eu-west"], "empty": [""]]
//
// Example 4:
//   Input:  "?mode=fast=beta&retry&retry=3"
//   Output: ["mode": ["fast=beta"], "retry": ["true", "3"]]
//
// Constraints:
//   - Input may or may not begin with "?"
//   - Tokens are separated by "&"; empty tokens must be ignored
//   - Each token is "name=value" or "name" (no "=") → value is "true"
//   - If a token contains multiple "=", split on the first one only
//   - Same name may appear multiple times; all values preserved in order
//   - Values are plain strings (may be empty)
//   - 0 <= input.length <= 10_000
//
// ============================================================

/* PLAN

QUESTIONs
 - emptyString - empty return
 - can numbers be used in key/value? - yes - check isNumber isLetter
 - Validation — what happens with malformed input (e.g. key= with no value)? - assume is valid
 - Operator semantics — is = equality only, or could >=, != appear later? - assume only =
 - Case sensitivity of values — is "USD" the same as "usd"? - assume is already lowercased
 
 1. PATTERN
 stack-based parser. will use sigle loop and have if conditions inside it
 
 2. SEQUENCE
 - use currentKey, currentValue arrays
 - convert string to array of characters
 - loop array, accumulate. conditions
    - ? : Skip
    - = : hasSeenEqual - if false, set to true. if true, append value array
    - number or letter: check hasSeenEqual, append to either key or value
    - & and end of the array: append to dict. before, if value is empty, must check edge case: hasSeenEqual - either commit true or empty
 
 3. STATES
 - curretKeyArray
 - currentValueArray
 - hasSeenEqual
 - outputMap: [String: [String]]
 
 4. CONDITIONS / LOOPS
 - loop character array enumerated - we need index to check end of string
 - for each character
    - if ?: skip
    - if =: hasSeenEqual
        - if true: append to values array
        - if false: set it to true AND CONTINUE - no break, must fall trhough to last check
    - if isLetter || isNumber - check hasSeenEnqual, append to the correct accumulator
    - if & || index == count - 1 - append currentKey and currentValue.
        - edge case: if value isEmpty, must check hasSeenEqual
            - if true, value = ""
            - if false, value = "true"
        - FLUSH currentKey and currentValue AND hasSeenEqual
 
 "?theme=dark&view=compact&view=expanded" CHECK
 "empty="
 "?mode=fast=beta"
 5. WALK
 - OK
 
 6. EDGE CASE
 - && - make sure to check before appending if key != empty
 - final = - hanlded if hasSeenEqual
 - mid value = - handled with hasSeenEqual
*/

#Playground {
    let string = "region=us-east&&region=eu-west&empty="
    print(string)
    
    func getTokenMap(for string: String) -> [String: [String]] {
        var outputMap: [String: [String]] = [:]
        let stringArray = Array(string)
        
        // Accumulators
        var currentKey: [Character] = []
        var currentValue: [Character] = []
        var hasSeenEqual = false
        
        for (index, character) in stringArray.enumerated() {
            if character == "?" { continue }
            
            if character == "=" {
                hasSeenEqual ? (currentValue.append("=")) : (hasSeenEqual = true)
            }
            
            if character != "=", character != "=", character != "&" {
                hasSeenEqual ? (currentValue.append(character)) : (currentKey.append(character))
            }
            
            if character == "&" || index == stringArray.count - 1 {
                // Edge case block - avoid double &
                guard !currentKey.isEmpty else { continue }
                
                let key = String(currentKey)
                var value = String(currentValue)

                if value.isEmpty {
                    hasSeenEqual ? (value = "") : (value = "true")
                }
                
                print("key BEFORE", currentKey)
                print("value BEFORE", currentValue)
                
                outputMap[key, default: []].append(value)
                
                currentKey = []
                currentValue = []
                hasSeenEqual = false
            }
        }
        
        print("key", currentKey)
        print("value", currentValue)
        
        print("=======")
        
        return outputMap
    }
    
    print(getTokenMap(for: string))
}
