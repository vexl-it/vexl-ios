//
//  MarketplaceRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import UIKit
import Combine
import Cleevio

final class HomeRouter {

    private let homeViewController: HomeViewController

    init(homeViewController: HomeViewController) {
        self.homeViewController = homeViewController
    }

    func set(bottomViewController viewController: UIViewController) {
        homeViewController.set(bottomViewController: viewController)
    }
}

extension HomeRouter: Router {

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        homeViewController.dismiss()
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        homeViewController.present(childViewController: viewController)
    }
}
