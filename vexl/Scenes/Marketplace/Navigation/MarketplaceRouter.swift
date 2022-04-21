//
//  MarketplaceRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import UIKit
import Combine
import Cleevio

final class MarketplaceRouter {

    private let marketplaceViewController: MarketplaceViewController
    private var isPresesentingFullscreen = false

    init(marketplaceViewController: MarketplaceViewController) {
        self.marketplaceViewController = marketplaceViewController
    }

    func set(bottomViewController viewController: UIViewController) {
        marketplaceViewController.set(bottomViewController: viewController)
    }
}

extension MarketplaceRouter: Router {

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        marketplaceViewController.dismiss(isFullscreenPresentation: isPresesentingFullscreen,
                                          completion: completion)
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        isPresesentingFullscreen = false
        marketplaceViewController.present(childViewController: viewController)
    }

    func presentFullscreen(_ viewController: UIViewController, animated: Bool) {
        isPresesentingFullscreen = true
        viewController.modalPresentationStyle = .fullScreen
        marketplaceViewController.present(viewController, animated: animated)
    }
}
