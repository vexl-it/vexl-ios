//
//  GroupRepository.swift
//  vexl
//
//  Created by Adam Salih on 07.08.2022.
//

import Foundation
import Combine

protocol GroupRepositoryType {
    func createOrUpdateGroup(payloads: [(GroupPayload, [String])]) -> AnyPublisher<Void, Error>
    func update(group unsafeGroup: ManagedGroup, members: [String]) -> AnyPublisher<[String], Error>
    func delete(group: ManagedGroup) -> AnyPublisher<Void, Error>
}

final class GroupRepository: GroupRepositoryType {
    @Inject var persistence: PersistenceStoreManagerType
    @Inject var userRepository: UserRepositoryType

    func createOrUpdateGroup(payloads: [(GroupPayload, [String])]) -> AnyPublisher<Void, Error> {
        guard !payloads.isEmpty else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let context = persistence.newEditContext()
        return persistence.insert(context: context) { [persistence, userRepository] context -> [ManagedGroup] in
            let user = userRepository.getUser(for: context)
            return payloads.compactMap { payload, members in
                if let uuid = payload.uuid {
                    let groups = persistence.loadSyncroniously(
                        type: ManagedGroup.self,
                        context: context,
                        predicate: NSPredicate(format: "uuid == '\(uuid)'")
                    )
                    if let group = groups.first {
                        payload.decode(context: context, userRepository: userRepository, into: group)
                        return nil
                    }
                }
                let group = ManagedGroup(context: context)
                return payload.decode(context: context, userRepository: userRepository, into: group)
                    .flatMap { group -> ManagedGroup in
                        members.forEach { pubKey in
                            let profile = ManagedAnonymisedProfile(context: context)
                            profile.publicKey = pubKey
                            profile.group = group
                        }
                        group.user = user
                        return group
                    }
            }
        }
        .asVoid()
        .eraseToAnyPublisher()
    }

    func update(group unsafeGroup: ManagedGroup, members: [String]) -> AnyPublisher<[String], Error> {
        persistence.update(context: persistence.newEditContext()) { [persistence] context in
            guard let group = persistence.loadSyncroniously(type: ManagedGroup.self, context: context, objectID: unsafeGroup.objectID) else {
                return []
            }
            let currentMemberProfileSet = group.members as? Set<ManagedAnonymisedProfile> ?? .init()
            let currentMemberSet = currentMemberProfileSet.compactMap(\.publicKey)

            var newMemberSet = Set(members)
            newMemberSet.subtract(currentMemberSet)

            newMemberSet.forEach { publicKey in
                let newMember = ManagedAnonymisedProfile(context: context)
                newMember.publicKey = publicKey
                newMember.group = group
            }

            let allMembers = group.members?.allObjects as? [ManagedAnonymisedProfile] ?? []

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
}
