//
//  BFS.swift
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
// BFS visit order: A → B → C → D → E → F

import Foundation
import Playgrounds

#Playground {
    let graph: [String: [String]] = [
        "A": ["B", "C"],
        "B": ["D", "E"],
        "C": ["F"],
        "D": [],
        "E": [],
        "F": []
    ]

    let startNode = "A"
    var visited: Set<String> = [startNode]
    var queue = [startNode]
    var head = 0

    while head < queue.count {
        let currentNode = queue[head]
        head += 1

        print("Visiting: \(currentNode)")

        for neighbor in graph[currentNode, default: []] {
            if !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.append(neighbor)
            }
        }
    }
}
