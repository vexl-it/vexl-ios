//
//  GroupRouter.swift
//  vexl
//
//  Created by Adam Salih on 06.08.2022.
//

import Foundation
import Alamofire

enum GroupRouter: ApiRouter {
    case leaveGroup(uuid: String)
    case getGroup(code: Int)
    case createGroup(groupPayload: GroupPayload)
    case getNewMembers(groupMemberPayloads: [GroupMemberPayload])
    case joinGroup(code: Int)
    case getExpiredGroups(uuids: [String])
    case getUsersGroups

    var method: HTTPMethod {
        switch self {
        case .leaveGroup:
            return .put
        case .getGroup, .getUsersGroups:
            return .get
        case .createGroup, .getNewMembers, .joinGroup, .getExpiredGroups:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .leaveGroup:
            return "groups/leave"
        case .getGroup, .createGroup:
            return "groups"
        case .getNewMembers:
            return "groups/members"
        case .joinGroup:
            return "groups/join"
        case .getExpiredGroups:
            return "groups/expired"
        case .getUsersGroups:
            return "groups/me"
        }
    }

    var version: Constants.API.Version? { .v1 }

    var parameters: Parameters {
        switch self {
        case .leaveGroup(let uuid):
            return ["groupUuid": uuid]
        case .getGroup(let code):
            return ["code": code]
        case .createGroup(let groupPayload):
            return groupPayload.asJson
        case .getNewMembers(let groupMemberPayloads):
            return [
                "groups": groupMemberPayloads
                    .map { payload in
                        [
                            "groupUuid": payload.groupUuid,
                            "publicKeys": payload.publicKeys
                        ]
                    }
            ]
        case .joinGroup(let code):
            return ["code": code]
        case .getExpiredGroups(let uuids):
            return ["uuids": uuids]
        case .getUsersGroups:
            return [:]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.contactsBaseURLString
    }
}
