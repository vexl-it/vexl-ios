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
    func getFriendLevels(publicKey: String) -> [AnonymousProfileType]
    func registerNewProfiles(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error>
    func registerGroupMembers(publicKeys: [String], group: ManagedGroup, context: NSManagedObjectContext?)
    func wipeProfiles() -> AnyPublisher<Void, Error>
}

extension AnonymousProfileManagerType {
    func registerGroupMembers(publicKeys: [String], group: ManagedGroup) {
        registerGroupMembers(publicKeys: publicKeys, group: group, context: nil)
    }
}

final class AnonymousProfileManager: AnonymousProfileManagerType {
    @Inject private var anonymousProfileRepository: AnonymousProfileRepositoryType
    @Inject private var userRepository: UserRepositoryType
    @Inject private var persistence: PersistenceStoreManagerType
    @Inject private var groupService: GroupServiceType
    @Inject private var contactsService: ContactsServiceType

    func getNewContacts() -> AnyPublisher<ContactPKsEnvelope, Error> {
        // TODO: refactor this code when facebook will start working
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
                    .getProfiles(publicKeys: envelope.firstDegree, type: .firstDegree, context: owner.persistence.newEditContext())
                let scndDegreeProfiles = owner.anonymousProfileRepository
                    .getProfiles(publicKeys: envelope.secondDegree, type: .secondDegree, context: owner.persistence.newEditContext())
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

    func getFriendLevels(publicKey: String) -> [AnonymousProfileType] {
        guard let profile = anonymousProfileRepository.getProfile(publicKey: publicKey),
              let types = profile.types?.allObjects as? [ManagedAnonymousProfileType]
        else {
            return []
        }
        return types.compactMap(\.type)

    }

    func registerNewProfiles(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error> {
        anonymousProfileRepository
            .saveNewContacts(envelope: envelope)
    }

    func registerGroupMembers(publicKeys: [String], group unsafeGroup: ManagedGroup, context: NSManagedObjectContext?) {
        let context = context ?? persistence.newEditContext()
        guard let group = context.object(with: unsafeGroup.objectID) as? ManagedGroup else {
            return
        }
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

    func wipeProfiles() -> AnyPublisher<Void, Error> {
        anonymousProfileRepository.wipe()
    }
}
