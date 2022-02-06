//
//  AuthRouter.swift
//  pilulka
//
//  Created by Daniel Fernandez Yopla on 17.05.2021.
//

import Foundation
import Alamofire

 enum AuthRouter: ApiRouter {
    case refresh

    var method: HTTPMethod {
        switch self {
        case .refresh:
            return .post
        }
    }

    var path: String {
        switch self {
        case .refresh:
            return "auth/refresh"
        }
    }

    var parameters: Parameters {
        switch self {
        case .refresh:
            return [:]
        }
    }

    var authType: AuthType {
        switch self {
        case .refresh:
            return .refresh
        }
    }
 }
