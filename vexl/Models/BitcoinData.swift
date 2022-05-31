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

    func bitcoinIncrease(for option: TimelineOption) -> Bool {
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
        var twoDecimalValue: String

        switch option {
        case .oneDayAgo:
            twoDecimalValue = String(format: "%.2f", percentageChangeOneDayAgo)
        case .oneWeekAgo:
            twoDecimalValue = String(format: "%.2f", percentageChangeOneWeekAgo)
        case .oneMonthAgo:
            twoDecimalValue = String(format: "%.2f", percentageChangeOneMonthAgo)
        case .threeMonthsAgo:
            twoDecimalValue = String(format: "%.2f", percentageChangeThreeMonthsAgo)
        case .sixMonthsAgo:
            twoDecimalValue = String(format: "%.2f", percentageChangeSixMonthsAgo)
        case .oneYearAgo:
            twoDecimalValue = String(format: "%.2f", percentageChangeOneYearAgo)
        }

        return "\(twoDecimalValue)%"
    }
}
