//
//  OffersViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio

final class OffersViewModel: ViewModelType, ObservableObject {

    @Inject var offerService: OfferServiceType
    @Inject var userSecurity: UserSecurityType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case createOfferTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var userOffers: [Offer] = []

    @Published var primaryActivity: Activity = .init()
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case createOfferTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()
    private let userOfferKeys: UserOfferKeys?
    var offerItems: [SellOfferViewData] {
        userOffers.map { offer in
            SellOfferViewData(id: offer.offerId,
                              description: offer.description,
                              minAmount: offer.minAmount,
                              maxAmount: offer.maxAmount,
                              paymentMethods: offer.paymentMethods.map(\.title))
        }
    }

    init() {
        self.userOfferKeys = UserDefaults.standard.codable(forKey: .storedOfferKeys)
        setupActivity()
        setupDataBindings()
        setupActionBindings()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
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
                owner.userOffers = offers
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .createOfferTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.createOfferTapped)
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)
    }
}
