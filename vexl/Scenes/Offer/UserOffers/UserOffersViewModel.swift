//
//  OffersViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio

final class UserOffersViewModel: ViewModelType, ObservableObject {

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

    private let offerType: OfferType
    private let cancelBag: CancelBag = .init()
    private var userOfferKeys: UserOfferKeys?

    var offerTitle: String {
        switch offerType {
        case .sell:
            return L.offerSellTitle()
        case .buy:
            return L.offerBuyTitle()
        }
    }

    var createOfferTitle: String {
        switch offerType {
        case .sell:
            return L.offerSellTitle()
        case .buy:
            return L.offerBuyTitle()
        }
    }

    var offerItems: [OfferItemViewData] {
        userOffers.map { offer in
            OfferItemViewData(id: offer.offerId,
                              description: offer.description,
                              minAmount: offer.minAmount,
                              maxAmount: offer.maxAmount,
                              paymentMethods: offer.paymentMethods.map(\.title),
                              offerType: offer.type)
        }
    }

    init(offerType: OfferType) {
        self.offerType = offerType
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
        fetchOffers()
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

    private func fetchOffers() {
        offerService
            .getOffer(pageLimit: Constants.pageMaxLimit)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .map(\.items)
            .withUnretained(self)
            .sink { owner, items in
                owner.userOfferKeys = UserDefaults.standard.codable(forKey: .storedOfferKeys)
                let offerKeys = owner.userOfferKeys?.keys ?? []
                var offers: [Offer] = []

                // TODO: - Optimize the decryption using multi-threading

                for item in items {
                    if let offer = try? Offer(encryptedOffer: item,
                                              keys: owner.userSecurity.userKeys) {
                        offers.append(offer)
                    }
                }

                let mySellOffers = offers.filter { offer in
                    offer.type == owner.offerType && offerKeys.contains(where: { $0.publicKey == offer.offerPublicKey })
                }
                owner.userOffers = mySellOffers
            }
            .store(in: cancelBag)
    }

    func refreshOffers() {
        fetchOffers()
    }
}
