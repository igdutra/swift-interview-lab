import Testing

// ============================================================
// PROBLEM: 385. Mini Parser
// https://leetcode.com/problems/mini-parser/
// Difficulty: Medium
// Topics: Stack, Depth-First Search, String
//
// Given a string s representing a serialization of a nested
// list, parse and deserialize it into a NestedInteger object.
//
// Example 1:
//   Input:  s = "324"
//   Output: 324
//
// Example 2:
//   Input:  s = "[123,[456,[789]]]"
//   Output: [123,[456,[789]]]
//
// Constraints:
//   - 1 <= s.length <= 5 * 10^4
//   - s consists of digits, square brackets "[]", negative sign '-', and commas ','
//   - s is the serialization of valid NestedInteger
//   - All the values in the input are in the range [-10^6, 10^6]
//
// ============================================================
// TIME AND SPACE COMPLEXITY ANALYSIS
//
// Time Complexity:
// TODO
// 
// Space Complexity: 
// TODO
// ============================================================

// NestedInteger interface/protocol
protocol NestedInteger {
    init()
    init(_ value: Int)
    mutating func add(_ elem: NestedInteger)
    func isInteger() -> Bool
    func getInteger() -> Int
    func getList() -> [NestedInteger]
}

// Concrete NestedInteger implementation for testing
class NestedIntegerImpl: NestedInteger {
    private var value: Int?
    private var list: [NestedIntegerImpl] = []
    
    required init() {
        self.value = nil
    }
    
    required init(_ value: Int) {
        self.value = value
    }
    
    func add(_ elem: NestedInteger) {
        if let impl = elem as? NestedIntegerImpl {
            list.append(impl)
        }
    }
    
    func isInteger() -> Bool {
        return value != nil
    }
    
    func getInteger() -> Int {
        return value ?? 0
    }
    
    func getList() -> [NestedInteger] {
        return list
    }
}

private func deserialize(_ s: String) -> NestedInteger {
    // TODO
}


// ============================================================
// TESTS
// ============================================================

@Suite("Mini Parser")
struct MiniParserTests {

    // --- Official LeetCode examples ---

    @Test("Official example 1")
    func officialExample1() {
        let result = deserialize("324")
        #expect(result.isInteger())
        #expect(result.getInteger() == 324)
    }

    @Test("Official example 2")
    func officialExample2() {
        let result = deserialize("[123,[456,[789]]]")
        #expect(!result.isInteger())
        let list = result.getList()
        #expect(list.count == 2)
        #expect(list[0].isInteger())
        #expect(list[0].getInteger() == 123)
    }

    // --- Edge cases ---

    @Test("Empty list")
    func emptyList() {
        let result = deserialize("[]")
        #expect(!result.isInteger())
        #expect(result.getList().isEmpty)
    }

    @Test("Single element list")
    func singleElementList() {
        let result = deserialize("[1]")
        #expect(!result.isInteger())
        let list = result.getList()
        #expect(list.count == 1)
        #expect(list[0].getInteger() == 1)
    }

    @Test("Negative number")
    func negativeNumber() {
        let result = deserialize("-5")
        #expect(result.isInteger())
        #expect(result.getInteger() == -5)
    }

    @Test("List with negative numbers")
    func listWithNegatives() {
        let result = deserialize("[-1,2,-3]")
        #expect(!result.isInteger())
        let list = result.getList()
        #expect(list.count == 3)
        #expect(list[0].getInteger() == -1)
        #expect(list[1].getInteger() == 2)
        #expect(list[2].getInteger() == -3)
    }
}
