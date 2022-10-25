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

    var version: Constants.API.Version? { nil }

    var parameters: Parameters {
        switch self {
        case .suggestions(let text):
            return [
                "phrase": text,
                "count": 20,
                "lang": "cs,en,sk"
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
