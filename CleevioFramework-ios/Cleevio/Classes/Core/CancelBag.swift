//
//  CancelBag.swift
//  CleevioRoutersExample
//
//  Created by Thành Đỗ Long on 14.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Combine

final public class CancelBag {
    private var subscriptions = Cancellables()

    public init() {}

    public func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    public func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
        subscriptions.formUnion(cancellables())
    }

    public func register(subscription: AnyCancellable) {
        subscriptions.insert(subscription)
    }

    @resultBuilder
    struct Builder {
        static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
            return cancellables
        }
    }
}

public extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.register(subscription: self)
    }
}
