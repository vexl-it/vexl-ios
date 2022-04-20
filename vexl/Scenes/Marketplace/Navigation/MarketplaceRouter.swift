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

    private let marketplaceController: MarketplaceViewController

    init(marketplaceController: MarketplaceViewController) {
        self.marketplaceController = marketplaceController
    }

    func set(bottomViewController viewController: UIViewController) {
        marketplaceController.set(bottomViewController: viewController)
    }
}

extension MarketplaceRouter: Router {

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        marketplaceController.dismiss()
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        marketplaceController.present(childViewController: viewController)
    }
}
