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
    private let tabs: [HomeTab] = [.marketplace, .profile]

    init(window: UIWindow) {
        self.tabBarController = HomeTabBarController()
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {

        Publishers.Merge(setupMarketplace(tabBar: tabBarController),
                         setupProfile(tabBar: tabBarController))
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        tabBarController.setViewControllers(animated: false)

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

    private func setupMarketplace(tabBar: HomeTabBarController) -> CoordinatingResult<Void> {
        let viewController = CoinValueViewController(viewModel: CoinValueViewModel(),
                                                     homeBarItem: .marketplace)
        let router = CoinValueRouter(homeViewController: viewController)
        tabBar.appendViewController(viewController)
        return coordinate(to: MarketplaceCoordinator(router: router,
                                                     animated: false))
    }

    private func setupProfile(tabBar: HomeTabBarController) -> CoordinatingResult<Void> {
        let viewController = CoinValueViewController(viewModel: CoinValueViewModel(),
                                                     homeBarItem: .profile)
        let router = CoinValueRouter(homeViewController: viewController)
        tabBar.appendViewController(viewController)
        return coordinate(to: UserProfileCoordinator(router: router,
                                                     animated: false))
    }
}
