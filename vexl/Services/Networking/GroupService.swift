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
    func createGroup(payload: GroupPayload) -> AnyPublisher<GroupPayload, Error>
    func getNewMembers(groups: [ManagedGroup]) -> AnyPublisher<[GroupNewMemberPayload], Error>
    func getAllMembers(uuid: String?) -> AnyPublisher<GroupNewMemberPayload, Error>
    func getAllMembers(uuids: [String]) -> AnyPublisher<[GroupNewMemberPayload], Error>
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

    func createGroup(payload: GroupPayload) -> AnyPublisher<GroupPayload, Error> {
        request(
            type: GroupPayload.self,
            endpoint: GroupRouter.createGroup(
                groupPayload: payload
            )
        )
    }

    func getNewMembers(groups: [ManagedGroup]) -> AnyPublisher<[GroupNewMemberPayload], Error> {
        getNewMembers(memberRequest: groups.compactMap(GroupMemberPayload.init))
    }

    func getAllMembers(uuid: String?) -> AnyPublisher<GroupNewMemberPayload, Error> {
        guard let uuid = uuid else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return getNewMembers(memberRequest: [ GroupMemberPayload(groupUuid: uuid, publicKeys: []) ])
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }

    func getAllMembers(uuids: [String]) -> AnyPublisher<[GroupNewMemberPayload], Error> {
        guard !uuids.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let payloads = uuids
            .map { ($0, [] as [String]) }
            .map(GroupMemberPayload.init)

        return getNewMembers(memberRequest: payloads)
    }

    private func getNewMembers(memberRequest payloads: [GroupMemberPayload]) -> AnyPublisher<[GroupNewMemberPayload], Error> {
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
