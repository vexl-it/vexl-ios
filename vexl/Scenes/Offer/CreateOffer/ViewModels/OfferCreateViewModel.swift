//
//  OfferCreateViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 11/07/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class OfferCreateViewModel: CreateOfferViewModel {

    override var actionTitle: String {
        switch offerType {
        case .sell:
            return L.offerCreateActionTitle()
        case .buy:
            return L.offerCreateBuyActionTitle()
        }
    }

    init(offerType: OfferType) {
        super.init(offerType: offerType, offerKey: ECCKeys())
    }

    override func setInitialValues(data: OfferInitialData) {
        currentAmountRange = data.minOffer...data.maxOffer
    }

    override func prepareOffer(encryptedOffers: [OfferPayload], expiration: TimeInterval) -> AnyPublisher<OfferPayload, Error> {
        offerService.createOffer(encryptedOffers: encryptedOffers, expiration: expiration)
    }

    override func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        offerService.storeOffers(offers: offers, areCreated: true)
    }

    override func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        chatService.createInbox(offerKey: offerKey,
                                pushToken: Constants.pushNotificationToken)
    }
}
