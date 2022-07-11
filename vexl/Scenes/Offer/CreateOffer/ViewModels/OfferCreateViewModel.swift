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

    override func setupInitialValues() {
        offerService
            .getInitialOfferData()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, data in
                owner.state = .loaded
                owner.amountRange = data.minOffer...data.maxOffer
                owner.currentAmountRange = data.minOffer...data.maxOffer
                owner.minFee = data.minFee
                owner.maxFee = data.maxFee
                owner.currencySymbol = data.currencySymbol
            }
            .store(in: cancelBag)
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
