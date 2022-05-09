//
//  HomeTabbarViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 6/05/22.
//

import UIKit
import Cleevio

protocol HomeBarItemType {
    var selectedIcon: UIImage { get }
    var unselectedIcon: UIImage { get }
}

class HomeTabBarButton: UIButton {

    override var isSelected: Bool {
        didSet {
            setImage(isSelected ? selectedIcon : unselectedIcon, for: .selected)
            backgroundColor = isSelected ? R.color.purple1() : .clear
        }
    }

    private let selectedIcon: UIImage
    private let unselectedIcon: UIImage

    init(item: HomeBarItemType) {
        self.selectedIcon = item.selectedIcon
        self.unselectedIcon = item.unselectedIcon
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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

    var selectedButton: HomeTabBarButton? {
        itemButtons.first(where: { $0.isSelected })
    }

    private var itemButtons: [HomeTabBarButton] = []

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

    func add(items: [HomeBarItemType], withSelectedIndex selectedIndex: Int = 0) {
        for button in itemButtons {
            stackView.removeArrangedSubview(button)
        }

        itemButtons.removeAll()

        for item in items {
            let button = HomeTabBarButton(item: item)
            button.addTarget(self, action: #selector(itemTap(sender:)), for: .touchUpInside)
            itemButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        itemButtons[selectedIndex].isSelected = true
    }

    @objc
    private func itemTap(sender: HomeTabBarButton) {
        guard let index = itemButtons.firstIndex(of: sender) else { return }
        selectedButton?.isSelected = false
        itemButtons[index].isSelected = true
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
