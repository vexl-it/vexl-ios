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

        let buySellViewModel = MarketplaceViewModel()
        let buySellViewController = BaseViewController(rootView: MarketplaceView(viewModel: buySellViewModel))

        window.tap {
            $0.rootViewController = homeViewController
            $0.makeKeyAndVisible()
        }

        homeRouter.set(bottomViewController: buySellViewController)

        buySellViewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showOffers(router: owner.homeRouter)
            }
            .sink { _ in }
            .store(in: cancelBag)

        let dismissViewController = homeViewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .asVoid()
            .eraseToAnyPublisher()
    }
}

extension HomeCoordinator {
    private func showOffers(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: OffersCoordinator(router: router))
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
