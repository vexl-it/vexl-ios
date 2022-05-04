//
//  MarketplaceGraphView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit

final class HomeCoinGraphView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        // TODO: - set real information when using services

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 150).isActive = true

        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
