//
//  TabBarCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import UIKit
import Cleevio
import Combine

final class TabBarCoordinator: BaseCoordinator<Void> {

    @Inject var authenticationManager: AuthenticationManagerType

    private let tabBarController: TabBarController
    private let window: UIWindow
    private let tabs: [HomeTab] = [.marketplace, .chat, .profile]

    init(window: UIWindow) {
        let viewModel = TabBarViewModel()
        self.tabBarController = TabBarController(viewModel: viewModel)
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {
        Publishers.MergeMany(configure(tabs: tabs))
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

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

        let logout = authenticationManager.authenticationStatePublisher
            .removeDuplicates()
            .filter { $0 == .signedOut }
            .asVoid()

        return logout
            .eraseToAnyPublisher()
    }

    private func configure(tabs: [HomeTab]) -> [CoordinatingResult<Void>] {
        let navigationControllers = tabs.map { tab in TabBarNavigationController(homeBarItem: tab.tabBarItem) }
        tabBarController.setViewControllers(navigationControllers, animated: false)

        return zip(navigationControllers, tabs)
            .map { navigationController, tab in
                switch tab {
                case .marketplace:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: HomeCoordinator(
                            router: router,
                            animated: true
                        )
                    )
                case .chat:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: ChatCoordinator(
                            router: router,
                            animated: true
                        )
                    )
                case .profile:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: UserProfileCoordinator(
                            router: router,
                            animated: true
                        )
                    )
                }
            }
    }
}
