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
    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error>
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

    func leave(group: ManagedGroup) -> AnyPublisher<Void, Error> {
        groupService
            .leave(group: group)
            .flatMap { [groupRepository] in
                groupRepository
                    .delete(group: group)
            }
            .eraseToAnyPublisher()
    }
}
