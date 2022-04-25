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

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )

        let dismissViewController = marketplaceViewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissViewController
            .receive(on: RunLoop.main)
            .asVoid()
            .eraseToAnyPublisher()
    }
}
