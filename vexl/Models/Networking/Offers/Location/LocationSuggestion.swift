//
//  LocationSuggestion.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 11.08.2022.
//

import Foundation

struct MapyResponse: Decodable {
    let result: [Result]

    struct Result: Decodable {
        let userData: LocationSuggestion
    }
}

struct LocationSuggestion: Decodable, Hashable {
    let suggestion: String
    let lat: Float
    let lon: Float

    enum CodingKeys: String, CodingKey {
        case suggestion = "suggestFirstRow"
        case lat = "latitude"
        case lon = "longitude"
    }
}
