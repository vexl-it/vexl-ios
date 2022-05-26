//
//  OfferFeed.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import Foundation

struct OfferFeed {
    let offer: Offer
    let viewData: OfferFeedViewData

    static func mapToOfferFeed(usingOffer offer: Offer) -> OfferFeed {
        let currencySymbol = Constants.currencySymbol
        let friendLevel = offer.friendLevel == .firstDegree ? L.marketplaceDetailFriendFirst() : L.marketplaceDetailFriendSecond()
        let formattedAmount = offer.maxAmount
        let viewData = OfferFeedViewData(
            id: offer.offerId,
            title: offer.description,
            isRequested: false,
            friendLevel: friendLevel,
            amount: "\(formattedAmount)\(currencySymbol)",
            paymentMethods: offer.paymentMethods,
            fee: offer.feeAmount > 0 ? "\(offer.feeAmount)%" : nil,
            offerType: offer.type
        )
        return OfferFeed(offer: offer, viewData: viewData)
    }
}

struct OfferFeedViewData: Identifiable, Hashable {
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
}
