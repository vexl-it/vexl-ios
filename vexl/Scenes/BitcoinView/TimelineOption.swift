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
            return "1 day"
        case .oneWeekAgo:
            return "1 week"
        case .oneMonthAgo:
            return "1 mth"
        case .threeMonthsAgo:
            return "3 mth"
        case .sixMonthsAgo:
            return "6 mth"
        case .oneYearAgo:
            return "1 year"
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
