//
//  GroupRepository.swift
//  vexl
//
//  Created by Adam Salih on 07.08.2022.
//

import Foundation
import Combine
import CoreData

protocol GroupRepositoryType {
    func createOrUpdateGroup(payloads: [(GroupPayload, [String])]) -> AnyPublisher<Void, Error>
    func update(group unsafeGroup: ManagedGroup, members: [String], returnOnlyNewMembers: Bool) -> AnyPublisher<[String], Error>
    func fetchGroup(uuid: String) -> ManagedGroup?
    func delete(group: ManagedGroup) -> AnyPublisher<Void, Error>
    func delete(groups: [ManagedGroup]) -> AnyPublisher<Void, Error>
}

final class GroupRepository: GroupRepositoryType {
    @Inject var persistence: PersistenceStoreManagerType
    @Inject var userRepository: UserRepositoryType
    @Inject var anonymousProfileManager: AnonymousProfileManagerType
    @Inject var anonymousProfileRepository: AnonymousProfileRepositoryType

    func createOrUpdateGroup(payloads: [(GroupPayload, [String])]) -> AnyPublisher<Void, Error> {
        guard !payloads.isEmpty else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let context = persistence.newEditContext()
        return persistence.insert(context: context) { [persistence, userRepository, anonymousProfileManager] context -> [ManagedGroup] in
            let user = userRepository.getUser(for: context)
            return payloads.compactMap { payload, members -> ManagedGroup? in
                if let uuid = payload.uuid {
                    let groups = persistence.loadSyncroniously(
                        type: ManagedGroup.self,
                        context: context,
                        predicate: NSPredicate(format: "uuid == '\(uuid)'")
                    )
                    if let group = groups.first {
                        payload.decode(context: context, userRepository: userRepository, into: group)
                        anonymousProfileManager.registerGroupMembers(publicKeys: members, group: group, context: context)
                        return nil
                    }
                }
                let group = ManagedGroup(context: context)
                return payload.decode(context: context, userRepository: userRepository, into: group)
                    .flatMap { group -> ManagedGroup in
                        anonymousProfileManager.registerGroupMembers(publicKeys: members, group: group, context: context)
                        group.user = user
                        return group
                    }
            }
        }
        .asVoid()
        .eraseToAnyPublisher()
    }

    func fetchGroup(uuid: String) -> ManagedGroup? {
        persistence.loadSyncroniously(
            type: ManagedGroup.self,
            context: persistence.viewContext,
            predicate: NSPredicate(format: "uuid == '\(uuid)'")
        ).first
    }

    func update(group unsafeGroup: ManagedGroup, members: [String], returnOnlyNewMembers: Bool) -> AnyPublisher<[String], Error> {
        persistence.update(context: persistence.viewContext) { [persistence, anonymousProfileRepository] context in
            guard let group = persistence.loadSyncroniously(type: ManagedGroup.self, context: context, objectID: unsafeGroup.objectID) else {
                return []
            }
            let currentMemberProfileSet = group.members as? Set<ManagedAnonymousProfile> ?? .init()
            let currentMemberSet = currentMemberProfileSet.compactMap(\.publicKey)

            var newMemberSet = Set(members)
            newMemberSet.subtract(currentMemberSet)

            newMemberSet.forEach { publicKey in
                let newMember = ManagedAnonymousProfile(context: context)
                newMember.publicKey = publicKey
                newMember.addToGroups(group)
                let profileType = anonymousProfileRepository.getProfileType(context: context, type: .group)
                newMember.addToTypes(profileType)
            }

            if returnOnlyNewMembers {
                return Array(newMemberSet)
            }

            let allMembers = group.members?.allObjects as? [ManagedAnonymousProfile] ?? []

            return allMembers.compactMap(\.publicKey)
        }
    }

    func delete(group unsafeGroup: ManagedGroup) -> AnyPublisher<Void, Error> {
        let context = persistence.viewContext
        guard let group = persistence.loadSyncroniously(type: ManagedGroup.self, context: context, objectID: unsafeGroup.objectID) else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return persistence.delete(context: context) { _ in [group] }
    }

    func delete(groups unsafeGroups: [ManagedGroup]) -> AnyPublisher<Void, Error> {
        let context = persistence.viewContext
        let groups: [ManagedGroup] = unsafeGroups.compactMap { unsafeGroup in
            guard let group = persistence.loadSyncroniously(type: ManagedGroup.self, context: context, objectID: unsafeGroup.objectID) else {
                return nil
            }
            return group
        }
        return persistence.delete(context: context) { _ in groups }
    }
}
