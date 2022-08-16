//
//  ManagedOfferLocation+.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 14.08.2022.
//

import Foundation

extension ManagedOfferLocation {
    var locationSuggestion: LocationSuggestion {
        LocationSuggestion(city: city ?? "", lat: lat, lon: lon)
    }

    var offerLocation: OfferLocation? {
        OfferLocation(managedLocation: self)
    }
}
