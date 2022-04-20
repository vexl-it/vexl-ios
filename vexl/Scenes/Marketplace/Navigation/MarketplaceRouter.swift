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

    init(marketplaceViewController: MarketplaceViewController) {
        self.marketplaceViewController = marketplaceViewController
    }

    func set(bottomViewController viewController: UIViewController) {
        marketplaceViewController.set(bottomViewController: viewController)
    }
}

extension MarketplaceRouter: Router {

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        marketplaceViewController.dismiss()
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        marketplaceViewController.present(childViewController: viewController)
    }
}
