//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import Cleevio
import SwiftUI

final class MarketplaceCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let marketController: MarketplaceViewController
    private let marketplaceRouter: MarketplaceRouter
    private let router: Router

    init(marketController: MarketplaceViewController, router: Router) {
        self.marketController = marketController
        self.marketplaceRouter = MarketplaceRouter(marketplaceController: marketController)
        self.router = router
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let coinViewModel = CoinViewModel()
        let coinViewController = BaseViewController(rootView: CoinView(viewModel: coinViewModel))

        let buySellViewModel = BuySellViewModel()
        let buySellViewController = BaseViewController(rootView: BuySellView(viewModel: buySellViewModel))

        marketplaceRouter.set(topViewController: coinViewController)
        marketplaceRouter.set(bottomViewController: buySellViewController)

        router.present(marketController, animated: false)

        coinViewModel
            .action
            .filter { $0 == .contentTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.marketController.resizeStuff()
            }
            .store(in: cancelBag)

        buySellViewModel
            .route
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .sink { owner, _ in
                let viewController = TestViewController()
                viewController.dismiss = {
                    owner.marketplaceRouter.dismiss(animated: true)
                }
                owner.marketplaceRouter.present(viewController, animated: true)
            }
            .store(in: cancelBag)

        let dismissViewController = marketController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
