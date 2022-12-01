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
    case removeContacts(contacts: [String], fromFacebook: Bool)
    case getAvailableContacts(contacts: [String])
    case getFacebookContacts(id: String, accessToken: String)
    case getAvailableFacebookContacts(id: String, accessToken: String)
    case createUser(token: String?, useFacebookHeader: Bool)
    case deleteUser
    case updateUser(token: String)
    case getContacts(useFacebookHeader: Bool, friendLevel: ContactFriendLevel, pageLimit: Int?)
    case countPhoneContacts
    case getCommonFriends(publicKeys: [String])
    case refresh(hasOffers: Bool)

    var method: HTTPMethod {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts, .getContacts, .countPhoneContacts:
            return .get
        case .createUser, .importContacts, .getAvailableContacts, .getCommonFriends, .refresh:
            return .post
        case .deleteUser, .removeContacts:
            return .delete
        case .updateUser:
            return .put
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case .importContacts, .getAvailableContacts, .deleteUser, .countPhoneContacts, .getCommonFriends, .refresh, .updateUser:
            return securityHeader
        case let .createUser(_, useFacebookHeader):
            return useFacebookHeader ? facebookSecurityHeader : securityHeader
        case let .getContacts(useFacebookHeader, _, _):
            return useFacebookHeader ? facebookSecurityHeader : securityHeader
        case let .removeContacts(_, fromFacebook):
            return fromFacebook ? facebookSecurityHeader : securityHeader
        case .getFacebookContacts, .getAvailableFacebookContacts:
            return facebookSecurityHeader
        }
    }

    var path: String {
        switch self {
        case .createUser:
            return "users"
        case .updateUser:
            return "users"
        case .getAvailableContacts:
            return "contacts/not-imported"
        case .importContacts:
            return "contacts/import"
        case .removeContacts:
            return "contacts"
        case let .getFacebookContacts(id, accessToken):
            return "facebook/\(id)/token/\(accessToken)"
        case let .getAvailableFacebookContacts(id, accessToken):
            return "facebook/\(id)/token/\(accessToken)/not-imported"
        case .getContacts:
            return "contacts/me"
        case .refresh:
            return "users/refresh"
        case .deleteUser:
            return "users/me"
        case .countPhoneContacts:
            return "contacts/count"
        case .getCommonFriends:
            return "contacts/common"
        }
    }

    var version: Constants.API.Version? { .v1 }

    var parameters: Parameters {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts, .deleteUser, .countPhoneContacts:
            return [:]
        case .updateUser(let token):
            return [
                "firebaseToken": token
            ]
        case let .createUser(token, _):
            guard let token = token else {
                return [:]
            }
            return ["firebaseToken": token]
        case let .getAvailableContacts(contacts):
            return ["contacts": contacts]
        case let .importContacts(contacts):
            return ["contacts": contacts]
        case let .removeContacts(contacts, _):
            return ["contactsToDelete": contacts]
        case let .getContacts(_, friendLevel, pageLimit):
            var params: Parameters = [:]
            switch friendLevel {
            case .first:
                params["level"] = friendLevel.rawValue
            case .second, .all:
                params["level"] = ContactFriendLevel.all.rawValue
            }
            if let pageLimit = pageLimit {
                params["limit"] = pageLimit
            }
            return params
        case let .getCommonFriends(publicKeys):
            return ["publicKeys": publicKeys]
        case let .refresh(hasOffers):
            return ["offersAlive": hasOffers]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.contactsBaseURLString
    }
}
