//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import UIKit
import SwiftUI
import Cleevio

final class ChildTabBarViewController: UIViewController, HomeTabBarItemType {
    let homeTabBarItem: HomeTabBarItem

    init(homeBarItem: HomeTabBarItem) {
        self.homeTabBarItem = homeBarItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CoinValueViewController: UIViewController, HomeTabBarItemType {

    let dismissPublisher: ActionSubject<Void> = .init()
    let homeTabBarItem: HomeTabBarItem
    var bottomViewController: UIViewController?

    private let viewModel: CoinValueViewModel
    private let headerView = CoinValueHeaderView()
    private let cancelBag: CancelBag = .init()
    private var currentViewController: UIViewController?
    private var isExpanded = false

    init(viewModel: CoinValueViewModel, homeBarItem: HomeTabBarItem) {
        self.viewModel = viewModel
        self.homeTabBarItem = homeBarItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupHeader()
        setupBindings()
    }

    private func setupHeader() {
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

    func dismiss(isFullscreenPresentation: Bool, completion: (() -> Void)?) {
        if isFullscreenPresentation {
            dismiss(animated: true, completion: completion)
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
                completion?()
            }
        }
    }

    private func setupBindings() {
        viewModel
            .$isLoading
            .withUnretained(self)
            .sink { owner, isLoading in
                owner.headerView.isLoading = isLoading
            }
            .store(in: cancelBag)

        viewModel.$bitcoinValue
            .assign(to: \.bitcoinValue, on: headerView)
            .store(in: cancelBag)
    }
}
