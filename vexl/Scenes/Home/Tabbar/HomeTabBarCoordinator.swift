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

    private let tabBarController: HomeTabBarController
    private let window: UIWindow
    private let tabs: [HomeTab] = [.marketplace, .chat, .profile]

    init(window: UIWindow) {
        let viewModel = HomeTabBarViewModel()
        self.tabBarController = HomeTabBarController(viewModel: viewModel)
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {

        Publishers.MergeMany(configure(tabBar: tabBarController, tabs: tabs))
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

        let logout = authenticationManager.statePublisher
            .removeDuplicates()
            .filter { $0 == .signedOut }
            .print("hello there 2")
            .asVoid()

        return logout
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private func configure(tabBar: HomeTabBarController, tabs: [HomeTab]) -> [CoordinatingResult<Void>] {
        let viewControllers = tabs.map { tab in
            CoinValueViewController(viewModel: CoinValueViewModel(startsLoading: true),
                                    homeBarItem: tab.tabBarItem)
        }

        tabBarController.setViewControllers(viewControllers, animated: false)

        return zip(viewControllers, tabs)
            .map { viewController, tab in
                switch tab {
                case .marketplace:
                    let router = CoinValueRouter(homeViewController: viewController)
                    return coordinate(to: MarketplaceCoordinator(router: router,
                                                                 animated: false))
                case .chat:
                    let router = CoinValueRouter(homeViewController: viewController)
                    return coordinate(to: ChatCoordinator(router: router,
                                                          animated: false))
                case .profile:
                    let router = CoinValueRouter(homeViewController: viewController)
                    return coordinate(to: UserProfileCoordinator(router: router,
                                                                 animated: false))
                }
            }
    }
}
