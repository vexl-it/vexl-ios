//
//  BuySellCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Cleevio
import Foundation
import Combine

class MarketplaceCoordinator: BaseCoordinator<RouterResult<Void>> {

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
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showOffers(router: owner.router)
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
