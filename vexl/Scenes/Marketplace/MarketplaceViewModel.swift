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
        case showBuyFilters
        case showSellFilters
        case showSellOffer
        case showBuyOffer
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: OfferType = .buy
    @Published private var filteredBuyFeedItems: [MarketplaceOffer] = []
    @Published private var filteredSellFeedItems: [MarketplaceOffer] = []

    @Published var offerItems: [Offer] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showFiltersTapped(OfferFilter)
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
        let openFilter = MarketplaceFilterData(
            title: L.filterOffers(),
            type: .filter,
            action: { [action] in action.send(.showBuyFilters) }
        )
        return [
            openFilter
        ]
    }

    var sellFilters: [MarketplaceFilterData] {
        let openFilter = MarketplaceFilterData(
            title: L.filterOffers(),
            type: .filter,
            action: { [action] in action.send(.showSellFilters) }
        )
        return [
            openFilter
        ]
    }

    var marketplaceFeedItems: [MarketplaceFeedViewData] {
        switch selectedOption {
        case .sell:
            return filteredSellFeedItems.map(\.viewData)
        case .buy:
            return filteredBuyFeedItems.map(\.viewData)
        }
    }

    private var buyOfferFilter = OfferFilter(type: .buy)
    private var sellOfferFilter = OfferFilter(type: .sell)
    private var buyFeedItems: [MarketplaceOffer] = []
    private var sellFeedItems: [MarketplaceOffer] = []
    private let userOfferKeys: UserOfferKeys?
    private let cancelBag: CancelBag = .init()

    init() {
        self.userOfferKeys = UserDefaults.standard.codable(forKey: .storedOfferKeys)
        setupDataBindings()
        setupActionBindings()
    }

    func applyFilter(_ filter: OfferFilter) {
        switch filter.type {
        case .buy:
            buyOfferFilter = filter
            filterBuyOffers()
        case .sell:
            sellOfferFilter = filter
            filterSellOffers()
        }
    }

    private func filterBuyOffers() {
        let filteredItems = buyFeedItems.filter { item in
            buyOfferFilter.shouldShow(offer: item.offer)
        }
        filteredBuyFeedItems = filteredItems
    }

    private func filterSellOffers() {
        let filteredItems = sellFeedItems.filter { item in
            sellOfferFilter.shouldShow(offer: item.offer)
        }
        filteredSellFeedItems = filteredItems
    }

    private func setupDataBindings() {
        offerService
            .getOffer(pageLimit: Constants.pageMaxLimit)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .map(\.items)
            .withUnretained(self)
            .tryMap { owner, items in
                items.compactMap { try? Offer(encryptedOffer: $0, keys: owner.userSecurity.userKeys) }
            }
            .replaceError(with: [])
            .assign(to: &$offerItems)

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

                owner.filteredBuyFeedItems = owner.buyFeedItems
                owner.filteredSellFeedItems = owner.sellFeedItems
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        let userAction = action
            .share()

        userAction
            .filter { $0 == .showSellOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showSellOfferTapped)
            }
            .store(in: cancelBag)

        userAction
            .filter { $0 == .showBuyOffer }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showBuyOfferTapped)
            }
            .store(in: cancelBag)

        userAction
            .filter { $0 == .showBuyFilters }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showFiltersTapped(owner.buyOfferFilter))
            }
            .store(in: cancelBag)

        userAction
            .filter { $0 == .showSellFilters }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.showFiltersTapped(owner.sellOfferFilter))
            }
            .store(in: cancelBag)
    }

    private static func mapToMarketplaceFeed(usingOffer offer: Offer) -> MarketplaceOffer {
        let currencySymbol = Constants.currencySymbol
        let viewData = MarketplaceFeedViewData(
            id: offer.offerId,
            title: offer.description,
            isRequested: false,
            location: L.offerSellNoLocation(),
            amount: "\(currencySymbol)\(offer.minAmount) - \(currencySymbol)\(offer.maxAmount)",
            paymentMethods: offer.paymentMethods.map(\.title),
            fee: offer.feeAmount > 0 ? "\(offer.feeAmount)%" : nil
        )
        return MarketplaceOffer(offer: offer, viewData: viewData)
    }
}

extension MarketplaceViewModel {
    struct MarketplaceOffer {
        let offer: Offer
        let viewData: MarketplaceFeedViewData
    }
}
