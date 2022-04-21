//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import UIKit
import Cleevio

final class MarketplaceViewController: UIViewController {

    let dismissPublisher: ActionSubject<Void> = .init()

    var headerView = MarketplaceHeaderView()

    var bottomViewController: UIViewController?
    var currentViewController: UIViewController?

    var isExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        headerView.addTarget(self, action: #selector(headerTap), for: .touchUpInside)
    }

    @objc
    private func headerTap() {
        isExpanded.toggle()
        isExpanded ? headerView.presentGraph() : headerView.hideGraph()
    }

    func set(bottomViewController: UIViewController) {
        self.bottomViewController = bottomViewController
        addChild(bottomViewController)
        let childView = bottomViewController.view!
        childView.backgroundColor = .black
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)

        NSLayoutConstraint.activate([
            childView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        bottomViewController.didMove(toParent: self)
    }

    func present(childViewController: UIViewController) {
        guard let bottomView = bottomViewController?.view else {
            return
        }

        self.currentViewController = childViewController
        addChild(childViewController)
        let childView = childViewController.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            childView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor)
        ])

        childView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        childView.alpha = 0.25

        childViewController.didMove(toParent: childViewController)

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.75, options: .curveEaseInOut) {
            childView.transform = CGAffineTransform.identity
            childView.alpha = 1
        }
    }

    func dismiss(isFullscreenPresentation: Bool) {
        if isFullscreenPresentation {
            dismiss(animated: true)
        } else {
            guard let currentViewController = currentViewController else {
                return
            }

            let childView = currentViewController.view!

            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.75, options: .curveEaseInOut) {
                childView.transform = CGAffineTransform(translationX: 0, y: childView.bounds.height)
                childView.alpha = 0.25
            } completion: { [weak self] _ in
                currentViewController.removeFromParent()
                childView.removeFromSuperview()
                currentViewController.didMove(toParent: nil)
                self?.currentViewController = nil
            }
        }
    }
}
