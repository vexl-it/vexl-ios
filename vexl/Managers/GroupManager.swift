//
//  GroupManager.swift
//  vexl
//
//  Created by Adam Salih on 07.08.2022.
//

import Foundation
import Combine
import UIKit

protocol GroupManagerType {
    func createGroup(name: String, logo: UIImage, expiration: Date, closureAt: Date) -> AnyPublisher<Void, Error>
    func getAllGroupMembers(group: ManagedGroup?) -> AnyPublisher<[String], Error>
    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error>
    func joinGroup(code: Int) -> AnyPublisher<Void, Error>
}

final class GroupManager: GroupManagerType {

    @Inject var groupRepository: GroupRepositoryType
    @Inject var groupService: GroupServiceType

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
