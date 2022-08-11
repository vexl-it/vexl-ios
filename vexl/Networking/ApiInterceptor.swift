//
//  ApiInterceptor.swift
//  pilulka
//
//  Created by Martin Vidovic on 07.07.2021.
//
//

import Foundation
import Alamofire
import KeychainAccess
import Combine
import Cleevio

final class ApiInterceptor: RequestInterceptor {

    static let authorizationHeaderKey = "Authorization"
    static let xPlatformHeaderKey = "X-Platform"
    static let xPlatformHeaderValue = "ios"
    static let xInstallHeaderKey = "X-Install-UUID"

    private var cancellables: Cancellables = .init()

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setDefaultHeaders()
        completion(.success(urlRequest))
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}

extension ApiInterceptor {
    private func logoutUser() {
        DispatchQueue.main.async {
            @Inject var authentication: AuthenticationManagerType
            authentication.logoutUser(force: true)
        }
    }

    public func refreshAuthorization(_ session: Session) -> AnyPublisher<Void, Error> {
        logoutUser()
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func serialize<T: Decodable>(data: Data, toObject: T.Type) throws -> T {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let jsonDict = json as? [String: Any] else {
            throw APIError.serverError(.invalidResponse(message: "Failed to parse JSON"))
        }

        if jsonDict.keys.contains("data") {
            return try T(data: data, keyPath: "data")
        }

        return try T(data: data)
    }
}
