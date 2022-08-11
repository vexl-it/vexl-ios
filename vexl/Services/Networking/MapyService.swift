//
//  MapyService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 11.08.2022.
//

import Foundation
import Combine

protocol MapyServiceType {
    func getSuggestions(for text: String) -> AnyPublisher<[LocationSuggestion], Error>
}

final class MapyService: BaseService, MapyServiceType {
    func getSuggestions(for text: String) -> AnyPublisher<[LocationSuggestion], Error> {
        request(type: MapyResponse.self, endpoint: MapyRouter.suggestions(text: text))
            .map(\.result)
            .map { $0.map { $0.userData } }
            .eraseToAnyPublisher()
    }
}
