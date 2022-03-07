//
//  RegistrationCounterView.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import UIKit

class RegistrationCounterView: UIView {

    private let numberOfItems: Int
    private let currentIndex: Int
    private let itemWidth: CGFloat = 24
    private let spacing: CGFloat = 4
    private let itemHeight: CGFloat = 4

    init(numberOfItems: Int, currentIndex: Int) {
        self.numberOfItems = numberOfItems
        self.currentIndex = currentIndex
        let totalWidth = (itemWidth * CGFloat(numberOfItems)) + (spacing * CGFloat(numberOfItems - 1))
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: totalWidth, height: itemHeight)))
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        for index in 0..<numberOfItems {
            let itemPoint = CGPoint(x: (itemWidth * CGFloat(index) + (spacing * CGFloat(index))), y: 0)
            let item = UIView(frame: CGRect(origin: itemPoint, size: CGSize(width: itemWidth, height: itemHeight)))
            item.backgroundColor = index <= currentIndex ? .white : .gray
            item.layer.cornerRadius = itemHeight * 0.5
            addSubview(item)
        }
    }
}
