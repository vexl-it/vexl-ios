//
//  BitcoinData.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 03.05.2022.
//

import Foundation

struct BitcoinData: Decodable {
    let priceUsd: Decimal

    static var noValue: BitcoinData {
        BitcoinData(priceUsd: 0)
    }
}
