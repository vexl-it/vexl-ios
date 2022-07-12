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

    var offer: Offer

    init(offerType: OfferType, offer: Offer) {
        self.offer = offer
        super.init(offerType: offerType, offerKey: ECCKeys(pubKey: offer.offerPublicKey, privKey: offer.offerPrivateKey))
    }

    override func setInitialValues(data: OfferInitialData) {
        offerService
            .getStoredOffer(withId: offer.offerId)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, storedOffer in

                // TODO: - find a way to improve this part

                owner.offer = storedOffer
                owner.offerKey = ECCKeys(pubKey: storedOffer.offerPublicKey, privKey: storedOffer.offerPrivateKey)

                owner.description = storedOffer.description
                owner.currentAmountRange = Int(storedOffer.minAmount)...Int(storedOffer.maxAmount)
                owner.selectedFeeOption = storedOffer.feeState
                owner.feeAmount = storedOffer.feeAmount
                owner.selectedTradeStyleOption = storedOffer.locationState
                owner.selectedPaymentMethodOptions = storedOffer.paymentMethods
                owner.selectedBTCOption = storedOffer.btcNetwork
                owner.selectedFriendDegreeOption = storedOffer.friendLevel
                owner.selectedPriceTrigger = storedOffer.offerPriceTrigger
                owner.selectedPriceTriggerAmount = "\(storedOffer.offerPriceTriggerValue)"
            }
            .store(in: cancelBag)
    }

    override func prepareOffer(encryptedOffers: [EncryptedOffer], expiration: TimeInterval) -> AnyPublisher<EncryptedOffer, Error> {
        offerService.updateOffers(encryptedOffers: encryptedOffers, offerId: offer.offerId)
    }

    override func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        offerService.updateStoredOffers(offers: offers)
    }

    override func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
