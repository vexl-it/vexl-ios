//
//  ApiService.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

// MARK: - ErrorPayload

struct ErrorPayload: Decodable {
    var message: [String]?
    var code: Int?
}

// MARK: - ApiServiceType

protocol ApiServiceType: AnyObject {
    func request(endpoint: ApiRouter) -> Observable<Data>
    func requestWithStatusCode(endpoint: ApiRouter) -> Observable<(Data, Int)>
    func voidRequest(endpoint: ApiRouter) -> Observable<Void>
}

// MARK: - ApiService

final class ApiService: ApiServiceType {
    struct StatusCode {
        static let ok = 200
        static let created = 201
        static let accepted = 202
        static let unauthorized = 401
        static let accessDenied = 403
        static let notFound = 404

        static let success = 200...299
        static let clientError = 400...499
        static let serverError = 500...599

        static let valid = 200...499
    }

    static let jsonContentType = "application/json"
    private let decoder: JSONDecoder

    @Inject private var authenticationManager: AuthenticationManager
    @Inject private var apiInterceptor: ApiInterceptor
    private lazy var sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60

        return Session(
            configuration: configuration,
            interceptor: apiInterceptor
        )
    }()

    init() {
        self.decoder = Constants.jsonDecoder
    }

    // MARK: - Requests

    func request(endpoint: ApiRouter) -> Observable<Data> {
        Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let request = self.sessionManager.request(endpoint)
                .validate()
                .validate(contentType: [ApiService.jsonContentType])
                .responseData { response in
                    do {
                        try self.validateResponse(response: response)
                        guard let data = response.data else {
                            throw APIError.serverError(.invalidResponse(message: nil))
                        }

                        observer.onNext(data)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func requestWithStatusCode(endpoint: ApiRouter) -> Observable<(Data, Int)> {
        Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let request = self.sessionManager.request(endpoint)
                .validate()
                .validate(contentType: [ApiService.jsonContentType])
                .responseData { response in
                    do {
                        try self.validateResponse(response: response)
                        guard let data = response.data, let statusCode = response.response?.statusCode else {
                            throw APIError.serverError(.invalidResponse(message: nil))
                        }

                        observer.onNext((data, statusCode))
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func voidRequest(endpoint: ApiRouter) -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let request = self.sessionManager.request(endpoint)
                .validate()
                .validate(contentType: [ApiService.jsonContentType])
                .responseData { response in
                    do {
                        try self.validateResponse(response: response)
                        observer.onNext(())
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    // MARK: - Helpers

    private func validateResponse(response: AFDataResponse<Data>) throws {
        guard let httpResponse = response.response else {
            if let error = response.error?.underlyingError as? URLError, error.code == .timedOut {
                throw APIError.serverError(.timeout)
            }

            throw response.error?.underlyingError ?? ServerError.invalidResponse(message: nil)
        }

        if !(ApiService.StatusCode.success ~= httpResponse.statusCode),
            let data = response.data,
            let errorPayload = try? JSONDecoder().decode(ErrorPayload.self, from: data),
            let code = errorPayload.code,
            code != 0 {
            throw APIError.clientError(.parse(code: code), message: errorPayload.message?.first)
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
    }
}
