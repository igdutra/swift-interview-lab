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
 
 QUESTIONS
 -
 
 1. WHAT
 stack-pased parser - for + if
 
 2. SEQUENCE
 - convert string to array of characters
 - accumulators = current key, current value
 - we will loop this array, and there will be things to accumulate. conditons
    - skip: ?
    - commit to key: = marks the commit word to key - start on value
    - commit to output: on & AND string end
 - edge case: if on commit value == empty and HASSEEN =, either false or empty
 - edgecase: ["fast=beta"] is hasSeen = , append to value
 
 
 3. STATEs
 - currentKey array
 - currentValue array
 - hasSeenEqual - same state as isKeyfilled
 - outputMap: [String: [String]]
 
 
 4. NAMING conditions / LOOPS
 - we loop each character enumerated - we need index for string end
 - for each character we check
    - if is ? - skip
    - if is = - check if hasSeenEqual
        - hasSeenEqual true - append char to value array
        - hasSeenEqual false - set to true
    - if isLetter - if hasSeenEqual - append to currentValue, else currentKey
    - last if - if is & || index = count - 1 -> commit key and value (handle emptyvalue edgecase)
        - if hasSeenEqual - append "" else append true
    
 
 "?theme=dark&view=compact&view=expanded" CHECK
 "empty="
 "?mode=fast=beta"
 5. WALK
 - OK
 
 
 6. EDGE CASES
 OK
 
*/


#Playground {

}
