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

    private let window: UIWindow
    @Inject var initialScreenManager: InitialScreenManager

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
            switch initialScreenManager.state {
            case .splashScreen:
                return showSplashCoordinator()
            case .onboarding:
                return showOnboardingCoordinator()
            case .home:
                return showHomeScreen()
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
            WindowNavigationCoordinator(window: window) { router, animated -> OnboardingCoordinator in
                OnboardingCoordinator(router: router, animated: animated)
            }
        ).asVoid()
    }

    private func showHomeScreen() -> CoordinatingResult<Void> {
        // TODO: Show homescreen
        showOnboardingCoordinator()
    }
}
