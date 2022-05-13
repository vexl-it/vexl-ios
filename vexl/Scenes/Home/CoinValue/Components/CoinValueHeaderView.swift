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

    override init(frame: CGRect) {
        super.init(frame: frame)
        arrangeSubviews()
        setupBindings()
        backgroundColor = R.color.green1()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentGraph() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.graphView.isHidden = false
            self.graphView.alpha = 1
        }
    }

    func hideGraph() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.graphView.isHidden = true
            self.graphView.alpha = 0
        }
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
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Appearance.GridGuide.padding)
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
