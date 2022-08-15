//
//  OfferLocation.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import Foundation

struct OfferLocation: Codable, Hashable {
    let latitude: Float
    let longitude: Float
    let city: String

    var asString: String? {
        let json: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "city": city
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    ///
    /// Use this init when creating from local storage
    ///
    init?(managedLocation: ManagedOfferLocation) {
        guard let city = managedLocation.city,
              managedLocation.lat > 0,
              managedLocation.lon > 0 else { return nil }

        self.latitude = managedLocation.lat
        self.longitude = managedLocation.lon
        self.city = city
    }

    ///
    /// Use this init when initializing from Networking
    ///
    init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        do {
            self = try JSONDecoder().decode(OfferLocation.self, from: data)
        } catch {
            return nil
        }
    }

    ///
    /// Use this init when creating from autocomplete on offer creation, update or filter
    ///
    init?(locationSuggestion: LocationSuggestion) {
        self.latitude = locationSuggestion.lat
        self.longitude = locationSuggestion.lon
        self.city = locationSuggestion.city
    }
}
