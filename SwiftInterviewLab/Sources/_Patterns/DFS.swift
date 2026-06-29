//
//  DFS_Recursive.swift
//  SwiftInterviewLab
//
//  Created by Ivo on 29/06/26.
//

// Graph:
//
//        A
//       / \
//      B   C
//     / \   \
//    D   E   F
//
// DFS visit order: A → B → D → E → C → F  (recursive, follows neighbor order)
// DFS visit order: A → C → F → B → E → D  (iterative, stack reverses neighbor order)

import Foundation
import Playgrounds

#Playground("Iterative") {
    let graph: [String: [String]] = [
        "A": ["B", "C"],
        "B": ["D", "E"],
        "C": ["F"],
        "D": [],
        "E": [],
        "F": []
    ]

    var visited: Set<String> = []
    var stack: [String] = ["A"]
    var visitedOrder: [String] = []

    while !stack.isEmpty {
        let nodeName = stack.removeLast()
        guard !visited.contains(nodeName) else { continue }

        visited.insert(nodeName)
        visitedOrder.append(nodeName)
        print("Visiting: \(nodeName)")

        for neighbor in graph[nodeName, default: []] {
            stack.append(neighbor)
        }
    }

    print("Order: \(visitedOrder)")
}
#Playground("Recursion") {
    let graph: [String: [String]] = [
        "A": ["B", "C"],
        "B": ["D", "E"],
        "C": ["F"],
        "D": [],
        "E": [],
        "F": []
    ]

    var visited: Set<String> = []
    var visitedOrder: [String] = []

    func dfs(node: String) {
        guard !visited.contains(node) else { return }
        visited.insert(node)
        visitedOrder.append(node)
        print("Visiting: \(node)")

        for neighbor in graph[node, default: []] {
            dfs(node: neighbor)
        }
    }

    dfs(node: "A")
    print("Order: \(visitedOrder)")
}
