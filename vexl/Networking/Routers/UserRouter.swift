//
//  UserRouter.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Alamofire

enum UserRouter: ApiRouter {
    case me
    case createUser(username: String, avatar: String)

    var method: HTTPMethod {
        switch self {
        case .me:
            return .get
        case .createUser:
            return .post
        }
    }

    var path: String {
        switch self {
        case .me:
            return "user/me"
        case .createUser:
            return "user"
        }
    }

    var parameters: Parameters {
        switch self {
        case .me:
            return [:]
        case .createUser(let username, let avatar):
            return ["username": username, "avatar": avatar]
        }
    }

    var authType: AuthType {
        .bearer
    }
}
