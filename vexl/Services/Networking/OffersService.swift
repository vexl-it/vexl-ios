//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

protocol OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferData, Error>
}

final class OfferService: OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferData, Error> {
        Future { promise in
            promise(.success(
                OfferData.defaultValues
            ))
        }
        .eraseToAnyPublisher()
    }
}
