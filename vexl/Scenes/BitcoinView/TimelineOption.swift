//
//  TimelineOption.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 31.05.2022.
//

import Foundation

enum TimelineOption: CaseIterable, Identifiable {
    case oneDayAgo
    case oneWeekAgo
    case oneMonthAgo
    case threeMonthsAgo
    case sixMonthsAgo
    case oneYearAgo

    var id: String { title }

    var title: String {
        switch self {
        case .oneDayAgo:
            return L.marketplaceCurrency1day()
        case .oneWeekAgo:
            return L.marketplaceCurrency1week()
        case .oneMonthAgo:
            return L.marketplaceCurrency1month()
        case .threeMonthsAgo:
            return L.marketplaceCurrency3month()
        case .sixMonthsAgo:
            return L.marketplaceCurrency6month()
        case .oneYearAgo:
            return L.marketplaceCurrency1year()
        }
    }

    func variation(percentage: String) -> String {
        switch self {
        case .oneDayAgo:
            return L.marketplaceCurrencyVariation1day(percentage)
        case .oneWeekAgo:
            return L.marketplaceCurrencyVariation1week(percentage)
        case .oneMonthAgo:
            return L.marketplaceCurrencyVariation1month(percentage)
        case .threeMonthsAgo:
            return L.marketplaceCurrencyVariation3month(percentage)
        case .sixMonthsAgo:
            return L.marketplaceCurrencyVariation6month(percentage)
        case .oneYearAgo:
            return L.marketplaceCurrencyVariation1year(percentage)
        }
    }
}
