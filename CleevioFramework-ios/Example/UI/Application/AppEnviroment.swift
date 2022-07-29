//
//  AppEnviroment.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(.init())

        let service = configuredServices(appState: appState)

        let container = DIContainer(appState: appState, services: service)
        let systemEventsHandler = SystemEventsHandlerImpl(container: container)

        return AppEnvironment(container: container,
                              systemEventsHandler: systemEventsHandler)
    }

    private static func configuredServices(appState: Store<AppState>) -> DIContainer.Services {

        return .init()
    }
}
