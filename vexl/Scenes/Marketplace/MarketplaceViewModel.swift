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

    // MARK: - Dependency Bindings

    @Inject private var offerManager: OfferManagerType
    @Inject private var inboxManager: InboxManagerType
    @Inject private var remoteConfigManager: RemoteConfigManagerType
    @Inject private var cryptoManager: CryptocurrencyValueManagerType

    // MARK: - Fetched Bindings

    @Fetched(
        fetchImmediately: false,
        sortDescriptors: [
            NSSortDescriptor(key: "isRequested", ascending: true),
            NSSortDescriptor(key: "modifiedAtDate", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "id", ascending: false)
        ]
    )
    var fetchedBuyOffers: [ManagedOffer]

    @Fetched(
        fetchImmediately: false,
        sortDescriptors: [
            NSSortDescriptor(key: "isRequested", ascending: true),
            NSSortDescriptor(key: "modifiedAtDate", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "id", ascending: false)
        ]
    )
    var fetchedSellOffers: [ManagedOffer]

    @Fetched(predicate: .init(
        format: "user != nil AND isRemoved == FALSE AND offerTypeRawType == %@", OfferType.buy.rawValue
    ))
    var userBuyOffers: [ManagedOffer]

    @Fetched(predicate: .init(
        format: "user != nil AND isRemoved == FALSE AND offerTypeRawType == %@", OfferType.sell.rawValue
    ))
    var userSellOffers: [ManagedOffer]

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: OfferType = .sell
    @Published var isRefreshing = false
    @Published var isGraphExpanded = false
    @Published var createdBuyOffers = false
    @Published var createdSellOffers = false
    @Published private var buyFeed: [OfferDetailViewData] = []
    @Published private var sellFeed: [OfferDetailViewData] = []

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case showBuyFilters
        case showSellFilters
        case showSellOffer
        case showBuyOffer
        case offerTapped(offer: ManagedOffer)
        case fetchNewOffers
        case graphExpanded(isExpanded: Bool)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showFiltersTapped(OfferFilter)
        case showSellOfferTapped
        case showBuyOfferTapped
        case showRequestOffer(ManagedOffer)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var currencySymbol: String {
        Constants.currencySymbol
    }

    var buyFilters: [MarketplaceFilterData] {
        let openFilter = MarketplaceFilterData(
            title: L.filterOffers(),
            type: .filter,
            action: { [action] in action.send(.showBuyFilters) }
        )
        return [openFilter]
    }

    var sellFilters: [MarketplaceFilterData] {
        let openFilter = MarketplaceFilterData(
            title: L.filterOffers(),
            type: .filter,
            action: { [action] in action.send(.showSellFilters) }
        )
        return [openFilter]
    }

    var marketplaceFeedItems: [OfferDetailViewData] {
        switch selectedOption {
        case .sell:
            return sellFeed
        case .buy:
            return buyFeed
        }
    }

    var userSelectedFilters: Bool {
        switch selectedOption {
        case .sell:
            return !sellOfferFilter.isFilterEmpty
        case .buy:
            return !buyOfferFilter.isFilterEmpty
        }
    }

    var isMarketplaceLocked: Bool {
        remoteConfigManager.getBoolValue(for: .isMarketplaceLocked)
    }

    let refresh = PassthroughSubject<Void, Never>()
    let bitcoinViewModel: BitcoinViewModel
    private var buyOfferFilter = OfferFilter(type: .buy)
    private var sellOfferFilter = OfferFilter(type: .sell)
    private let cancelBag: CancelBag = .init()

    // MARK: - Methods

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupDataBindings()
        setupActionBindings()
        setupInbox()
    }

    func applyFilter(_ filter: OfferFilter) {
        switch filter.type {
        case .buy:
            buyOfferFilter = filter
            $fetchedBuyOffers.load(predicate: filter.predicate)
        case .sell:
            sellOfferFilter = filter
            $fetchedSellOffers.load(predicate: filter.predicate)
        }
    }

    func reloadFilters() {
        [buyOfferFilter, sellOfferFilter]
            .forEach(applyFilter)
    }

    private func setupInbox() {
        inboxManager.syncInboxes()
    }

    private func setupDataBindings() {
        $fetchedBuyOffers.publisher
            .map(\.objects)
            .map { $0.map(OfferDetailViewData.init) }
            .assign(to: &$buyFeed)

        $fetchedSellOffers.publisher
            .map(\.objects)
            .map { $0.map(OfferDetailViewData.init) }
            .assign(to: &$sellFeed)

        $userBuyOffers.publisher
            .map(\.objects)
            .map { !$0.isEmpty }
            .assign(to: &$createdBuyOffers)

        $userSellOffers.publisher
            .map(\.objects)
            .map { !$0.isEmpty }
            .assign(to: &$createdSellOffers)

        cryptoManager
            .currentCoinData
            .withUnretained(self)
            .sink { owner, _ in
                owner.reloadFilters()
            }
            .store(in: cancelBag)

        offerManager
            .syncInProgressPublisher
            .assign(to: &$isRefreshing)
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

        userAction
            .filter { $0 == .fetchNewOffers }
            .withUnretained(self)
            .sink { [offerManager] _ in
                offerManager.sync()
            }
            .store(in: cancelBag)

        userAction
            .compactMap { action -> ManagedOffer? in
                guard case let .offerTapped(offer) = action else {
                    return nil
                }
                return offer
            }
            .map { offer in Route.showRequestOffer(offer) }
            .subscribe(route)
            .store(in: cancelBag)

        userAction
            .compactMap { action -> Bool? in // swiftlint:disable:this discouraged_optional_boolean
                guard case let .graphExpanded(isExpanded) = action else {
                    return nil
                }
                return isExpanded
            }
            .withUnretained(self)
            .sink { owner, isExpanded in
                owner.isGraphExpanded = isExpanded
            }
            .store(in: cancelBag)
    }
}
