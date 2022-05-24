//
//  MarketplaceDisplayValueView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit
import Cleevio

final class CoinValueMiniGraphView: UIView {

    @Published var displayGraph = true

    private let minigraphImageView = UIImageView()
    private let coinLabel = UILabel()
    private let variationLabel = UILabel()
    private let labelStack = UIStackView()

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
        minigraphImageView.translatesAutoresizingMaskIntoConstraints = false
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(minigraphImageView)
        addSubview(labelStack)
        labelStack.addArrangedSubview(coinLabel)
        labelStack.addArrangedSubview(variationLabel)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            minigraphImageView.topAnchor.constraint(equalTo: topAnchor),
            minigraphImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            minigraphImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            minigraphImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelStack.topAnchor.constraint(equalTo: topAnchor),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupViews() {
        labelStack.axis = .vertical
        minigraphImageView.image = R.image.profile.graph()
        minigraphImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        // TODO: - remove when real data is set
        coinLabel.text = "Bitcoin"
        coinLabel.textColor = .white
        coinLabel.font = Appearance.TextStyle.paragraphSmallBold.font

        variationLabel.textColor = R.color.yellow100()
        variationLabel.text = "2% Today"
        variationLabel.font = Appearance.TextStyle.descriptionBold.font

        minigraphImageView.isHidden = !displayGraph
        minigraphImageView.alpha = displayGraph ? 1 : 0

        labelStack.isHidden = displayGraph
        labelStack.alpha = displayGraph ? 0 : 1
    }

    private func setupBindings() {
        $displayGraph
            .withUnretained(self)
            .sink { owner, displayGraph in

                if displayGraph {
                    owner.minigraphImageView.isHidden = !displayGraph

                    UIView.animate(withDuration: 0.25,
                                   delay: 0,
                                   options: .curveEaseInOut,
                                   animations: {
                        owner.minigraphImageView.alpha = displayGraph ? 1 : 0
                        owner.labelStack.alpha = displayGraph ? 0 : 1
                    },
                                   completion: { _ in
                        owner.labelStack.isHidden = displayGraph
                    })
                } else {
                    owner.labelStack.isHidden = displayGraph

                    UIView.animate(withDuration: 0.25,
                                   delay: 0,
                                   options: .curveEaseInOut,
                                   animations: {
                        owner.minigraphImageView.alpha = displayGraph ? 1 : 0
                        owner.labelStack.alpha = displayGraph ? 0 : 1
                    },
                                   completion: { _ in
                        owner.minigraphImageView.isHidden = !displayGraph
                    })
                }
            }
            .store(in: cancelBag)
    }
}

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
        valueLabel.textColor = R.color.yellow60()
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5

        activityIndicator.color = .white

        minigraphView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        valueLabel.text = "-"
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
                    owner.valueLabel.textColor = isExpanded ? R.color.yellow100() : R.color.yellow60()
                }
                owner.minigraphView.displayGraph = !isExpanded
            }
            .store(in: cancelBag)
    }
}
