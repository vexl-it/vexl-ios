//
//  ApiService.swift
//  Test
//
//  Created by Daniel Fernandez Yopla on 07.01.2022.
//
//

import Foundation
import Alamofire
import Combine
import Cleevio

// MARK: - ErrorPayload

struct ErrorPayload: Decodable {
    var message: [String]?
    var code: String?
}

// MARK: - ApiServiceType

protocol ApiServiceType: AnyObject {
    func request(endpoint: ApiRouter) -> AnyPublisher<Data, Error>
    func voidRequest(endpoint: ApiRouter) -> AnyPublisher<Void, Error>
}

// MARK: - ApiService

final class ApiService: ApiServiceType {

    struct StatusCode {
        static let ok = 200
        static let created = 201
        static let accepted = 202
        static let unauthorized = 401
        static let notFound = 404

        static let success = 200...299
        static let clientError = 400...499
        static let serverError = 500...599

        static let valid = 200...499
    }

    static let jsonContentType = "application/json"

    let sessionManager: Session

    private var cancellables: Cancellables = .init()

    init() {

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 120

        let apiInterceptor = ApiInterceptor()

        self.sessionManager = Session(
            configuration: configuration,
            interceptor: apiInterceptor)
    }

    // MARK: - Requests

    func request(endpoint: ApiRouter) -> AnyPublisher<Data, Error> {
        sessionManager.request(endpoint)
            .validate()
            .validate(contentType: [ApiService.jsonContentType])
            .publishData()
            .tryMap(handleResponse)
            .tryMap { responseData in
                guard let data = responseData else {
                    throw APIError.serverError(.internalError)
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func voidRequest(endpoint: ApiRouter) -> AnyPublisher<Void, Error> {
        sessionManager.request(endpoint)
            .validate()
            .validate(contentType: [ApiService.jsonContentType])
            .publishData()
            .tryMap(handleResponse)
            .asVoid()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func handleResponse(_ response: DataResponse<Data, AFError>) throws -> Data? {
        guard let httpResponse = response.response else {
            if let error = response.error?.asAFError?.underlyingError as? URLError, error.code == .timedOut {
                throw APIError.serverError(.timeout)
            }

            throw APIError.serverError(.internalError)
        }

        if !(ApiService.StatusCode.success ~= httpResponse.statusCode),
            let data = response.data,
            let errorPayload = try? Constants.jsonDecoder.decode(ErrorPayload.self, from: data),
            let code = errorPayload.code,
            let codeNumber = Int(code), codeNumber != 0 {
            throw APIError.clientError(.parse(code: codeNumber), message: errorPayload.message?.first)
        }

        if (ApiService.StatusCode.clientError ~= httpResponse.statusCode) ||
            (ApiService.StatusCode.serverError ~= httpResponse.statusCode) {
            switch httpResponse.statusCode {
            case 400:
                throw APIError.serverError(.badRequest)
            case 401:
                throw APIError.serverError(.unauthorized)
            case 403:
                throw APIError.serverError(.accessDenied)
            case 404:
                throw APIError.serverError(.notFound)
            default:
                throw APIError.serverError(.internalError)
            }
        }

        return response.data
    }
}
