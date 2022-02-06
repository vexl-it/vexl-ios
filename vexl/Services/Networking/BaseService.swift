//
//  BaseService.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import Alamofire
import RxSwift

class BaseService {
    @Inject var apiService: ApiServiceType
    let disposeBag = DisposeBag()

    // MARK: - Requests

    func request<T: Decodable>(type: T.Type,
                               endpoint: ApiRouter,
                               scheduler: ConcurrentDispatchQueueScheduler? = nil) -> Single<T> {
        var request = apiService.request(endpoint: endpoint)

        if let scheduler = scheduler {
            request = request.observe(on: scheduler)
        }

        return request
            .withUnretained(self)
            .map { owner, data -> T in try owner.serialize(data: data, toObject: T.self, rootKey: endpoint.rootKey) }
            .asSingle()
    }

    func request(endpoint: ApiRouter) -> Single<Void> {
        apiService
            .voidRequest(endpoint: endpoint)
            .asSingle()
    }

    // MARK: - Serializer

    func serialize<T: Decodable>(data: Data, toObject: T.Type, rootKey: String) throws -> T {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let jsonDict = json as? [String: Any] {
            if jsonDict.keys.contains(rootKey) {
                return try T(data: data, keyPath: rootKey)
            }
            return try T(data: data)
        } else if json as? [[String: Any]] != nil {
            return try T(data: data)
        } else if json as? T != nil {
            return try T(data: data)
        } else {
            throw APIError.serverError(.invalidResponse(message: R.string.generic.errorParseJson()))
        }
    }
}
