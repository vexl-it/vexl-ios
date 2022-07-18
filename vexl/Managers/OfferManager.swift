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

    func sync() {
        guard cancellable == nil else {
            return
        }
        cancellable = offerService
            .getOffer(pageLimit: Constants.pageMaxLimit)
            .map(\.items)
            .flatMap { [offerRepository] payloads -> AnyPublisher<[ManagedOffer], Error> in
                offerRepository.createOffer(offerPayloads: payloads)
            }
            .catch { _ in Just([]) }
            .sink(receiveValue: { [weak self] _ in
                self?.cancellable = nil
            })
    }
}
