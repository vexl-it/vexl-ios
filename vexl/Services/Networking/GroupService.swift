//
//  GroupService.swift
//  vexl
//
//  Created by Adam Salih on 06.08.2022.
//

import Foundation
import Combine

protocol GroupServiceType {
    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error>
    func getGroup(code: Int) -> AnyPublisher<GroupPayload, Error>
    func createGroup(group: ManagedGroup) -> AnyPublisher<GroupPayload, Error>
    func getNewMembers(groups: [ManagedGroup]) -> AnyPublisher<[GroupMemberPayload], Error>
    func joinGroup(code: Int) -> AnyPublisher<Void, Error>
    func getExpiredGroups(groups: [ManagedGroup]) -> AnyPublisher<[GroupPayload], Error>
    func getUserGroups() -> AnyPublisher<[GroupPayload], Error>
}

final class GroupService: BaseService, GroupServiceType {
    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error> {
        guard let uuid = group.uuid else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return request(endpoint: GroupRouter.leaveGroup(uuid: uuid))
    }

    func getGroup(code: Int) -> AnyPublisher<GroupPayload, Error> {
        request(type: GroupPayload.self, endpoint: GroupRouter.getGroup(code: code))
    }

    func createGroup(group: ManagedGroup) -> AnyPublisher<GroupPayload, Error> {
        guard let payload = GroupPayload(group: group) else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return request(
            type: GroupPayload.self,
            endpoint: GroupRouter.createGroup(
                groupPayload: payload
            )
        )
    }

    func getNewMembers(groups: [ManagedGroup]) -> AnyPublisher<[GroupMemberPayload], Error> {
        let payloads = groups
            .compactMap(GroupMemberPayload.init)
        guard !payloads.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return request(
            type: GroupMemberEnvelope.self,
            endpoint: GroupRouter.getNewMembers(
                groupMemberPayloads: payloads
            )
        )
        .map(\.newMembers)
        .eraseToAnyPublisher()
    }

    func joinGroup(code: Int) -> AnyPublisher<Void, Error> {
        request(endpoint: GroupRouter.joinGroup(code: code))
    }

    func getExpiredGroups(groups: [ManagedGroup]) -> AnyPublisher<[GroupPayload], Error> {
        let uuids = groups.compactMap(\.uuid)
        guard !uuids.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return request(type: GroupEnvelope.self, endpoint: GroupRouter.getExpiredGroups(uuids: uuids))
            .map(\.groupResponse)
            .eraseToAnyPublisher()
    }

    func getUserGroups() -> AnyPublisher<[GroupPayload], Error> {
        request(type: GroupEnvelope.self, endpoint: GroupRouter.getUsersGroups)
            .map(\.groupResponse)
            .eraseToAnyPublisher()
    }
}
