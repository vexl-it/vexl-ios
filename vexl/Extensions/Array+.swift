//
//  Array+.swift
//  vexl
//
//  Created by Adam Salih on 19.07.2022.
//

import Foundation

extension Array {
    func splitIntoChunks(by count: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        var chunk: [Element] = []
        for (index, element) in enumerated() {
            chunk.append(element)
            if (index + 1) % count == 0 {
                chunks.append(chunk)
                chunk = []
            }
        }
        if !chunk.isEmpty {
            chunks.append(chunk)
        }
        return chunks
    }
}
