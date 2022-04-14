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

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
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
