//
//  UserRouter.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import Alamofire

enum UserRouter: ApiRouter {
    case me

    var method: HTTPMethod {
        switch self {
        case .me:
            return .get
        }
    }

    var path: String {
        switch self {
        case .me:
            return "user/me"
        }
    }

    var parameters: Parameters {
        switch self {
        case .me:
            return [:]
        }
    }

    var authType: AuthType {
        .bearer
    }
}
