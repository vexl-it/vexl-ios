//
//  Array+.swift
//  vexl
//
//  Created by Adam Salih on 19.07.2022.
//

import Foundation
import Combine

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

extension Array where Element: Publisher, Element.Output == Void {
    func zip() -> AnyPublisher<Void, Element.Failure> {
        guard !isEmpty else {
            return Just(())
                .setFailureType(to: Element.Failure.self)
                .eraseToAnyPublisher()
        }
        let result = self
            .dropFirst()
            .reduce(into: AnyPublisher(self[0])) { result, publisher in
                result = result
                    .zip(publisher) { _, _ in }
                    .eraseToAnyPublisher()
            }
        return result
    }
}

extension Array where Element: Publisher {
    func zip() -> AnyPublisher<[Element.Output], Element.Failure> {
        guard !isEmpty else {
            return Just([])
                .setFailureType(to: Element.Failure.self)
                .eraseToAnyPublisher()
        }
        let result = self
            .dropFirst()
            .reduce(into: AnyPublisher(self[0].map { [$0] })) { result, publisher in
                result = result
                    .zip(publisher) { $0 + [$1] }
                    .eraseToAnyPublisher()
            }
        return result
    }
}
