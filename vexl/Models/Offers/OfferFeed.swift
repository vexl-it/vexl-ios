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
        let viewData = OfferDetailViewData(offer: offer, isRequested: isRequested)
        return OfferFeed(offer: offer, viewData: viewData)
    }
}

struct OfferDetailViewData: Identifiable, Hashable {
    let id: String
    let username = "Enter random name"
    let title: String
    let isRequested: Bool
    let friendLevel: String
    let amount: String
    let paymentMethods: [OfferPaymentMethodOption]
    let fee: String?
    let offerType: OfferType

    init(offer: Offer, isRequested: Bool) {
        let currencySymbol = Constants.currencySymbol
        let formattedAmount = offer.maxAmount

        self.id = offer.offerId
        self.title = offer.description
        self.isRequested = isRequested
        self.friendLevel = offer.friendLevel == .firstDegree ? L.marketplaceDetailFriendFirst() : L.marketplaceDetailFriendSecond()
        self.amount = "\(formattedAmount)\(currencySymbol)"
        self.paymentMethods = offer.paymentMethods
        self.fee = offer.feeAmount > 0 ? "\(offer.feeAmount)%" : nil
        self.offerType = offer.type
    }

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
        OfferDetailViewData(offer: .stub, isRequested: true)
    }
}
