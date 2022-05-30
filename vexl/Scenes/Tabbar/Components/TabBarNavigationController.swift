//
//  TabBarNavigationController.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import UIKit

final class TabBarNavigationController: UINavigationController, TabItemType {
    let tabItem: TabItem

    init(homeBarItem: TabItem) {
        self.tabItem = homeBarItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
