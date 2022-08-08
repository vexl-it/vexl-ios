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
                        _ = payload.decode(context: context, userRepository: userRepository, into: group)
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

    func delete(group unsafeGroup: ManagedGroup) -> AnyPublisher<Void, Error> {
        let context = persistence.viewContext
        guard let group = persistence.loadSyncroniously(type: ManagedGroup.self, context: context, objectID: unsafeGroup.objectID) else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return persistence.delete(context: context) { _ in [group] }
    }
}
