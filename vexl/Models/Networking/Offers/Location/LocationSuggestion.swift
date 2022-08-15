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
    let city: String
    let region: String
    let country: String
    let lat: Float
    let lon: Float

    enum CodingKeys: String, CodingKey {
        case city = "municipality"
        case region
        case country
        case lat = "latitude"
        case lon = "longitude"
    }
    
    init(city: String, lat: Float, lon: Float) {
        self.city = city
        self.lat = lat
        self.lon = lon
        self.region = ""
        self.country = ""
    }
}

//mapper = {
//    it?.result?.map { a ->
//        LocationSuggestion(
//            a.userData.municipality,
//            a.userData.region,
//            a.userData.country,
//            BigDecimal(a.userData.latitude),
//            BigDecimal(a.userData.longitude)
//        )
//    }
//    ?.filter { a -> a.city.isNotBlank() }
//    ?.distinctBy { a -> a.city }
//    ?.filter { a -> a.city.contains(query, ignoreCase = true) }.orEmpty()
//}
