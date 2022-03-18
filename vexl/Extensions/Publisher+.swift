//
//  Publisher+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import Combine

public extension Publisher {
    func asVoid() -> AnyPublisher<Void, Self.Failure> {
        self
            .map { _ -> Void in }
            .eraseToAnyPublisher()
    }

    func withUnretained<ReferenceType: AnyObject>(_ obj: ReferenceType) -> Publishers.CompactMap<Self, (ReferenceType, Self.Output)> {
        compactMap { [weak obj] element -> (ReferenceType, Output)? in
            guard let obj = obj else { return nil }
            return (obj, element)
        }
    }
}

public extension Publisher where Output == Void {
    func withUnretained<ReferenceType: AnyObject>(_ obj: ReferenceType) -> Publishers.CompactMap<Self, ReferenceType> {
        compactMap { [weak obj] _ -> ReferenceType? in
            guard let obj = obj else { return nil }
            return obj
        }
    }
}

extension Publisher where Output: Equatable {
    func useAction(action: Output) -> AnyPublisher<Output, Failure> {
        self.filter { $0 == action }.eraseToAnyPublisher()
    }
}
