//
//  ApiRouter.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Alamofire

struct Header {
    let key: String
    let value: String
}

enum AuthType {
    case none
    case basic(username: String, password: String)
    case bearer
    case refresh
}

protocol ApiRouter: URLRequestConvertible {
    var securityHeader: [Header] { get }
    var facebookSecurityHeader: [Header] { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
    var authType: AuthType { get }
    var rootKey: String { get }
    var additionalHeaders: [Header] { get }
    var url: String { get }
    var useURLEncoding: Bool { get }
}

extension ApiRouter {

    var securityHeader: [Header] {
        let authManager = DIContainer.shared.getDependency(type: AuthenticationManagerType.self)
        return authManager.securityHeader?.header ?? []
    }

    var facebookSecurityHeader: [Header] {
        let authManager = DIContainer.shared.getDependency(type: AuthenticationManager.self)
        return authManager.facebookSecurityHeader?.header ?? []
    }

    var additionalHeaders: [Header] { [] }
    var rootKey: String { "data" }
    var url: String { Constants.API.baseURLString }
    var useURLEncoding: Bool { false }

    public func asURL() throws -> URL {
        let urlPath = "\(url)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return try urlPath.asURL()
    }

    public func asURLRequest() throws -> URLRequest {
        // URL
        var urlRequest = URLRequest(url: try asURL())

        // HTTP method
        urlRequest.httpMethod = method.rawValue

        // Parameters encoding
        do {
            if method == .get || useURLEncoding {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            } else {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        // Adding additional headers
        for header in additionalHeaders {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }

        // Authentication
        switch authType {
        case .none, .bearer, .refresh:
            break
        case let .basic(username, password):
            let header = HTTPHeader.authorization(username: username, password: password)
            urlRequest.setValue(header.value, forHTTPHeaderField: ApiInterceptor.authorizationHeaderKey)
        }

        return urlRequest
    }
}
