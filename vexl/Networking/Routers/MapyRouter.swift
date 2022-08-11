//
//  MapyRouter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 11.08.2022.
//

import Foundation
import Alamofire

enum MapyRouter: ApiRouter {
    case suggestions(text: String)

    var method: HTTPMethod {
        switch self {
        case .suggestions:
            return .get
        }
    }

    var path: String {
        switch self {
        case .suggestions:
            return "suggest"
        }
    }

    var parameters: Parameters {
        switch self {
        case .suggestions(let text):
            return [
                "phrase": text,
                "count": 5,
                "lang": "cs"
            ]
        }
    }

    var authType: AuthType {
        .none
    }

    var url: String {
        Constants.API.mapyBaseURLString
    }
}
