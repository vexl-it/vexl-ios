//
//  Materialize.swift
//  vexl
//
//  Created by Diego Espinoza on 18/03/22.
//

import Foundation
import Combine

public extension Publishers {
    enum Event<T, E: Error> {
        case value(T)
        case failure(E)
        case finished

        var value: T? {
            if case .value(let value) = self {
                return value
            }
            return nil
        }

        var failure: E? {
            if case .failure(let error) = self {
                return error
            }
            return nil
        }

        var isCompleted: Bool {
            if case .finished = self {
                return true
            }
            return false
        }

    }

    class Materialized<Upstream: Publisher>: Publisher {
        public typealias Output = Event<Upstream.Output, Upstream.Failure>
        public typealias Failure = Never

        private let upstream: Upstream

        init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Materialized.Failure == S.Failure, Materialized.Output == S.Input {
            let cancellable = upstream
                .sink(
                    receiveCompletion: {
                        switch $0 {
                        case .failure(let error):
                            _ = subscriber.receive(.failure(error))
                        case .finished:
                            _ = subscriber.receive(.finished)
                        }
                        subscriber.receive(completion: .finished)
                    },
                    receiveValue: { _ = subscriber.receive(.value($0)) }
                )
            let subscription = MaterializedSubscription(cancellable: cancellable)
            subscriber.receive(subscription: subscription)
        }

        private class MaterializedSubscription: Subscription {
            private let cancellable: AnyCancellable

            init(cancellable: AnyCancellable) {
                self.cancellable = cancellable
            }

            func request(_ demand: Subscribers.Demand) {}

            func cancel() {
                cancellable.cancel()
            }
        }
    }
}

public extension Publishers.Materialized {
    func separate() -> (value: AnyPublisher<Upstream.Output?, Never>, failure: AnyPublisher<Upstream.Failure?, Never>) {
        (
            value: self.map { $0.value }.eraseToAnyPublisher(),
            failure: self.map { $0.failure }.eraseToAnyPublisher()
        )
    }
    
    func ignoreCompleted() -> AnyPublisher<Output, Never> {
        self.filter { !$0.isCompleted }
        .eraseToAnyPublisher()
    }
}

public extension Publisher {
    func materialize() -> Publishers.Materialized<Self> {
        Publishers.Materialized(upstream: self)
    }
    
    func materializeIgnoreCompleted() -> Publishers.Filter<Publishers.Materialized<Self>> {
        Publishers.Filter(upstream: Publishers.Materialized(upstream: self),
                          isIncluded: { !$0.isCompleted })
    }
}
