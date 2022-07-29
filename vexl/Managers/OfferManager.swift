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
    func sync()
}

final class OfferManager: OfferManagerType {

    @Inject private var offerService: OfferServiceType
    @Inject private var offerRepository: OfferRepositoryType
    private var cancellable: AnyCancellable?

    @UserDefault(UserDefaultKey.lastOfferSyncDate.rawValue, defaultValue: Date()) private var lastSyncDate: Date

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
                self?.cancellable = nil
            })
    }
}
