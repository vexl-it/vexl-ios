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

    let dismissPublisher = ActionSubject<Void>()
    private let homeViewController: HomeViewController
    private var isPresesentingFullscreen = false

    init(homeViewController: HomeViewController) {
        self.homeViewController = homeViewController
    }

    func set(bottomViewController viewController: UIViewController) {
        homeViewController.set(bottomViewController: viewController)
    }
}

extension HomeRouter: Router {

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        dismissPublisher.send()
        homeViewController.dismiss(isFullscreenPresentation: isPresesentingFullscreen,
                                   completion: completion)
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        isPresesentingFullscreen = false
        if homeViewController.bottomViewController == nil {
            homeViewController.set(bottomViewController: viewController)
        } else {
            homeViewController.present(childViewController: viewController)
        }
    }

    func presentFullscreen(_ viewController: UIViewController, animated: Bool) {
        isPresesentingFullscreen = true
        viewController.modalPresentationStyle = .fullScreen
        homeViewController.present(viewController, animated: animated)
    }
}
