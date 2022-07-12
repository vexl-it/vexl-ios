//
//  OfferEditViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 11/07/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class OfferEditViewModel: OfferActionViewModel {

    override var actionTitle: String {
        switch offerType {
        case .sell:
            return L.offerUpdateActionTitle()
        case .buy:
            return L.offerUpdateBuyActionTitle()
        }
    }

    override var showDeleteButton: Bool {
        true
    }

    override var showDeleteTrigger: Bool {
        false
    }

    let offer: Offer

    init(offerType: OfferType, offer: Offer) {
        self.offer = offer
        super.init(offerType: offerType, offerKey: ECCKeys(pubKey: offer.offerPublicKey, privKey: offer.offerPrivateKey))
    }

    override func setInitialValues(data: OfferInitialData) {
        description = offer.description
        currentAmountRange = Int(offer.minAmount)...Int(offer.maxAmount)
        selectedFeeOption = offer.feeState
        feeAmount = offer.feeAmount
        selectedTradeStyleOption = offer.locationState
        selectedPaymentMethodOptions = offer.paymentMethods
        selectedBTCOption = offer.btcNetwork
        selectedFriendDegreeOption = offer.friendLevel
        selectedPriceTrigger = offer.offerPriceTrigger
        selectedPriceTriggerAmount = "\(offer.offerPriceTriggerValue)"
    }

    override func prepareOffer(encryptedOffers: [EncryptedOffer], expiration: TimeInterval) -> AnyPublisher<EncryptedOffer, Error> {
        offerService.updateOffers(encryptedOffers: encryptedOffers, offerId: offer.offerId)
    }

    override func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    override func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
