//
//  OfferFeed.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import Foundation

struct OfferFeed {
    let offer: Offer
    let viewData: OfferDetailViewData

    static func mapToOfferFeed(usingOffer offer: Offer, isRequested: Bool) -> OfferFeed {
        let currencySymbol = Constants.currencySymbol
        let friendLevel = offer.friendLevel == .firstDegree ? L.marketplaceDetailFriendFirst() : L.marketplaceDetailFriendSecond()
        let formattedAmount = offer.maxAmount
        let viewData = OfferDetailViewData(
            id: offer.offerId,
            title: offer.description,
            isRequested: isRequested,
            friendLevel: friendLevel,
            amount: "\(formattedAmount)\(currencySymbol)",
            paymentMethods: offer.paymentMethods,
            fee: offer.feeAmount > 0 ? "\(offer.feeAmount)%" : nil,
            offerType: offer.type
        )
        return OfferFeed(offer: offer, viewData: viewData)
    }
}

struct OfferDetailViewData: Identifiable, Hashable {
    let id: String
    let username = "Murakami"
    let title: String
    let isRequested: Bool
    let friendLevel: String
    let amount: String
    let paymentMethods: [OfferPaymentMethodOption]
    let fee: String?
    let offerType: OfferType

    var paymentIcons: [String] {
        paymentMethods.map(\.iconName)
    }

    var paymentLabel: String {
        guard let label = paymentMethods.first?.title else {
            return Constants.notAvailable
        }

        if paymentMethods.count > 1 {
            return "\(label) +(\(paymentMethods.count - 1))"
        }

        return label
    }

    static var stub: OfferDetailViewData {
        OfferDetailViewData(
            id: "2",
            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
            isRequested: true,
            friendLevel: "Friend",
            amount: "$10k",
            paymentMethods: [.revolut],
            fee: nil,
            offerType: .buy
        )
    }
}
