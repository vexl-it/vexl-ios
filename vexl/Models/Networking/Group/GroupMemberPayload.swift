//
//  GroupMemberPayload.swift
//  vexl
//
//  Created by Adam Salih on 06.08.2022.
//

import Foundation

struct GroupMemberEnvelope: Codable {
    var newMembers: [GroupMemberPayload]
}

struct GroupMemberPayload: Codable {
    let groupUuid: String
    let publicKeys: [String]

    init?(group: ManagedGroup) {
        guard let uuid = group.uuid, let publicKeys = group.members else {
            return nil
        }
        self.groupUuid = uuid
        self.publicKeys = publicKeys
    }
}
