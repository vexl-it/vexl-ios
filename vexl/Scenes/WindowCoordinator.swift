//
//  WindowCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import Combine
import UIKit
import SwiftUI
import Cleevio

final class WindowNavigationCoordinator<ResultType, InitialCoordinator: BaseCoordinator<ResultType>>: BaseCoordinator<ResultType> {

    private let window: UIWindow
    private let initialCoordinatorHandler: (Router, Bool) -> InitialCoordinator
    private let navigationController: UINavigationController
    private let router: NavigationRouter

    init(window: UIWindow, initialCoordinatorHandler: @escaping  (Router, Bool) -> InitialCoordinator) {
        self.window = window
        self.navigationController = UINavigationController()
        self.router = NavigationRouter(navigationController: navigationController)
        self.initialCoordinatorHandler = initialCoordinatorHandler
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        window.tap {
            $0.rootViewController = navigationController
            $0.makeKeyAndVisible()
        }

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )

        return coordinate(to: initialCoordinatorHandler(router, false))
    }
}
