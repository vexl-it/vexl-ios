//
//  BuySellViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Foundation
import Cleevio
import Combine

final class MarketplaceViewModel: ViewModelType, ObservableObject {

    @Inject var offerService: OfferServiceType
    @Inject var userSecurity: UserSecurityType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case showOffer
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: OfferType = .buy

    @Published var offerItems: [Offer] = []

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

    var buyFilters: [MarketplaceFilterData] {
        [
            .init(id: 1, title: "Revolut"),
            .init(id: 2, title: "up to 10K"),
            .init(id: 3, title: "▽")
        ]
    }

    var sellFilters: [MarketplaceFilterData] {
        [
            .init(id: 4, title: "Filter offers ▽")
        ]
    }

    var filteredOffers: [Offer] {
        offerItems.filter { $0.type == selectedOption }
    }

    private let cancelBag: CancelBag = .init()

    init() {
        setupDataBindings()
        setupActionBindings()
    }

    private func setupDataBindings() {
        offerService
            .getOffer()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .map(\.items)
            .withUnretained(self)
            .sink { owner, items in
                var offers: [Offer] = []
                for item in items {
                    if let offer = try? Offer(encryptedOffer: item,
                                              offerKey: owner.userSecurity.userKeys) {
                        offers.append(offer)
                    }
                }
                owner.offerItems = offers
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showOffer)
            }
            .store(in: cancelBag)
    }
}
