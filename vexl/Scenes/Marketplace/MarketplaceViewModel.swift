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

    @Inject private var offerService: OfferServiceType
    @Inject private var userSecurity: UserSecurityType
    @Inject private var localStorageService: LocalStorageServiceType
    @Inject private var inboxManager: InboxManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case showBuyFilters
        case showSellFilters
        case showSellOffer
        case showBuyOffer
        case offerDetailTapped(id: String)
        case requestOfferTapped(id: String)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedOption: OfferType = .buy
    @Published var offerItems: [Offer] = []
    @Published private var displayedBuyFeedItems: [OfferDetailViewData] = []
    @Published private var displayedSellFeedItems: [OfferDetailViewData] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showFiltersTapped(OfferFilter)
        case showSellOfferTapped
        case showBuyOfferTapped
        case showRequestOffer(Offer)
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
            return displayedSellFeedItems
        case .buy:
            return displayedBuyFeedItems
        }
    }

    let refresh = PassthroughSubject<Void, Never>()
    let bitcoinViewModel: BitcoinViewModel
    private var buyOfferFilter = OfferFilter(type: .buy)
    private var sellOfferFilter = OfferFilter(type: .sell)
    private var buyFeedItems: [OfferDetailViewData] = []
    private var sellFeedItems: [OfferDetailViewData] = []
    private var userOfferKeys: [StoredOffer.Keys] = []
    private let cancelBag: CancelBag = .init()

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
            filterBuyOffers()
        case .sell:
            sellOfferFilter = filter
            filterSellOffers()
        }
    }

    private func filterBuyOffers() {
        let filteredItems = buyFeedItems.filter { [weak self] item in
            if let owner = self, let offer = owner.offerItems.first(where: { $0.offerId == item.id }) {
                return buyOfferFilter.shouldShow(offer: offer)
            }
            return false
        }
        displayedBuyFeedItems = filteredItems
    }

    private func filterSellOffers() {
        let filteredItems = sellFeedItems.filter { [weak self] item in
            if let owner = self, let offer = owner.offerItems.first(where: { $0.offerId == item.id }) {
                return sellOfferFilter.shouldShow(offer: offer)
            }
            return false
        }
        displayedSellFeedItems = filteredItems
    }

    private func setupInbox() {
        inboxManager.syncInboxes()
    }

    // swiftlint: disable function_body_length
    private func setupDataBindings() {
        Publishers.Merge(refresh, Just(()))
            .flatMapLatest(with: self) { owner, _ in
                owner.offerService
                    .getCreatedStoredOfferKeys()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, keys in
                owner.userOfferKeys = keys
            })
            .flatMapLatest(with: self) { owner, _ in
                owner.offerService
                    .getOffer(pageLimit: Constants.pageMaxLimit)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .map(\.items)
            .withUnretained(self)
            .tryMap { owner, items in
                items.compactMap { try? Offer(encryptedOffer: $0, keys: owner.userSecurity.userKeys) }
            }
            .replaceError(with: [])
            .assign(to: &$offerItems)

        $offerItems
            .withUnretained(self)
            .map { owner, offers -> [Offer] in
                offers.filter { offer in
                    !owner.userOfferKeys.contains(where: { $0.id == offer.offerId })
                }
            }
            .withUnretained(self)
            .flatMap { owner, offers in
                owner.offerService
                    .storeFetchedOffers(offers: offers)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { offers }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink { owner, offers in
                let requestedInboxes = owner.getRequestedInboxes()
                owner.buyFeedItems.removeAll()
                owner.sellFeedItems.removeAll()

                for offer in offers {
                    let isRequested = requestedInboxes.contains(where: { $0.publicKey == offer.offerPublicKey })
                    let viewData = OfferDetailViewData(offer: offer, isRequested: isRequested)
                    switch offer.type {
                    case .buy:
                        owner.buyFeedItems.append(viewData)
                    case .sell:
                        owner.sellFeedItems.append(viewData)
                    }
                }

                owner.displayedBuyFeedItems = owner.buyFeedItems
                owner.displayedSellFeedItems = owner.sellFeedItems
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

        userAction
            .compactMap { action -> String? in
                if case let .requestOfferTapped(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .compactMap { owner, id in
                owner.offerItems.first(where: { $0.offerId == id })
            }
            .map { offer in Route.showRequestOffer(offer) }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func getRequestedInboxes() -> [ChatInbox] {
        do {
            return try localStorageService.getInboxes(ofType: .requested)
        } catch {
            return []
        }
    }
}
