//
//  BuySellViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Foundation
import Cleevio
import Combine

final class BuySellViewModel: ViewModelType, ObservableObject {

    enum Option {
        case buy, sell
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: Option = .buy

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showOffer
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    // TODO: - Update to real data when services are ready

    var currencySymbol: String {
        "$"
    }
    var amount: String {
        "1234.4"
    }

    var buyFilters: [BuySellFilterData] {
        [
            .init(id: 1, title: "Revolut"),
            .init(id: 2, title: "up to 10K"),
            .init(id: 3, title: "▽")
        ]
    }

    var sellFilters: [BuySellFilterData] {
        [
            .init(id: 4, title: "Filter offers ▽")
        ]
    }

    var feedItems: [BuySellFeedViewData] = [
        BuySellFeedViewData(id: 1,
                            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                            isRequested: false,
                            location: "Prague",
                            maxAmount: "up to $10k",
                            paymentMethod: "Revolut",
                            fee: nil),
        BuySellFeedViewData(id: 2,
                            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                            isRequested: true,
                            location: "Prague",
                            maxAmount: "up to $10k",
                            paymentMethod: "Revolut",
                            fee: "Wants $30 fee per transaction"),
        BuySellFeedViewData(id: 3,
                            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                            isRequested: true,
                            location: "Prague",
                            maxAmount: "up to $10k",
                            paymentMethod: "Revolut",
                            fee: nil),
        BuySellFeedViewData(id: 4,
                            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                            isRequested: false,
                            location: "Prague",
                            maxAmount: "up to $10k",
                            paymentMethod: "Revolut",
                            fee: "Wants $30 fee per transaction")
    ]

    private let cancelBag: CancelBag = .init()
}
