//
//  SyncOfferManager.swift
//  vexl
//
//  Created by Adam Salih on 17.07.2022.
//

import Foundation
import Combine
import CoreData
import Cleevio

protocol OfferManagerType {
    var didFinishSyncing: AnyPublisher<Void, Never> { get }

    func sync()
    func syncUserOffers(withPublicKeys: [String], completionHandler: ((Error?) -> Void)?)
    func sync(offers: [ManagedOffer], withPublicKeys: [String]) -> AnyPublisher<Void, Error>
}

final class OfferManager: OfferManagerType {

    @Inject private var userRepository: UserRepositoryType
    @Inject private var offerService: OfferServiceType
    @Inject private var offerRepository: OfferRepositoryType
    private var cancellable: AnyCancellable?

    private let cancelBag: CancelBag = .init()

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
            .asVoid()
            .flatMap { [offerRepository] in
                offerRepository.getKnownOffers()
            }
            .flatMap { [offerService] knownOfferIDs in
                offerService.getDeletedOffers(knownOffers: knownOfferIDs)
            }
            .flatMap { [offerRepository] offerIDsToDelete in
                offerRepository.deleteOffers(offerIDs: offerIDsToDelete)
            }
            .catch { _ in Just(()) }
            .sink(receiveValue: { [weak self] in
                self?.lastSyncDate = startDate
                self?._didFinishSyncing.send(())
                self?.cancellable = nil
            })
    }

    func syncUserOffers(withPublicKeys publicKeys: [String], completionHandler: ((Error?) -> Void)?) {
        let offers = userRepository.user?.offers?.allObjects as? [ManagedOffer] ?? []
        sync(offers: offers, withPublicKeys: publicKeys)
            .handleEvents(
                receiveOutput: {
                    completionHandler?(nil)
                },
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        completionHandler?(error)
                    case .finished:
                        break
                    }
                }
            )
            .sink()
            .store(in: cancelBag)
    }

    func sync(offers unsafeOffers: [ManagedOffer], withPublicKeys publicKeys: [String]) -> AnyPublisher<Void, Error> {
        offerRepository.sync(offers: unsafeOffers, withPublicKeys: publicKeys)
    }
}
