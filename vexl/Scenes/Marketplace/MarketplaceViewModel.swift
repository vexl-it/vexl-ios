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
        case showSellOffer
        case showBuyOffer
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: OfferType = .buy

    @Published var offerItems: [Offer] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showSellOfferTapped
        case showBuyOfferTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    // TODO: - Update to real data when services are ready

    var currencySymbol: String {
        Constants.currencySymbol
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
                owner.offerItems = items.compactMap {
                    try? Offer(encryptedOffer: $0, keys: owner.userSecurity.userKeys)
                }
            }
            .store(in: cancelBag)

        $offerItems
            .withUnretained(self)
            .sink { owner, offers in
                let offerKeys = owner.userOfferKeys?.keys ?? []

                for offer in offers {
                    guard !offerKeys.contains(where: { $0.publicKey == offer.offerPublicKey }) else {
                        continue
                    }

                    let marketplaceItem = Self.mapToMarketplaceFeed(usingOffer: offer)
                    switch offer.type {
                    case .buy:
                        owner.buyFeedItems.append(marketplaceItem)
                    case .sell:
                        owner.sellFeedItems.append(marketplaceItem)
                    }
                }
//
//                owner.buyFeedItems = items
//                    .filter { offer in
//                        offer.type == .buy && !offerKeys.contains(where: { $0.publicKey == offer.offerPublicKey })
//                    }
//                    .map { Self.mapToMarketplaceFeed(usingOffer: $0) }
//
//                owner.sellFeedItems = items
//                    .filter { offer in
//                        offer.type == .sell && !offerKeys.contains(where: { $0.publicKey == offer.offerPublicKey })
//                    }
//                    .map { Self.mapToMarketplaceFeed(usingOffer: $0) }
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .share()
            .filter { $0 == .showSellOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showSellOfferTapped)
            }
            .store(in: cancelBag)

        action
            .share()
            .filter { $0 == .showBuyOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showBuyOfferTapped)
            }
            .store(in: cancelBag)
    }

    private static func mapToMarketplaceFeed(usingOffer offer: Offer) -> MarketplaceFeedViewData {
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
