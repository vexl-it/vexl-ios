//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class HomeCoordinator: BaseCoordinator<Void> {

    private let homeViewController: HomeViewController
    private let homeRouter: HomeRouter
    private let window: UIWindow

    init(window: UIWindow) {
        self.homeViewController = HomeViewController()
        self.homeRouter = HomeRouter(homeViewController: homeViewController)
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {

        window.tap {
            $0.rootViewController = homeViewController
            $0.makeKeyAndVisible()
        }

        // Setting initial child view controller

        Just(homeRouter)
            .withUnretained(self)
            .flatMap { owner, router in
                owner.showMarketplaceAsRoot(router: router)
            }
            .sink { _ in }
            .store(in: cancelBag)

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )

        let dismissViewController = homeViewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .asVoid()
            .eraseToAnyPublisher()
    }
}

extension HomeCoordinator {
    private func showMarketplaceAsRoot(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: MarketplaceCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
