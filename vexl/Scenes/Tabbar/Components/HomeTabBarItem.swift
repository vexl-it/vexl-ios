//
//  HomeTabBarItem.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio

protocol HomeTabBarItemType {
    var homeTabBarItem: HomeTabBarItem { get }
}

struct HomeTabBarItem {
    let selectedIcon: UIImage
    let unselectedIcon: UIImage

    static var marketplace: HomeTabBarItem {
        HomeTabBarItem(selectedIcon: R.image.tabbar.marketplaceSelected()!,
                       unselectedIcon: R.image.tabbar.marketplaceUnselected()!)
    }

    static var chat: HomeTabBarItem {
        HomeTabBarItem(selectedIcon: R.image.tabbar.chatSelected()!,
                       unselectedIcon: R.image.tabbar.chatUnselected()!)
    }

    static var profile: HomeTabBarItem {
        HomeTabBarItem(selectedIcon: R.image.tabbar.profileSelected()!,
                       unselectedIcon: R.image.tabbar.profileUnselected()!)
    }
}

final class HomeTabBarButton: UIButton {

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? R.color.purple1() : .clear
        }
    }

    init(item: HomeTabBarItem) {
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
