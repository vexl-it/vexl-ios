//
//  BaseService.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Alamofire
import Combine
import Cleevio

class BaseService {
    @Inject var apiService: ApiServiceType
    let cancelBag = CancelBag()

    // MARK: - Requests

    func request<T: Decodable>(type: T.Type, endpoint: ApiRouter) -> AnyPublisher<T, Error> {
        self.request(type: type, endpoint: endpoint, scheduler: RunLoop.current)
    }

    func request<T: Decodable, S: Scheduler>(type: T.Type, endpoint: ApiRouter, scheduler: S) -> AnyPublisher<T, Error> {
        apiService.request(endpoint: endpoint)
            .receive(on: scheduler, options: nil)
            .withUnretained(self)
            .tryMap { owner, data -> T in
                try owner.serialize(data: data, toObject: T.self, rootKey: endpoint.rootKey)
            }
            .eraseToAnyPublisher()
    }

    func request(endpoint: ApiRouter) -> AnyPublisher<Void, Error> {
        apiService.voidRequest(endpoint: endpoint)
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
            throw APIError.serverError(.invalidResponse(message: "Failed to parse JSON"))
        }
    }
}
