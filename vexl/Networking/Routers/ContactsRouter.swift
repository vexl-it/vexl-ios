//
//  ContactsRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Alamofire

enum ContactsRouter: ApiRouter {
    case importContacts(contacts: [String])
    case getAvailableContacts(contacts: [String])
    case getFacebookContacts(id: String, accessToken: String)
    case getAvailableFacebookContacts(id: String, accessToken: String)
    case createUser(useFacebookHeader: Bool)
    case deleteUser
    case getContacts(useFacebookHeader: Bool, friendLevel: ContactFriendLevel, pageLimit: Int?)
    case countPhoneContacts
    case getCommonFriends(publicKeys: [String])

    var method: HTTPMethod {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts, .getContacts, .countPhoneContacts, .getCommonFriends:
            return .get
        case .createUser, .importContacts, .getAvailableContacts:
            return .post
        case .deleteUser:
            return .delete
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts:
            return facebookSecurityHeader
        case .importContacts, .getAvailableContacts, .deleteUser, .countPhoneContacts, .getCommonFriends:
            return securityHeader
        case let .createUser(useFacebookHeader):
            return useFacebookHeader ? facebookSecurityHeader : securityHeader
        case let .getContacts(useFacebookHeader, _, _):
            return useFacebookHeader ? facebookSecurityHeader : securityHeader
        }
    }

    var path: String {
        switch self {
        case .createUser:
            return "users"
        case .getAvailableContacts:
            return "contacts/not-imported"
        case .importContacts:
            return "contacts/import"
        case let .getFacebookContacts(id, accessToken):
            return "facebook/\(id)/token/\(accessToken)"
        case let .getAvailableFacebookContacts(id, accessToken):
            return "facebook/\(id)/token/\(accessToken)/not-imported"
        case .getContacts:
            return "contacts/me"
        case .deleteUser:
            return "users/me"
        case .countPhoneContacts:
            return "contacts/count"
        case .getCommonFriends:
            return "contacts/common"
        }
    }

    var parameters: Parameters {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts, .deleteUser, .countPhoneContacts:
            return [:]
        case .createUser:
            return [:]
        case let .getAvailableContacts(contacts):
            return ["contacts": contacts]
        case let .importContacts(contacts):
            return ["contacts": contacts]
        case let .getContacts(_, friendLevel, pageLimit):
            guard let pageLimit = pageLimit else {
                return ["level": friendLevel.rawValue]
            }
            return ["level": friendLevel.rawValue,
                    "limit": pageLimit]
        case let .getCommonFriends(publicKeys):
            return ["offerIds": publicKeys.joined(separator: ",")]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.contactsBaseURLString
    }
}
