//
//  BuySellCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Cleevio
import Foundation
import Combine

final class MarketplaceCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = MarketplaceViewModel()
        let viewController = BaseViewController(rootView: MarketplaceView(viewModel: viewModel))

        router.present(viewController, animated: true)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showSellOfferTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showSellOffers(router: owner.router)
            }
            .sink { _ in }
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showBuyOfferTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showBuyOffers(router: modalRouter)
            }
            .sink { _ in }
            .store(in: cancelBag)

        let dismissByRouter = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissByRouter
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension MarketplaceCoordinator {
    private func showSellOffers(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: UserOffersCoordinator(router: router, offerType: .sell))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func showBuyOffers(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: UserOffersCoordinator(router: router, offerType: .buy))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func showCreateOffer(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: CreateOfferCoordinator(router: router, offerType: .buy))
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
