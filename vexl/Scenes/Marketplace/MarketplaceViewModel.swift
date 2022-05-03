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
        case createBuyOffer
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: OfferType = .buy

    @Published var offerItems: [Offer] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showOfferTapped
        case continueTapped
        case createBuyOfferTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    // TODO: - Update to real data when services are ready

    var currencySymbol: String {
        Constants.currencySymbol
    }
    var amount: String {
        "N/A"
    }

    var buyFilters: [MarketplaceFilterData] {
        []
    }

    var sellFilters: [MarketplaceFilterData] {
        []
    }

    private var buyFeedItems: [MarketplaceFeedViewData] = []
    private var sellFeedItems: [MarketplaceFeedViewData] = []

    var marketplaceFeedItems: [MarketplaceFeedViewData] {
        switch selectedOption {
        case .sell:
            return sellFeedItems
        case .buy:
            return buyFeedItems
        }
    }

    private let userOfferKeys: UserOfferKeys?
    private let cancelBag: CancelBag = .init()

    init() {
        self.userOfferKeys = UserDefaults.standard.codable(forKey: .storedOfferKeys)
        setupDataBindings()
        setupActionBindings()
    }

    private func setupDataBindings() {
        offerService
            .getOffer(pageLimit: Constants.pageMaxLimit)
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

        $offerItems
            .withUnretained(self)
            .sink { owner, items in
                let offerKeys = owner.userOfferKeys?.keys ?? []

                owner.buyFeedItems = items
                    .filter { offer in
                        offer.type == .buy && !offerKeys.contains(where: { $0.publicKey == offer.offerPublicKey })
                    }
                    .map { Self.map(offer: $0) }

                owner.sellFeedItems = items
                    .filter { offer in
                        offer.type == .sell && !offerKeys.contains(where: { $0.publicKey == offer.offerPublicKey })
                    }
                    .map { Self.map(offer: $0) }
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .share()
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showOfferTapped)
            }
            .store(in: cancelBag)

        action
            .share()
            .filter { $0 == .createBuyOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.createBuyOfferTapped)
            }
            .store(in: cancelBag)
    }

    private static func map(offer: Offer) -> MarketplaceFeedViewData {
        let currencySymbol = Constants.currencySymbol
        return MarketplaceFeedViewData(id: offer.offerId,
                                       title: offer.description,
                                       isRequested: false,
                                       location: L.offerSellNoLocation(),
                                       amount: "\(currencySymbol)\(offer.minAmount) - \(currencySymbol)\(offer.maxAmount)",
                                       paymentMethods: offer.paymentMethods.map(\.title),
                                       fee: offer.feeAmount > 0 ? "\(offer.feeAmount)%" : nil)
    }
}
