//
//  HomeTabbarViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 6/05/22.
//

import UIKit
import Cleevio

struct HomeBarItem {
    let selectedIcon: UIImage
    let unselectedIcon: UIImage

    static var marketplace: HomeBarItem {
        HomeBarItem(selectedIcon: R.image.tabbar.marketplaceSelected()!,
                    unselectedIcon: R.image.tabbar.marketplaceUnselected()!)
    }

    static var profile: HomeBarItem {
        HomeBarItem(selectedIcon: R.image.tabbar.profileSelected()!,
                    unselectedIcon: R.image.tabbar.profileUnselected()!)
    }
}

protocol HomeTabBarItemContainerType {
    var homeBarItem: HomeBarItem { get }
}

enum HomeTab {
    case marketplace
    case profile
}

class HomeTabBarButton: UIButton {

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? R.color.purple1() : .clear
        }
    }

    init(item: HomeBarItem) {
        super.init(frame: .zero)
        setImage(item.selectedIcon, for: .selected)
        setImage(item.unselectedIcon, for: .normal)
        heightAnchor.constraint(equalToConstant: Appearance.GridGuide.homeTabBarHeight).isActive = true
        layer.cornerRadius = Appearance.GridGuide.tabBarCorner
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
        backgroundColor = .black
        layer.cornerRadius = Appearance.GridGuide.tabBarCorner
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(itemContainers: [HomeTabBarItemContainerType], withSelectedIndex selectedIndex: Int = 0) {
        for button in itemButtons {
            stackView.removeArrangedSubview(button)
        }

        itemButtons.removeAll()

        for container in itemContainers {
            let button = HomeTabBarButton(item: container.homeBarItem)
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

    private var _storedViewController: [UIViewController & HomeTabBarItemContainerType] = []
    private let cancelBag: CancelBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        arrangeSubviews()
        layout()
        setupBindings()
        view.backgroundColor = .black
    }

    func appendViewController(_ viewController: UIViewController & HomeTabBarItemContainerType) {
        _storedViewController.append(viewController)
    }

    func setViewControllers(animated: Bool) {
        setViewControllers(_storedViewController, animated: animated)
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        guard let viewControllers = viewControllers else {
            super.setViewControllers(viewControllers, animated: animated)
            return
        }

        let itemContainers = viewControllers
            .compactMap { $0 as? HomeTabBarItemContainerType & UIViewController }

        super.setViewControllers(itemContainers, animated: animated)
        homeTabBar.add(itemContainers: itemContainers)
        _storedViewController = []
    }

    private func arrangeSubviews() {
        view.addSubview(homeTabBar)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            homeTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Appearance.GridGuide.mediumPadding1),
            homeTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Appearance.GridGuide.mediumPadding1),
            homeTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Appearance.GridGuide.mediumPadding1),
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
