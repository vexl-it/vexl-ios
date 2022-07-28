//
//  DependencyInjector.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import SwiftUI
import Combine

// MARK: - Dependencies

struct DIContainer: EnvironmentKey {

    let appState: Store<AppState>
    let services: Services

    static var defaultValue: Self { Self.default }

    private static let `default` = DIContainer(appState: AppState(), services: .stub)

    init(appState: Store<AppState>, services: DIContainer.Services) {
        self.appState = appState
        self.services = services
    }

    init(appState: AppState, services: DIContainer.Services) {
        self.init(appState: Store(appState), services: services)
    }
}
