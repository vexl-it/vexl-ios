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
    @Inject var offerService: OfferServiceType
    @Inject var userRepository: UserRepositoryType

    @UserDefault(.refreshDate, defaultValue: Date(timeIntervalSince1970: 0))
    var lastRefresh: Date

    func refresh() -> AnyPublisher<Void, Error> {
        guard lastRefresh.addingTimeInterval(.day).compare(Date()) == .orderedAscending else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let userOffers = userRepository.getOffers()
        let adminIds = userOffers.compactMap(\.adminID)
        return Just(())
            .flatMap { [offerService] in
                offerService.refresh(adminIDs: adminIds)
            }
            .handleEvents(receiveOutput: { [weak self] in
                self?.lastRefresh = Date()
            })
            .eraseToAnyPublisher()
    }
}
