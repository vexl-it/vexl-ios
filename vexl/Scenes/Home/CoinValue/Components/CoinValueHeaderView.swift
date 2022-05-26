//
//  MarketplaceHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit
import Cleevio

final class CoinValueHeaderView: UIControl {

    @Published var isLoading = false
    @Published var bitcoinValue: Decimal?
    private let displayValue = CoinValueContainerView()
    private let graphView = CoinValueGraphView()
    private let stackView = UIStackView()
    private let cancelBag: CancelBag = .init()

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
        arrangeSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentGraph() {
        displayValue.isExpanded = true

        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.graphView.isHidden = false
            self.graphView.alpha = 1
        }
    }

    func hideGraph() {
        displayValue.isExpanded = false

        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.graphView.isHidden = true
            self.graphView.alpha = 0
        }
    }

    private func setupLayer() {
        let gradientLayer = layer as? CAGradientLayer
        let bottomColor = UIColor(Appearance.Colors.yellow100).withAlphaComponent(0.2)
        let topColor = UIColor(Appearance.Colors.yellow100).withAlphaComponent(0)
        gradientLayer?.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer?.locations = [0.0, 0.75]
        gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1)
    }

    private func arrangeSubviews() {
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        displayValue.isUserInteractionEnabled = false
        graphView.isUserInteractionEnabled = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Appearance.GridGuide.mediumPadding2)
        ])

        stackView.addArrangedSubview(displayValue)
        stackView.addArrangedSubview(graphView)
        graphView.isHidden = true
        graphView.alpha = 0
    }

    private func setupBindings() {
        $isLoading
            .assign(to: \.isLoading, on: displayValue)
            .store(in: cancelBag)

        $bitcoinValue
            .assign(to: \.bitcoinValue, on: displayValue)
            .store(in: cancelBag)
    }
}
