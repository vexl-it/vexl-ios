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
    func reencryptUserOffers(withPublicKeys publicKeys: [String], friendLevel: OfferFriendDegree, completionHandler: ((Error?) -> Void)?) -> AnyPublisher<Void, Error>
    func reencrypt(offers: [ManagedOffer], withPublicKeys: [String]) -> AnyPublisher<Void, Error>

    func flag(offer: ManagedOffer) -> AnyPublisher<Void, Error>
}

extension OfferManagerType {
    func reencryptUserOffers(withPublicKeys: [String], friendLevel: OfferFriendDegree) -> AnyPublisher<Void, Error> {
        reencryptUserOffers(withPublicKeys: withPublicKeys, friendLevel: friendLevel, completionHandler: nil)
    }
}

final class OfferManager: OfferManagerType {

    @Inject private var userRepository: UserRepositoryType
    @Inject private var offerService: OfferServiceType
    @Inject private var offerRepository: OfferRepositoryType
    private var cancellable: AnyCancellable?

    private let cancelBag: CancelBag = .init()

    @UserDefault(UserDefaultKey.lastOfferSyncDate.rawValue, defaultValue: Date(timeIntervalSince1970: 0)) private var lastSyncDate: Date

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
            .getNewOffers(pageLimit: Constants.pageMaxLimit, lastSyncDate: Date(timeIntervalSince1970: 0))
            .map(\.offers)
            .filter(\.isEmpty.not)
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

    func reencryptUserOffers(
        withPublicKeys publicKeys: [String],
        friendLevel: OfferFriendDegree,
        completionHandler: ((Error?) -> Void)?
    ) -> AnyPublisher<Void, Error> {
        let offers: [ManagedOffer] = {
            let allOfferSet = userRepository.user?.offers ?? NSSet()
            switch friendLevel {
            case .firstDegree:
                return allOfferSet.allObjects as? [ManagedOffer] ?? []
            case .secondDegree:
                let secondDegreeOffers = allOfferSet
                    .filtered(using: NSPredicate(format: "friendDegreeRawType == '\(OfferFriendDegree.secondDegree.rawValue)'"))
                return Array(secondDegreeOffers) as? [ManagedOffer] ?? []
            }
        }()

        return reencrypt(offers: offers, withPublicKeys: publicKeys)
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
            .eraseToAnyPublisher()
    }

    func reencrypt(offers unsafeOffers: [ManagedOffer], withPublicKeys publicKeys: [String]) -> AnyPublisher<Void, Error> {
        offerRepository.sync(offers: unsafeOffers, withPublicKeys: publicKeys)
    }

    func flag(offer: ManagedOffer) -> AnyPublisher<Void, Error> {
        guard let offerID = offer.offerID else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return Just(())
            .flatMap { [offerRepository] in
                offerRepository
                    .flag(offer: offer)
            }
            .flatMap { [offerService] in
                offerService
                    .report(offerID: offerID)
                    .nilOnError()
                    .filterNil()
            }
            .eraseToAnyPublisher()
    }
}
