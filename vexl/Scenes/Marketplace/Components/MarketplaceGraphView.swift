//
//  MarketplaceGraphView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit

class MarketplaceGraphView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 150).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
