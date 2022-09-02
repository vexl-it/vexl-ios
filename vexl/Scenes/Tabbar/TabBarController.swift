//
//  TabBarController.swift
//  vexl
//
//  Created by Diego Espinoza on 6/05/22.
//

import UIKit
import Cleevio

enum Tab: Int {
    case marketplace = 0
    case chat
    case profile

    var tabBarItem: TabItem {
        switch self {
        case .marketplace:
            return .marketplace
        case .chat:
            return .chat
        case .profile:
            return .profile
        }
    }
}

final class TabBarController: UITabBarController {

    private lazy var tabBarView: TabBarView = {
        let tabBar = TabBarView()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    private var _storedViewController: [UIViewController & TabItemType] = []
    private let viewModel: TabBarViewModel
    private let cancelBag: CancelBag = .init()

    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        arrangeSubviews()
        layout()
        setupBindings()
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkSelectedTab()
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        guard let viewControllers = viewControllers else {
            super.setViewControllers(viewControllers, animated: animated)
            return
        }

        let homeViewControllers = viewControllers
            .compactMap { $0 as? TabItemType & UIViewController }

        super.setViewControllers(viewControllers, animated: animated)
        tabBarView.add(tabs: homeViewControllers)
        _storedViewController = []
    }

    private func arrangeSubviews() {
        view.addSubview(tabBarView)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Appearance.GridGuide.mediumPadding1),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Appearance.GridGuide.mediumPadding1),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: Appearance.GridGuide.homeTabBarHeight)
        ])
    }

    private func setupBindings() {
        tabBarView
            .selectedItem
            .withUnretained(self)
            .sink { owner, index in
                owner.selectedIndex = index
            }
            .store(in: cancelBag)

        viewModel
            .goToInboxTab
            .withUnretained(self)
            .filter { $0.isVisible }
            .sink { owner in
                owner.tabBarView.setSelectedUI(index: Tab.chat.rawValue)
                owner.selectedIndex = Tab.chat.rawValue
            }
            .store(in: cancelBag)
    }
}
