//
//  SyncOfferManager.swift
//  vexl
//
//  Created by Adam Salih on 17.07.2022.
//

import Foundation
import Combine
import CoreData

protocol OfferManagerType {
    var didFinishSyncing: AnyPublisher<Void, Never> { get }

    func sync()
    func sync(offers: [ManagedOffer], withPublicKeys: [String]) -> AnyPublisher<Void, Error>
}

final class OfferManager: OfferManagerType {

    @Inject private var offerService: OfferServiceType
    @Inject private var offerRepository: OfferRepositoryType
    private var cancellable: AnyCancellable?

    @UserDefault(UserDefaultKey.lastOfferSyncDate.rawValue, defaultValue: Date()) private var lastSyncDate: Date

    var didFinishSyncing: AnyPublisher<Void, Never> {
        _didFinishSyncing.eraseToAnyPublisher()
    }

    private var _didFinishSyncing: PassthroughSubject<Void, Never> = .init()

    func sync() {
        guard cancellable == nil else {
            return
        }
        let startDate = Date()
        cancellable = offerService
            .getNewOffers(pageLimit: Constants.pageMaxLimit, lastSyncDate: lastSyncDate)
            .map(\.items)
            .flatMap { [offerRepository] payloads -> AnyPublisher<[ManagedOffer], Error> in
                offerRepository.createOrUpdateOffer(offerPayloads: payloads)
            }
            .catch { _ in Just([]) }
            .sink(receiveValue: { [weak self] _ in
                self?.lastSyncDate = startDate
                self?._didFinishSyncing.send(())
                self?.cancellable = nil
            })
    }

    func sync(offers unsafeOffers: [ManagedOffer], withPublicKeys publicKeys: [String]) -> AnyPublisher<Void, Error> {
        offerRepository.sync(offers: unsafeOffers, withPublicKeys: publicKeys)
    }
}
