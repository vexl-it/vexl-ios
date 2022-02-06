//
//  ApiInterceptor.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import Alamofire
import RxSwift
import KeychainAccess

final class ApiInterceptor: RequestInterceptor {
    static let authorizationHeaderKey = "Authorization"
    static let xPlatformHeaderKey = "X-Platform"
    static let xPlatformHeaderValue = "IOS"
    static let xInstallHeaderKey = "X-Install-UUID"
    static let xEncryptHeaderKey = "X-Encrypt"

    private let disposeBag = DisposeBag()

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
