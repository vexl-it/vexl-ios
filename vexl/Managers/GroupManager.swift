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
    func reencryptOffersForNewMembers(groupUUID: String, completionHandler: ((Error?) -> Void)?)
    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error>
    func joinGroup(code: Int) -> AnyPublisher<Void, Error>
}

extension GroupManagerType {
    func updateOffersForNewMembers(groupUUID: String) {
        reencryptOffersForNewMembers(groupUUID: groupUUID, completionHandler: nil)
    }
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
                    .update(group: group, members: membersPayload.newPublicKeys, returnOnlyNewMembers: false)
            }
            .eraseToAnyPublisher()
    }

    func reencryptOffersForNewMembers(groupUUID: String, completionHandler: ((Error?) -> Void)?) {
        guard let group = groupRepository.fetchGroup(uuid: groupUUID),
              let groupOfferSet = group.offers as? Set<ManagedOffer> else {
            completionHandler?(nil)
            return
        }
        let userGroupOffers = groupOfferSet.filter { $0.user != nil }
        groupService.getNewMembers(groups: [group])
            .compactMap { newMembers in
                let pubKeys = newMembers.first?.newPublicKeys
                guard pubKeys?.isEmpty == false else {
                    completionHandler?(nil)
                    return nil
                }
                return pubKeys
            }
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
                    .reencrypt(offers: Array(userGroupOffers), withPublicKeys: newMemeberPublicKeys)
            }
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
                let groupMembers: [ManagedAnonymousProfile] = group.members?.allObjects as? [ManagedAnonymousProfile] ?? []
                var memberSet: Set<String> = Set(groupMembers.compactMap(\.publicKey))
                memberSet.subtract(myContactSet)
                let members: [String] = Array(memberSet)
                return members
            }

        let deleteOffers = deleteMemberPublicKeys
            .flatMap { [offerService] (members: [String]) -> AnyPublisher<Void, Never> in
                let offerSet = group.offers?.filtered(using: NSPredicate(format: "user != nil")) as? Set<ManagedOffer> ?? .init()
                let offers = Array(offerSet).compactMap(\.adminID)
                guard !offerSet.isEmpty && !members.isEmpty else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
                return offerService
                    .deleteOfferPrivateParts(adminIDs: offers, publicKeys: members)
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
                    .map { (payload, $0.newPublicKeys) }
                    .eraseToAnyPublisher()
            }
            .flatMap { [groupRepository] groupPayload, members in
                groupRepository.createOrUpdateGroup(payloads: [ (groupPayload, members) ])
            }
            .eraseToAnyPublisher()
    }
}
