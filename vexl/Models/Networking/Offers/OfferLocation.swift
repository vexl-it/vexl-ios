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

    var asString: String? {
        let json = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
