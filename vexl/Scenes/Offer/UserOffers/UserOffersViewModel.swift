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
    @Published var offerSortingOption: OfferSortOption = .newest

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

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

    var offerItems: [OfferDetailViewData] {
        userOffers.map { OfferFeed.mapToOfferFeed(usingOffer: $0, isRequested: false).viewData }
    }

    init(offerType: OfferType) {
        self.offerType = offerType
        self.userOfferKeys = UserDefaults.standard.codable(forKey: .storedOfferKeys)
        setupActivityBindings()
        setupBindings()
        setupDataBindings()
        setupActionBindings()
    }

    private func setupActivityBindings() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupBindings() {
        $offerSortingOption
            .withUnretained(self)
            .sink { owner, option in
                owner.sortOffers(withOption: option)
            }
            .store(in: cancelBag)
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
            .getStoredOfferIds(forType: offerType)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .filter { !$0.isEmpty }
            .flatMapLatest(with: self) { owner, ids in
                owner.offerService
                    .getUserOffers(offerIds: ids)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, encryptedOffers in
                owner.userOffers = encryptedOffers.compactMap {
                    try? Offer(encryptedOffer: $0, keys: owner.userSecurity.userKeys)
                }
                owner.sortOffers(withOption: owner.offerSortingOption)
            }
            .store(in: cancelBag)
    }

    private func sortOffers(withOption option: OfferSortOption) {
        userOffers = userOffers.sorted { first, second in
            switch option {
            case .newest:
                return first.createdDate.compare(second.createdDate) == .orderedDescending
            case .oldest:
                return first.createdDate.compare(second.createdDate) == .orderedAscending
            }
        }
    }

    func refreshOffers() {
        fetchOffers()
    }
}
