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
    var city: String {
        if let municipality = municipality, !municipality.isEmpty {
            return municipality
        }
        if let suggestFirstRow = suggestFirstRow, !suggestFirstRow.isEmpty {
            return suggestFirstRow
        }
        return ""
    }

    let municipality: String?
    let suggestFirstRow: String?
    let suggestSecondRow: String?
    let region: String
    let country: String
    let lat: Float
    let lon: Float

    enum CodingKeys: String, CodingKey {
        case region
        case country
        case lat = "latitude"
        case lon = "longitude"
        case municipality
        case suggestFirstRow
        case suggestSecondRow
    }

    init(city: String, lat: Float, lon: Float) {
        self.municipality = city
        self.suggestFirstRow = nil
        self.suggestSecondRow = nil
        self.lat = lat
        self.lon = lon
        self.region = ""
        self.country = ""
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(city)
    }

    static func == (lhs: LocationSuggestion, rhs: LocationSuggestion) -> Bool {
        lhs.city == rhs.city
    }
}
