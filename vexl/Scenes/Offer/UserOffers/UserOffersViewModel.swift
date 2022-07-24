//
//  OffersViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio
import Combine

final class UserOffersViewModel: ViewModelType, ObservableObject {

    @Inject var authenticationManager: AuthenticationManagerType

    // MARK: - Fetched Bindings

    @Fetched(
        fetchImmediately: false,
        sortDescriptors: [ NSSortDescriptor(key: "createdAt", ascending: false) ]
    )
    var fetchedOffers: [ManagedOffer]

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case createOfferTap
        case editOfferTap(id: String)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var userOffers: [ManagedOffer] = []
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
        case editOfferTapped(offer: ManagedOffer)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let offerType: OfferType
    private let cancelBag: CancelBag = .init()

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
        userOffers.map { OfferDetailViewData(offer: $0) }
    }

    init(offerType: OfferType) {
        self.offerType = offerType
        setupActivityBindings()
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

    private func setupDataBindings() {
        $fetchedOffers
            .load(
                predicate: .init(format: "offerTypeRawType == '\(offerType.rawValue)' AND user != nil")
            )

        $fetchedOffers.publisher
            .map(\.objects)
            .assign(to: &$userOffers)
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
            .compactMap { action -> String? in
                if case let .editOfferTap(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .sink { owner, id in
                guard let offer = owner.userOffers.first(where: { $0.id == id }) else {
                    return
                }
                owner.route.send(.editOfferTapped(offer: offer))
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)

        $offerSortingOption
            .withUnretained(self)
            .sink { owner, option in
                owner.$fetchedOffers
                    .load(sortDescriptors: [ NSSortDescriptor(key: "createdAt", ascending: option == .oldest) ])
            }
            .store(in: cancelBag)
    }
}
