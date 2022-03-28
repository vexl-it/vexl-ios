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
    case createUser(key: String, hash: String)

    var method: HTTPMethod {
        switch self {
        case .createUser, .importContacts, .getAvailableContacts:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        []
    }

    var path: String {
        switch self {
        case .createUser:
            return "users"
        case .getAvailableContacts:
            return "contacts/not-imported"
        case .importContacts:
            return "contacts/import"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .createUser(key, hash):
            return [:]
        case let .getAvailableContacts(contacts):
            return [:]
        case let .importContacts(contacts):
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
