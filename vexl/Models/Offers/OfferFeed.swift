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
