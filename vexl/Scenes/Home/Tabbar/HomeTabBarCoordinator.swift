//
//  HomeTabBarCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import UIKit
import Cleevio
import Combine

final class HomeTabBarCoordinator: BaseCoordinator<Void> {

    private let tabBarController: HomeTabBarController
    private let window: UIWindow

    init(window: UIWindow) {
        self.tabBarController = HomeTabBarController()
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {

        window.tap {
            $0.rootViewController = self.tabBarController
            $0.makeKeyAndVisible()
        }

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
