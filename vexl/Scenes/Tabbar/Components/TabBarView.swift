//
//  TabBarView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import UIKit
import Cleevio

final class TabBarView: UIView {

    var selectedItem: ActionSubject<Int> = .init()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var selectedButton: TabBarButton? {
        tabBarButtons.first(where: { $0.isSelected })
    }

    private var tabBarButtons: [TabBarButton] = []

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

    func add(tabs: [TabItemType], withSelectedIndex selectedIndex: Int = 0) {
        for button in tabBarButtons {
            stackView.removeArrangedSubview(button)
        }

        tabBarButtons.removeAll()

        for tab in tabs {
            let button = TabBarButton(item: tab.tabItem)
            button.addTarget(self, action: #selector(itemTap(sender:)), for: .touchUpInside)
            tabBarButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        tabBarButtons[selectedIndex].isSelected = true
    }

    func setSelectedUI(index: Int) {
        guard index < tabBarButtons.count else { return }
        selectedButton?.isSelected = false
        tabBarButtons[index].isSelected = true
    }

    @objc
    private func itemTap(sender: TabBarButton) {
        guard let index = tabBarButtons.firstIndex(of: sender) else { return }
        setSelectedUI(index: index)
        selectedItem.send(index)
    }
}
