//
//  Publisher+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import Combine

public extension Publisher {
    func asVoid() -> Publishers.Map<Self, Void> {
        self.map { _ in }
    }
    
    func withUnretained<ReferenceType: AnyObject>(_ obj: ReferenceType) -> Publishers.CompactMap<Self, (ReferenceType, Self.Output)> {
        compactMap { [weak obj] element -> (ReferenceType, Output)? in
            guard let obj = obj else { return nil }
            return (obj, element)
        }
    }
    
    func asOptional() -> Publishers.Map<Self, Self.Output?> {
        self.map { $0 }
    }

    func sink() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }

    func flatMapLatest<T: Publisher>(_ transform: @escaping (Self.Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> {
        map(transform)
            .switchToLatest()
    }

    func flatMapLatest<T: Publisher, ReferenceType: AnyObject>(
        with obj: ReferenceType,
        _ transform: @escaping (ReferenceType, Self.Output) -> T
    ) -> Publishers.SwitchToLatest<T, Publishers.Map<Publishers.CompactMap<Self, (ReferenceType, Self.Output)>, T>> {
        withUnretained(obj)
        .map(transform)
        .switchToLatest()
    }
}

extension Publisher where Output == Void {
    func withUnretained<ReferenceType: AnyObject>(_ obj: ReferenceType) -> Publishers.CompactMap<Self, ReferenceType> {
        compactMap { [weak obj] _ -> ReferenceType? in
            guard let obj = obj else { return nil }
            return obj
        }
    }
}

protocol _OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: _OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

extension Publisher where Output: _OptionalType {
    func filterNil() -> AnyPublisher<Output.Wrapped, Failure> {
        flatMap { element -> AnyPublisher<Output.Wrapped, Never> in
            guard let value = element.value else {
                return Empty().eraseToAnyPublisher()
            }

            return Just(value).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
