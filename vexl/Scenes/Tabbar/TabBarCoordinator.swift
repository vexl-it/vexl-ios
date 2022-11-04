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
    private let tabs: [Tab] = [.marketplace, .chat, .profile]
    private let viewModel = TabBarViewModel()

    init(window: UIWindow) {
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

        viewModel
            .route
            .filter { $0 == .showNotifications }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(
                    parentViewController: owner.tabBarController,
                    presentationStyle: .fullScreen
                )
                return owner.showNotificationPermission(router: router)
            }
            .sink()
            .store(in: cancelBag)

        let logout = authenticationManager.isUserLoggedInPublisher
            .filter { !$0 }
            .asVoid()

        return logout
            .eraseToAnyPublisher()
    }

    private func configure(tabs: [Tab]) -> [CoordinatingResult<Void>] {
        let navigationControllers = tabs.map { tab in TabBarNavigationController(homeBarItem: tab.tabBarItem) }
        tabBarController.setViewControllers(navigationControllers, animated: false)

        return zip(navigationControllers, tabs)
            .map { navigationController, tab in
                switch tab {
                case .marketplace:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: MarketplaceCoordinator(
                            router: router,
                            animated: true
                        )
                    )
                case .chat:
                    let router = NavigationRouter(navigationController: navigationController)
                    return coordinate(
                        to: InboxCoordinator(
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

    private func showNotificationPermission(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: NotificationPermissionCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                switch result {
                case .dismiss, .finished:
                    return router.dismiss(animated: true, returning: result)
                case .dismissedByRouter:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
