//
//  HomeTabbarViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 6/05/22.
//

import UIKit
import Cleevio

protocol HomeBarItemType {
    var itemIcon: UIImage { get }
}

class HomeTabBarView: UIView {

    var selectedItem: ActionSubject<Int> = .init()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var itemButtons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(items: [HomeBarItemType]) {
        for button in itemButtons {
            stackView.removeArrangedSubview(button)
        }

        itemButtons.removeAll()

        for item in items {
            let button = UIButton()
            button.setImage(item.itemIcon, for: [.normal, .highlighted, .selected])
            button.addTarget(self, action: #selector(itemTap(sender:)), for: .touchUpInside)
            itemButtons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    @objc
    private func itemTap(sender: UIButton) {
        guard let index = itemButtons.firstIndex(of: sender) else { return }
        selectedItem.send(index)
    }
}

class HomeTabBarController: UITabBarController {

    private lazy var homeTabBar: HomeTabBarView = {
        let tabBar = HomeTabBarView()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    private let cancelBag: CancelBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        arrangeSubviews()
        layout()
        setupBindings()
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        guard let viewControllers = viewControllers else {
            super.setViewControllers(viewControllers, animated: animated)
            return
        }

        let items = viewControllers
            .compactMap { $0 as? HomeBarItemType & UIViewController }

        super.setViewControllers(items, animated: animated)
        homeTabBar.add(items: items)
    }

    private func arrangeSubviews() {
        view.addSubview(homeTabBar)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            homeTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Appearance.GridGuide.mediumPadding1),
            homeTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: Appearance.GridGuide.mediumPadding1),
            homeTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                               constant: Appearance.GridGuide.mediumPadding1),
            homeTabBar.heightAnchor.constraint(equalToConstant: Appearance.GridGuide.homeTabBarHeight)
        ])
    }

    private func setupBindings() {
        homeTabBar
            .selectedItem
            .withUnretained(self)
            .sink { owner, index in
                owner.selectedIndex = index
            }
            .store(in: cancelBag)
    }
}
