import Playgrounds

public protocol NestedIntegerProtocol: AnyObject {
    init()
    init(_ value: Int)
    func add(_ elem: Self)
    func isInteger() -> Bool
    func getInteger() -> Int
    func getList() -> [Self]
}

/// Mock NestedInteger implementation for LeetCode 385 Mini Parser and 341 Flatten Iterator.
/// Supports storing either an Int or a [NestedInteger], prints nicely.
public final class NestedInteger: NestedIntegerProtocol, CustomStringConvertible {
    private var intValue: Int?
    private var listValue: [NestedInteger]?

    required public init() {
        self.listValue = []
    }

    required public init(_ value: Int) {
        self.intValue = value
    }

    public func add(_ elem: NestedInteger) {
        if listValue == nil {
            listValue = []
        }
        listValue?.append(elem)
    }

    public func isInteger() -> Bool {
        intValue != nil
    }

    public func getInteger() -> Int {
        intValue ?? 0
    }

    public func getList() -> [NestedInteger] {
        listValue ?? []
    }

    public var description: String {
        if let intValue = intValue {
            return "\(intValue)"
        } else if let listValue = listValue {
            return "[\(listValue.map { $0.description }.joined(separator: ", "))]"
        }
        return "[]"
    }
}

#Playground {
    let inner = NestedInteger()
    inner.add(NestedInteger(456))
    inner.add(NestedInteger(789))

    let outer = NestedInteger()
    outer.add(NestedInteger(123))
    outer.add(inner)

    print(outer)
    var out = outer.getList()
    print("list,", out)
    let last = out.popLast()
    print("last", last)
    print(last?.getList())
    var test: [NestedInteger] = []
//    
    for value in last!.getList().reversed() {
        test.append(value)
    }
    print("final", test)
    for value in test {
        print(value.isInteger())
    }
   
}
