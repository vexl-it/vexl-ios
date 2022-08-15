//
//  ManagedOfferLocation+.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 14.08.2022.
//

import Foundation

extension ManagedOfferLocation {
    var locationSuggestion: LocationSuggestion {
        LocationSuggestion(suggestion: city ?? "", lat: lat, lon: lon)
    }
}
