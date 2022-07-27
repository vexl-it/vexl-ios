//
//  Activity.swift
//  pilulka
//
//  Created by Adam Salih on 11.10.2021.
//

import Foundation
import Combine

public struct Activity {
    public let indicator: ActivityIndicator
    public let error: ErrorIndicator

    public init(indicator: ActivityIndicator? = nil, error: ErrorIndicator? = nil) {
        self.indicator = indicator ?? .init()
        self.error = error ?? .init()
    }
}

public extension Publisher {
    func track(activity: Activity) -> AnyPublisher<Output, Never> {
        self
            .trackActivity(activity.indicator)
            .trackError(activity.error)
    }
}
