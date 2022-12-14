//
//  GroupMemberPayload.swift
//  vexl
//
//  Created by Adam Salih on 06.08.2022.
//

import Foundation

struct GroupMemberEnvelope: Codable {
    var newMembers: [GroupNewMemberPayload]
}

struct GroupNewMemberPayload: Codable {
    let groupUuid: String
    let newPublicKeys: [String]
    var removedPublicKeys: [String] = []
}

struct GroupMemberPayload: Codable {
    let groupUuid: String
    let publicKeys: [String]

    init?(group: ManagedGroup) {
        guard let uuid = group.uuid, let members = group.members?.allObjects as? [ManagedAnonymousProfile] else {
            return nil
        }
        self.groupUuid = uuid
        self.publicKeys = members.compactMap(\.publicKey)
    }

    init(groupUuid: String, publicKeys: [String]) {
        self.groupUuid = groupUuid
        self.publicKeys = publicKeys
    }
}
