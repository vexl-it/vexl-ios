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
    case createUser(key: String, hash: String, useFacebookHeader: Bool)
    case getFacebookContacts(id: String, accessToken: String)
    case getAvailableFacebookContacts(id: String, accessToken: String)

    var method: HTTPMethod {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts:
            return .get
        case .createUser, .importContacts, .getAvailableContacts:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts:
            return facebookSecurityHeader
        case .importContacts, .getAvailableContacts:
            return securityHeader
        case let .createUser(_, _, useFacebookHeader):
            if useFacebookHeader {
                return facebookSecurityHeader
            } else {
                return securityHeader
            }
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
        }
    }

    var parameters: Parameters {
        switch self {
        case .getFacebookContacts, .getAvailableFacebookContacts:
            return [:]
        case let .createUser(key, hash, _):
            return ["publicKey": key,
                    "hash": hash]
        case let .getAvailableContacts(contacts):
            return ["contacts": contacts]
        case let .importContacts(contacts):
            return ["contacts": contacts]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.contactsBaseURLString
    }
}
