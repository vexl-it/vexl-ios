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

    var chartEndpointRange: (from: Int, to: Int) {
        let today = Date()
        let todayFormatted = today.timeIntervalSince1970
        let optionTimeInterval: TimeInterval = {
            let day: TimeInterval = 86_400 // 60 * 60 * 24
            switch self {
            case .oneDayAgo:
                return day
            case .oneWeekAgo:
                return day * 7
            case .oneMonthAgo:
                return day * 30
            case .threeMonthsAgo:
                return day * 30 * 3
            case .sixMonthsAgo:
                return day * 30 * 6
            case .oneYearAgo:
                return day * 365
            }
        }()

        let fromDate = today.addingTimeInterval(-optionTimeInterval)
        let fromFormatted = fromDate.timeIntervalSince1970
        return (from: Int(fromFormatted), to: Int(todayFormatted))
    }

    var timeline: [String] {
        let dates = getDateIntervals(by: self == .oneWeekAgo ? 7 : 5)

        if self == .oneDayAgo {
            return dates.map { Formatters.hourFormatter.string(from: $0) }
        } else {
            return dates.map { Formatters.shortDateFormatter.string(from: $0) }
        }
    }

    private func getDateIntervals(by count: Int) -> [Date] {
        let range = chartEndpointRange
        let step = (range.to - range.from) / count

        return (0..<count)
            .map { range.from + ($0 * step) }
            .map { Date(timeIntervalSince1970: Double($0)) }
    }
}
