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

    @Inject var authenticationManager: AuthenticationManagerType

    private let tabBarController: TabBarController
    private let window: UIWindow
    private let tabs: [HomeTab] = [.marketplace, .chat, .profile]

    init(window: UIWindow) {
        let viewModel = HomeTabBarViewModel()
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
        let viewControllers = tabs.map { tab in
            ChildTabBarViewController(homeBarItem: tab.tabBarItem)
//            CoinValueViewController(viewModel: CoinValueViewModel(startsLoading: true),
//                                    homeBarItem: tab.tabBarItem)
        }
        let navigationControllers = tabs.map { _ in UINavigationController() }

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
//                    let router = CoinValueRouter(homeViewController: viewController)
//                    return coordinate(to: MarketplaceCoordinator(router: router,
//                                                                 animated: false))
                case .chat:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: HomeCoordinator(
                            router: router,
                            animated: true
                        )
                    )
//                    let router = CoinValueRouter(homeViewController: viewController)
//                    return coordinate(to: ChatCoordinator(router: router,
//                                                          animated: false))
                case .profile:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: HomeCoordinator(
                            router: router,
                            animated: true
                        )
                    )
//                    let router = CoinValueRouter(homeViewController: viewController)
//                    return coordinate(to: UserProfileCoordinator(router: router,
//                                                                 animated: false))
                }
            }
    }
}
