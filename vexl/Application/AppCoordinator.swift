//
//  AppCoordinator.swift
//  CleevioRoutersExample
//
//  Created by Thành Đỗ Long on 14.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import Cleevio

final class AppCoordinator: BaseCoordinator<Void> {

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var syncQueue: SyncQueueManagerType
    @Inject var notificationManager: NotificationManagerType

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {
        coordinateToRoot()
        return Empty()
            .eraseToAnyPublisher()
    }

    // Recursive method that will restart a child coordinator after completion.
    // Based on:
    // https://github.com/uptechteam/Coordinator-MVVM-Rx-Example/issues/3
    private func coordinateToRoot() {
        let coordinationResult: CoordinatingResult<Void> = {
            switch initialScreenManager.getCurrentScreenState() {
            case .splashScreen:
                return showSplashCoordinator()
            case .onboarding:
                return showOnboardingCoordinator()
            case .home:
                return showHomeCoordinator()
            }
        }()

        cancellable = coordinationResult
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.resetFlow()
            })
    }

    private func resetFlow() {
        cancellable?.cancel()
        window.rootViewController = nil
        coordinateToRoot()
    }
}

extension AppCoordinator {
    private func showSplashCoordinator() -> CoordinatingResult<Void> {
        coordinate(to: SplashScreenCoordinator(window: window))
    }

    private func showOnboardingCoordinator() -> CoordinatingResult<Void> {
        coordinate(to:
            WindowNavigationCoordinator(window: window) { router, animated -> WelcomeCoordinator in
                WelcomeCoordinator(router: router, animated: animated)
            }
        )
            .asVoid()
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showHomeCoordinator() -> CoordinatingResult<Void> {
        coordinate(to: TabBarCoordinator(window: window))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
