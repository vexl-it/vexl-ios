//
//  MarketplaceHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import UIKit

final class HomeHeaderView: UIControl {

    let displayValue = HomeCoinValueView()
    let graphView = HomeCoinGraphView()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        arrangeSubviews()
        backgroundColor = R.color.green1()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
