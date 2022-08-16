//
//  GroupManager.swift
//  vexl
//
//  Created by Adam Salih on 07.08.2022.
//

import Foundation
import Combine
import UIKit
import Cleevio

protocol GroupManagerType {
    func createGroup(name: String, logo: UIImage, expiration: Date, closureAt: Date) -> AnyPublisher<Void, Error>
    func getAllGroupMembers(group: ManagedGroup?) -> AnyPublisher<[String], Error>
    func updateOffersForNewMembers(groupUUID: String)
    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error>
    func joinGroup(code: Int) -> AnyPublisher<Void, Error>
}

final class GroupManager: GroupManagerType {

    @Inject var groupRepository: GroupRepositoryType
    @Inject var groupService: GroupServiceType
    @Inject var offerManager: OfferManagerType

    private let cancelBag: CancelBag = .init()

    func createGroup(name: String, logo: UIImage, expiration: Date, closureAt: Date) -> AnyPublisher<Void, Error> {
        groupService
            .createGroup(payload: GroupPayload(name: name, logo: logo, expiration: expiration, closureAt: closureAt))
            .flatMap { [groupRepository] payload in
                groupRepository
                    .createOrUpdateGroup(payloads: [(payload, [])])
            }
            .eraseToAnyPublisher()
    }

    func getAllGroupMembers(group: ManagedGroup?) -> AnyPublisher<[String], Error> {
        guard let group = group else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return groupService
            .getAllMembers(uuid: group.uuid)
            .flatMap { [groupRepository] membersPayload in
                groupRepository
                    .update(group: group, members: membersPayload.publicKeys)
            }
            .eraseToAnyPublisher()
    }

    func updateOffersForNewMembers(groupUUID: String) {
        guard let group = groupRepository.fetchGroup(uuid: groupUUID),
              let groupOfferSet = group.offers as? Set<ManagedOffer> else {
            return
        }
        let userGroupOffers = groupOfferSet.filter { $0.user != nil }
        guard !userGroupOffers.isEmpty else {
            return
        }
        groupService.getNewMembers(groups: [group])
            .compactMap(\.first?.publicKeys)
            .flatMap { [groupRepository] newMemberPublicKeys in
                groupRepository
                    .update(group: group, members: newMemberPublicKeys)
            }
            .flatMap { [offerManager] newMemeberPublicKeys in
                offerManager
                    .sync(offers: Array(userGroupOffers), withPublicKeys: newMemeberPublicKeys)
            }
            .sink()
            .store(in: cancelBag)
    }

    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error> {
        groupService
            .leave(group: group)
            .flatMap { [groupRepository] in
                groupRepository
                    .delete(group: group)
            }
            .eraseToAnyPublisher()
    }

    func joinGroup(code: Int) -> AnyPublisher<Void, Error> {
        Just(())
            .flatMap { [groupService] in
                groupService.joinGroup(code: code)
            }
            .flatMap { [groupService] in
                groupService.getGroup(code: code)
            }
            .flatMap { [groupService] payload in
                groupService.getAllMembers(uuid: payload.uuid)
                    .map { (payload, $0.publicKeys) }
                    .eraseToAnyPublisher()
            }
            .flatMap { [groupRepository] groupPayload, members in
                groupRepository.createOrUpdateGroup(payloads: [ (groupPayload, members) ])
            }
            .eraseToAnyPublisher()
    }
}
