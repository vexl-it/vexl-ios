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

final class MarketplaceWindowCoordinator: BaseCoordinator<Void> {

    private let marketplaceViewController: MarketplaceViewController
    private let marketplaceRouter: MarketplaceRouter
    private let window: UIWindow

    init(window: UIWindow) {
        self.marketplaceViewController = MarketplaceViewController()
        self.marketplaceRouter = MarketplaceRouter(marketplaceViewController: marketplaceViewController)
        self.window = window
    }

    override func start() -> CoordinatingResult<Void> {

        let buySellViewModel = BuySellViewModel()
        let buySellViewController = BaseViewController(rootView: BuySellView(viewModel: buySellViewModel))

        window.tap {
            $0.rootViewController = marketplaceViewController
            $0.makeKeyAndVisible()
        }

        marketplaceRouter.set(bottomViewController: buySellViewController)

        buySellViewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showOffers(router: owner.marketplaceRouter)
            }
            .sink { _ in }
            .store(in: cancelBag)

        let dismissViewController = marketplaceViewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .asVoid()
            .eraseToAnyPublisher()
    }

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

final class MarketplaceCoordinator: BaseCoordinator<Void> {

    private let marketplaceViewController: MarketplaceViewController
    private let marketplaceRouter: MarketplaceRouter
    private let router: Router

    init(router: Router) {
        self.router = router
        self.marketplaceViewController = MarketplaceViewController()
        self.marketplaceRouter = MarketplaceRouter(marketplaceViewController: marketplaceViewController)
    }

    override func start() -> CoordinatingResult<Void> {

        let buySellViewModel = BuySellViewModel()
        let buySellViewController = BaseViewController(rootView: BuySellView(viewModel: buySellViewModel))

        marketplaceRouter.set(bottomViewController: buySellViewController)
        router.present(marketplaceViewController, animated: false)

        buySellViewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showOffers(router: owner.marketplaceRouter)
            }
            .sink { _ in }
            .store(in: cancelBag)

        let dismissViewController = marketplaceViewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .asVoid()
            .eraseToAnyPublisher()
    }

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
