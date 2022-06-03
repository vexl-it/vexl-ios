//
//  BitcoinData.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 03.05.2022.
//

import Foundation

struct BitcoinData: Decodable {
    let priceUsd: Decimal
    let percentageChangeOneDayAgo: Double
    let percentageChangeOneWeekAgo: Double
    let percentageChangeOneMonthAgo: Double
    let percentageChangeThreeMonthsAgo: Double
    let percentageChangeSixMonthsAgo: Double
    let percentageChangeOneYearAgo: Double

    enum CodingKeys: String, CodingKey {
        case priceUsd
        case percentageChangeOneDayAgo = "priceChangePercentage24h"
        case percentageChangeOneWeekAgo = "priceChangePercentage7d"
        case percentageChangeOneMonthAgo = "priceChangePercentage30d"
        case percentageChangeThreeMonthsAgo = "priceChangePercentage60d"
        case percentageChangeSixMonthsAgo = "priceChangePercentage200d"
        case percentageChangeOneYearAgo = "priceChangePercentage1y"
    }

    func bitcoinIncreased(for option: TimelineOption) -> Bool {
        switch option {
        case .oneDayAgo:
            return percentageChangeOneDayAgo > 0
        case .oneWeekAgo:
            return percentageChangeOneWeekAgo > 0
        case .oneMonthAgo:
            return percentageChangeOneMonthAgo > 0
        case .threeMonthsAgo:
            return percentageChangeThreeMonthsAgo > 0
        case .sixMonthsAgo:
            return percentageChangeSixMonthsAgo > 0
        case .oneYearAgo:
            return percentageChangeOneYearAgo > 0
        }
    }

    func getPercentage(for option: TimelineOption) -> String {
        let decimalFormat = "%.2f"
        var twoDecimalValue: String

        switch option {
        case .oneDayAgo:
            twoDecimalValue = String(format: decimalFormat, percentageChangeOneDayAgo)
        case .oneWeekAgo:
            twoDecimalValue = String(format: decimalFormat, percentageChangeOneWeekAgo)
        case .oneMonthAgo:
            twoDecimalValue = String(format: decimalFormat, percentageChangeOneMonthAgo)
        case .threeMonthsAgo:
            twoDecimalValue = String(format: decimalFormat, percentageChangeThreeMonthsAgo)
        case .sixMonthsAgo:
            twoDecimalValue = String(format: decimalFormat, percentageChangeSixMonthsAgo)
        case .oneYearAgo:
            twoDecimalValue = String(format: decimalFormat, percentageChangeOneYearAgo)
        }

        return "\(twoDecimalValue)%"
    }
}
