//
//  CoinValueMiniGraphView.swift
//  vexl
//
//  Created by Diego Espinoza on 24/05/22.
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
