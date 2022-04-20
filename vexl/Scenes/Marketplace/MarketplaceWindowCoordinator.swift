//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import Cleevio
import SwiftUI

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

        let dismissViewController = marketplaceViewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .asVoid()
            .eraseToAnyPublisher()
    }
}
