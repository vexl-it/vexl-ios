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

struct LocationSuggestion: Decodable {
    let suggestion: String
    let lat: Double
    let lon: Double

    enum CodingKeys: String, CodingKey {
        case suggestion = "suggestFirstRow"
        case lat = "latitude"
        case lon = "longitude"
    }
}
