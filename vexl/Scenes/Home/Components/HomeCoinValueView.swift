//
//  MarketplaceDisplayValueView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit

final class HomeCoinValueView: UIView {

    private let valueLabel = UILabel()
    private let minigraphView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        arrangeSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrangeSubviews() {
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        minigraphView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(valueLabel)
        addSubview(minigraphView)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Appearance.GridGuide.mediumPadding2),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            minigraphView.topAnchor.constraint(equalTo: topAnchor),
            minigraphView.bottomAnchor.constraint(equalTo: bottomAnchor),
            minigraphView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Appearance.GridGuide.padding)
        ])
    }

    // TODO: - set real information when using services

    private func setupViews() {
        minigraphView.image = R.image.profile.graph()
        valueLabel.text = "$ 1234"
        valueLabel.font = Appearance.TextStyle.h2.font
        valueLabel.textColor = R.color.green5()
        backgroundColor = R.color.green1()
    }
}
