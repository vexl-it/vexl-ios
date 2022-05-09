//
//  HomeTabbarViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 6/05/22.
//

import UIKit
import Cleevio

enum HomeTab {
    case marketplace
    case profile
}

class HomeTabBarController: UITabBarController {

    private lazy var homeTabBarView: HomeTabBarView = {
        let tabBar = HomeTabBarView()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    private var _storedViewController: [UIViewController & HomeTabBarItemType] = []
    private let cancelBag: CancelBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        arrangeSubviews()
        layout()
        setupBindings()
        view.backgroundColor = .black
    }

    /// Use this method to store temporary the view controllers without setting them as child UIViewControllers
    /// from the HomeTabBarController. Once all the needed UIViewControllers have been stored, call the method `setViewController(animated:)` to set them as tabs from the HomeTabBarController.

    func appendViewController(_ viewController: UIViewController & HomeTabBarItemType) {
        _storedViewController.append(viewController)
    }

    /// Use this method to set as tabs all the previously stored UIViewControllers via `appendViewControllers()`
    
    func setViewControllers(animated: Bool) {
        setViewControllers(_storedViewController, animated: animated)
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        guard let viewControllers = viewControllers else {
            super.setViewControllers(viewControllers, animated: animated)
            return
        }

        let homeViewControllers = viewControllers
            .compactMap { $0 as? HomeTabBarItemType & UIViewController }

        super.setViewControllers(homeViewControllers, animated: animated)
        homeTabBarView.add(tabs: homeViewControllers)
        _storedViewController = []
    }

    private func arrangeSubviews() {
        view.addSubview(homeTabBarView)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            homeTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Appearance.GridGuide.mediumPadding1),
            homeTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Appearance.GridGuide.mediumPadding1),
            homeTabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Appearance.GridGuide.mediumPadding1),
            homeTabBarView.heightAnchor.constraint(equalToConstant: Appearance.GridGuide.homeTabBarHeight)
        ])
    }

    private func setupBindings() {
        homeTabBarView
            .selectedItem
            .withUnretained(self)
            .sink { owner, index in
                owner.selectedIndex = index
            }
            .store(in: cancelBag)
    }
}
