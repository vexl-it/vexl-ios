//
//  ReencryptionManager.swift
//  vexl
//
//  Created by Adam Salih on 28.09.2022.
//

import Foundation
import Combine
import Cleevio

protocol ReencryptionManagerType {
    func synchronizeContacts()
    func synchronizeGroups()
}

final class ReencryptionManager: ReencryptionManagerType {
    @Inject private var anonymousProfileManager: AnonymousProfileManagerType
    @Inject private var offerManager: OfferManagerType
    @Inject private var groupManager: GroupManagerType

    private var cancelBag: CancelBag = .init()

    func synchronizeContacts() {
        anonymousProfileManager.getNewContacts()
            .flatMap { [offerManager] envelope in
                offerManager.reencryptUserOffers(withPublicKeys: envelope.firstDegree, friendLevel: .firstDegree)
                    .map { envelope }
            }
            .flatMap { [offerManager] envelope in
                offerManager.reencryptUserOffers(withPublicKeys: envelope.secondDegree, friendLevel: .secondDegree)
                    .map { envelope }
            }
            .flatMap { [anonymousProfileManager] envelope in
                anonymousProfileManager.registerNewProfiles(envelope: envelope)
            }
            .sink()
            .store(in: cancelBag)
    }

    func synchronizeGroups() {
        let envelopes = anonymousProfileManager
            .getNewGroupMembers()
            .flatMap { [offerManager] envelopes -> AnyPublisher<[GroupPKsEnvelope], Error> in
                envelopes
                    .map { envelope -> AnyPublisher<Void, Error> in
                        let offers = envelope.group.offers?.allObjects as? [ManagedOffer] ?? []
                        let userOffers = offers.filter { $0.user != nil }
                        return offerManager.reencrypt(offers: userOffers, withPublicKeys: envelope.publicKeys)
                    }
                    .zip()
                    .map { envelopes }
                    .eraseToAnyPublisher()
            }

        envelopes
            .nilOnError()
            .sink(receiveValue: { [anonymousProfileManager] envelopes in
                envelopes?.forEach { envelope in
                    anonymousProfileManager.registerGroupMembers(publicKeys: envelope.publicKeys, group: envelope.group)
                }
            })
            .store(in: cancelBag)
    }
}
