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
    @Inject var offerService: OfferServiceType
    @Inject var offerRepository: OfferRepositoryType
    @Inject var contactService: ContactsServiceType
    @Inject var authenticationManager: AuthenticationManagerType

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
                    .update(group: group, members: membersPayload.publicKeys, returnOnlyNewMembers: false)
            }
            .eraseToAnyPublisher()
    }

    func updateOffersForNewMembers(groupUUID: String) {
        guard let group = groupRepository.fetchGroup(uuid: groupUUID),
              let groupOfferSet = group.offers as? Set<ManagedOffer> else {
            return
        }
        let userGroupOffers = groupOfferSet.filter { $0.user != nil }
        groupService.getNewMembers(groups: [group])
            .compactMap(\.first?.publicKeys)
            .flatMap { [groupRepository] newMemberPublicKeys in
                groupRepository
                    .update(group: group, members: newMemberPublicKeys, returnOnlyNewMembers: true)
            }
            .flatMap { [offerManager] newMemeberPublicKeys -> AnyPublisher<Void, Error> in
                guard !userGroupOffers.isEmpty else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return offerManager
                    .sync(offers: Array(userGroupOffers), withPublicKeys: newMemeberPublicKeys)
            }
            .sink()
            .store(in: cancelBag)
    }

    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error> { // swiftlint:disable:this function_body_length
        let allPublicKeys: AnyPublisher<UserContacts, Never> = Just(())
            .flatMap { [contactService] () -> AnyPublisher<UserContacts, Never> in
                contactService
                    .getAllContacts(friendLevel: .second, hasFacebookAccount: false, pageLimit: Constants.pageMaxLimit)
                    .nilOnError()
                    .map { $0 ?? UserContacts(phone: [], facebook: []) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let deleteMemberPublicKeys = allPublicKeys
            .map { (contacts: UserContacts) -> [String] in
                let allContacts: [ContactKey] = contacts.phone + contacts.facebook
                let myContactSet: Set<String> = Set(allContacts.map(\.publicKey))
                let groupMembers: [ManagedAnonymisedProfile] = group.members?.allObjects as? [ManagedAnonymisedProfile] ?? []
                var memberSet: Set<String> = Set(groupMembers.compactMap(\.publicKey))
                memberSet.subtract(myContactSet)
                let members: [String] = Array(memberSet)
                return members
            }

        let deleteOffers = deleteMemberPublicKeys
            .flatMap { [offerService] (members: [String]) -> AnyPublisher<Void, Never> in
                let offerSet = group.offers?.filtered(using: NSPredicate(format: "user != nil")) as? Set<ManagedOffer> ?? .init()
                let offers = Array(offerSet).compactMap(\.id)
                guard !offerSet.isEmpty && !members.isEmpty else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
                return offerService
                    .deleteOfferPrivateParts(offerIds: offers, publicKeys: members)
                    .nilOnError()
                    .asVoid()
                    .eraseToAnyPublisher()
            }
            .flatMap { [offerRepository] () -> AnyPublisher<Void, Never> in
                let groupOfferSet = group.offers?.filtered(using: NSPredicate(format: "user == nil")) as? Set<ManagedOffer> ?? .init()
                let groupOfferIds = Array(groupOfferSet).compactMap(\.id)
                guard !groupOfferIds.isEmpty else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
                return offerRepository
                    .deleteOffers(with: groupOfferIds)
                    .nilOnError()
                    .asVoid()
                    .eraseToAnyPublisher()
            }

        let deleteGroup = deleteOffers
            .flatMap { [groupService] () -> AnyPublisher<Void, Never> in
                groupService
                    .leave(group: group)
                    .nilOnError()
                    .asVoid()
                    .eraseToAnyPublisher()
            }
            .flatMap { [groupRepository] () -> AnyPublisher<Void, Error> in
                groupRepository
                    .delete(group: group)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return deleteGroup
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
