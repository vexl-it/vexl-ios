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

final class OfferCreateViewModel: OfferActionViewModel {

    init(offerType: OfferType) {
        super.init(offerType: offerType, offerKey: ECCKeys())
    }

    override func setInitialValues(data: OfferInitialData) {
        currentAmountRange = data.minOffer...data.maxOffer
    }

    override func prepareOffer(encryptedOffers: [EncryptedOffer], expiration: TimeInterval) -> AnyPublisher<EncryptedOffer, Error> {
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
