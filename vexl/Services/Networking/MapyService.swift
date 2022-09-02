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
        let diacriticInsensitiveText = text.folding(options: .diacriticInsensitive, locale: nil).lowercased()
        return request(type: MapyResponse.self, endpoint: MapyRouter.suggestions(text: text))
            .map(\.result)
            .map { $0.map { $0.userData } }
            .map {
                Set($0.filter { suggestion in
                    let diacriticInsensitiveSuggestionCity = suggestion.city.folding(options: .diacriticInsensitive, locale: nil).lowercased()
                    return !suggestion.city.isEmpty && diacriticInsensitiveSuggestionCity.lowercased().contains(diacriticInsensitiveText.lowercased())
                })
            }
            .map(Array.init)
            .eraseToAnyPublisher()
    }
}
