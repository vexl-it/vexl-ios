//
//  OfferLocation.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import Foundation

struct OfferLocation: Codable {
    let latitude: Float
    let longitude: Float
    let radius: Float
    let city: String

    var asString: String? {
        let json: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius,
            "city": city
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    init?(managedLocation: ManagedOfferLocation) {
        guard let city = managedLocation.city,
              managedLocation.lat > 0,
              managedLocation.lon > 0 else { return nil }

        self.latitude = managedLocation.lat
        self.longitude = managedLocation.lon
        self.radius = 1
        self.city = city
    }

    init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        do {
            self = try JSONDecoder().decode(OfferLocation.self, from: data)
        } catch {
            return nil
        }
    }
}
