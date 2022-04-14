//
//  BuySellViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Foundation
import Cleevio
import Combine

struct FeedItem: Identifiable {
    let id: Int
    let title: String
    let isRequested: Bool
    let location: String
}

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

    var currencySymbol: String {
        "$"
    }
    var amount: String {
        "1234.4"
    }

    var buyFilters: [BuySellFilterView.FilterItem] {
        [
            .init(id: 1, title: "Revolut"),
            .init(id: 2, title: "up to 10K"),
            .init(id: 3, title: "▽")
        ]
    }

    var sellFilters: [BuySellFilterView.FilterItem] {
        [
            .init(id: 4, title: "Revolut2"),
            .init(id: 5, title: "up to 20K"),
            .init(id: 6, title: "▽")
        ]
    }

    var feedItems: [FeedItem] = [
        FeedItem(id: 1,
                 title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                 isRequested: false,
                 location: "Prague"),
        FeedItem(id: 2,
                 title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                 isRequested: true,
                 location: "Prague"),
        FeedItem(id: 3,
                 title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                 isRequested: true,
                 location: "Prague"),
        FeedItem(id: 4,
                 title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                 isRequested: false,
                 location: "Prague")
    ]

    private let cancelBag: CancelBag = .init()
}
