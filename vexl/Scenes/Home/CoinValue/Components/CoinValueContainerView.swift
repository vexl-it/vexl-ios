//
//  MarketplaceDisplayValueView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit
import Cleevio

final class CoinValueContainerView: UIView {

    @Published var isExpanded = false
    @Published var isLoading = false
    @Published var bitcoinValue: Decimal?

    private let activityIndicator = UIActivityIndicatorView()
    private let valueLabel = UILabel()
    private let minigraphView = CoinValueMiniGraphView()
    private let cancelBag: CancelBag = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        arrangeSubviews()
        layout()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrangeSubviews() {
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        minigraphView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(valueLabel)
        addSubview(minigraphView)
        addSubview(activityIndicator)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Appearance.GridGuide.mediumPadding2),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: minigraphView.trailingAnchor, constant: Appearance.GridGuide.padding)
        ])

        NSLayoutConstraint.activate([
            minigraphView.topAnchor.constraint(equalTo: topAnchor),
            minigraphView.bottomAnchor.constraint(equalTo: bottomAnchor),
            minigraphView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Appearance.GridGuide.padding)
        ])

        NSLayoutConstraint.activate([
            activityIndicator.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor)
        ])
    }

    private func setupViews() {
        valueLabel.font = Appearance.TextStyle.h2.font
        valueLabel.textColor = UIColor(Appearance.Colors.yellow60)
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5

        activityIndicator.color = UIColor(Appearance.Colors.whiteText)

        minigraphView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupBindings() {
        $isLoading
            .withUnretained(self)
            .sink { owner, isLoading in
                owner.activityIndicator.isHidden = !isLoading
                owner.valueLabel.isHidden = isLoading
                isLoading ? owner.activityIndicator.startAnimating() : owner.activityIndicator.stopAnimating()
            }
            .store(in: cancelBag)

        $bitcoinValue
            .withUnretained(self)
            .sink { owner, value in
                if let value = value {
                    owner.valueLabel.text = Formatters.numberFormatter.string(for: value)
                }
            }
            .store(in: cancelBag)

        $isExpanded
            .withUnretained(self)
            .sink { owner, isExpanded in
                UIView.transition(with: owner.valueLabel, duration: 0.25, options: .transitionCrossDissolve) {
                    owner.valueLabel.textColor = isExpanded ? UIColor(Appearance.Colors.yellow100) : UIColor(Appearance.Colors.yellow60)
                }
                owner.minigraphView.displayGraph = !isExpanded
            }
            .store(in: cancelBag)
    }
}
