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
    var tokenHandler: TokenHandlerType { get }
    var securityHeader: [Header] { get }
    var facebookSecurityHeader: [Header] { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
    var authType: AuthType { get }
    var rootKey: String { get }
    var additionalHeaders: [Header] { get }
    var url: String { get }
}

extension ApiRouter {
    var tokenHandler: TokenHandlerType {
        DIContainer.shared.getDependency(type: TokenHandlerType.self)
    }

    var securityHeader: [Header] {
        let authManager = DIContainer.shared.getDependency(type: AuthenticationManager.self)
        return authManager.securityHeader?.header ?? []
    }

    var facebookSecurityHeader: [Header] {
        let authManager = DIContainer.shared.getDependency(type: AuthenticationManager.self)
        return authManager.facebookSecurityHeader?.header ?? []
    }

    var additionalHeaders: [Header] { [] }
    var rootKey: String { "data" }
    var url: String { Constants.API.baseURLString }

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
            if method == .get {
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
        case .none:
            break
        case let .basic(username, password):
            let header = HTTPHeader.authorization(username: username, password: password)
            urlRequest.setValue(header.value, forHTTPHeaderField: ApiInterceptor.authorizationHeaderKey)
        case .bearer:
            if let accessToken = tokenHandler.accessToken {
                urlRequest.setValue(accessToken.bearer, forHTTPHeaderField: ApiInterceptor.authorizationHeaderKey)
            }
        case .refresh:
            if let refreshToken = tokenHandler.refreshToken {
                urlRequest.setValue(refreshToken.bearer, forHTTPHeaderField: ApiInterceptor.authorizationHeaderKey)
            }
        }

        return urlRequest
    }
}

fileprivate extension BearerToken {
    var bearer: String {
        "Bearer \(self)"
    }
}
