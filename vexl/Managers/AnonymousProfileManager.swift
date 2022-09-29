//
//  PublicKeysManager.swift
//  vexl
//
//  Created by Adam Salih on 21.09.2022.
//

import Foundation
import Combine
import CoreData

protocol AnonymousProfileManagerType {
    func getNewContacts() -> AnyPublisher<ContactPKsEnvelope, Error>
    func getNewGroupMembers() -> AnyPublisher<[GroupPKsEnvelope], Error>
    func registerNewProfiles(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error>
    func registerGroupMembers(publicKeys: [String], group: ManagedGroup, context: NSManagedObjectContext?)
}

extension AnonymousProfileManagerType {
    func registerGroupMembers(publicKeys: [String], group: ManagedGroup) {
        registerGroupMembers(publicKeys: publicKeys, group: group, context: nil)
    }
}

struct ContactPKsEnvelope {
    var firstDegree: [String]
    var secondDegree: [String]

    func publicKeys(for type: AnonymousProfileType) -> [String] {
        switch type {
        case .firstDegree:
            return firstDegree
        case .secondDegree:
            return secondDegree
        case .group:
            return []
        }
    }
}

struct GroupPKsEnvelope {
    var group: ManagedGroup
    var publicKeys: [String]
}

final class AnonymousProfileManager: AnonymousProfileManagerType {
    @Inject private var anonymousProfileRepository: AnonymousProfileRepositoryType
    @Inject private var userRepository: UserRepositoryType
    @Inject private var persistence: PersistenceStoreManagerType
    @Inject private var groupService: GroupServiceType
    @Inject private var contactsService: ContactsServiceType

    func getNewContacts() -> AnyPublisher<ContactPKsEnvelope, Error> {
        let useFacebook = false
        return contactsService
            .getContacts(fromFacebook: useFacebook, friendLevel: .first, pageLimit: Constants.pageMaxLimit)
            .flatMap { [contactsService] firstDegreeContactKeys in
                contactsService
                    .getContacts(fromFacebook: useFacebook, friendLevel: .second, pageLimit: Constants.pageMaxLimit)
                    .map { secondContactKeys -> ContactPKsEnvelope in
                        ContactPKsEnvelope(
                            firstDegree: firstDegreeContactKeys.map(\.publicKey),
                            secondDegree: secondContactKeys.map(\.publicKey)
                        )
                    }
            }
            .withUnretained(self)
            .map { owner, envelope -> ContactPKsEnvelope in
                let firstDegreeProfiles = owner.anonymousProfileRepository
                    .getProfiles(publicKeys: envelope.firstDegree, type: .firstDegree, context: nil)
                let scndDegreeProfiles = owner.anonymousProfileRepository
                    .getProfiles(publicKeys: envelope.secondDegree, type: .secondDegree, context: nil)
                return ContactPKsEnvelope(
                    firstDegree: owner.getNewPublicKeys(from: envelope.secondDegree, subtracting: firstDegreeProfiles),
                    secondDegree: owner.getNewPublicKeys(from: envelope.firstDegree, subtracting: scndDegreeProfiles)
                )
            }
            .eraseToAnyPublisher()
    }

    func getNewGroupMembers() -> AnyPublisher<[GroupPKsEnvelope], Error> {
        let groups = userRepository.user?.groups?.allObjects as? [ManagedGroup] ?? []
        var groupMap = groups.reduce(into: [String: ManagedGroup]()) { partialResult, group in
            if let uuid = group.uuid {
                partialResult[uuid] = group
            }
        }
        return groupService
            .getNewMembers(groups: groups)
            .map { payloads -> [GroupPKsEnvelope] in
                payloads
                    .compactMap { payload in
                        guard let group = groupMap[payload.groupUuid] else {
                            return nil
                        }
                        return GroupPKsEnvelope(
                            group: group,
                            publicKeys: payload.newPublicKeys
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    func registerNewProfiles(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error> {
        anonymousProfileRepository
            .saveNewContacts(envelope: envelope)
    }

    func registerGroupMembers(publicKeys: [String], group: ManagedGroup, context: NSManagedObjectContext?) {
        let context = context ?? persistence.viewContext
        let currentProfiles = anonymousProfileRepository.getProfiles(publicKeys: publicKeys, type: .group, context: context)
        let newProfileSet = getNewPublicKeys(from: publicKeys, subtracting: currentProfiles)
            .map { publicKey -> ManagedAnonymousProfile in
                let profile = ManagedAnonymousProfile(context: context)
                profile.publicKey = publicKey
                return profile
            }
        (currentProfiles + Array(newProfileSet))
            .forEach { profile in
                profile.addToGroups(group)
                let profileType = anonymousProfileRepository.getProfileType(context: context, type: .group)
                profile.addToTypes(profileType)
            }
    }

    private func getNewPublicKeys(from publicKeys: [String], subtracting profiles: [ManagedAnonymousProfile]) -> [String] {
        let memberSet = Set(publicKeys)
        let matchedProfilesSet = Set(profiles.compactMap(\.publicKey))
        return Array(memberSet.subtracting(matchedProfilesSet))
    }
}
