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
                guard let userOfferKeys = owner.userOfferKeys else {
                    return
                }

                for item in items {
                    let id = item.offerId

                    if let keys = userOfferKeys.keys.first(where: { $0.id == id }) {
                        let offer = try? Offer(encryptedOffer: item,
                                               offerKey: owner.userSecurity.userKeys)
                        print(offer)
                    }
                }
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
