//
//  RefreshManager.swift
//  vexl
//
//  Created by Adam Salih on 24.11.2022.
//

import Foundation
import Combine

protocol RefreshManagerType {
    func refresh() -> AnyPublisher<Void, Error>
}

final class RefreshManager: RefreshManagerType {
    @Inject var contactsService: ContactsServiceType
    @Inject var offerService: OfferServiceType
    @Inject var userRepository: UserRepositoryType

    func refresh() -> AnyPublisher<Void, Error> {
        let userOffers = userRepository.getOffers()
        let adminIds = userOffers.compactMap(\.adminID)
        return Just(())
            .flatMap { [offerService] in
                offerService.refresh(adminIDs: adminIds)
            }
            .flatMap { [contactsService] in
                contactsService.refresh(hasOffers: userOffers.isEmpty.not)
            }
            .eraseToAnyPublisher()
    }
}
