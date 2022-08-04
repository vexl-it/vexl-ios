//
//  FilterViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 23.05.2022.
//

import Foundation
import Cleevio
import Combine

final class FilterViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case addLocation
        case deleteLocation(id: Int)
        case resetFilter
        case applyFilter
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Dependencies

    @Inject var offerService: OfferServiceType

    // MARK: - View Bindings

    @Published var currentAmountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
    @Published var amountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer

    @Published var selectedFeeOptions: [OfferFeeOption] = []
    @Published var feeAmount: Double

    @Published var locations: [OfferLocationItemData]

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption]

    @Published var selectedBTCOptions: [OfferAdvancedBTCOption]
    @Published var selectedFriendDegreeOptions: [OfferFriendDegree]

    @Published var currency: Currency = Constants.OfferInitialData.currency

    var filterType: String { offerFilter.type.title }
    var formatedFeeAmount: String {
        "< \(Int(((maxFee - minFee) * feeAmount) + minFee))%"
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case applyFilterTapped(OfferFilter)
    }

    var route: CoordinatingSubject<Route> = .init()
    let primaryActivity: Activity = .init()

    // MARK: - Variables

    private var minFee: Double = Constants.OfferInitialData.minFee
    private var maxFee: Double = Constants.OfferInitialData.maxFee
    private var offerFilter: OfferFilter
    private let cancelBag: CancelBag = .init()

    init(offerFilter: OfferFilter) {
        self.offerFilter = offerFilter
        currentAmountRange = offerFilter.currentAmountRange ?? 0...0
        selectedFeeOptions = offerFilter.selectedFeeOptions
        feeAmount = offerFilter.feeAmount
        locations = offerFilter.locations
        selectedPaymentMethodOptions = offerFilter.selectedPaymentMethodOptions
        selectedBTCOptions = offerFilter.selectedBTCOptions
        selectedFriendDegreeOptions = offerFilter.selectedFriendDegreeOptions
        setupCurrencyBindings(currency: offerFilter.currency)
        setupDataBindings()
        setupBindings()
    }

    private func setupCurrencyBindings(currency: Currency?) {
        if let currency = currency {
            self.currency = currency
        }

        $currency
            .withUnretained(self)
            .sink { owner, option in
                let minOffer = Constants.OfferInitialData.minOffer
                let maxOffer = Constants.OfferInitialData.maxOffer
                let maxOfferCZK = Constants.OfferInitialData.maxOfferCZK

                switch option {
                case .eur, .usd:
                    owner.amountRange = minOffer...maxOffer
                    owner.currentAmountRange = minOffer...maxOffer
                case .czk:
                    owner.amountRange = minOffer...maxOfferCZK
                    owner.currentAmountRange = minOffer...maxOfferCZK
                }
            }
            .store(in: cancelBag)
    }

    private func setupDataBindings() {
    }

    private func setupBindings() {
        let userAction = action
            .share()
            .eraseToAnyPublisher()

        userAction
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)

        userAction
            .filter { $0 == .applyFilter }
            .withUnretained(self)
            .sink { owner, _ in
                owner.offerFilter.currentAmountRange = owner.currentAmountRange
                owner.offerFilter.selectedFeeOptions = owner.selectedFeeOptions
                owner.offerFilter.feeAmount = owner.feeAmount
                owner.offerFilter.locations = owner.locations
                owner.offerFilter.selectedPaymentMethodOptions = owner.selectedPaymentMethodOptions
                owner.offerFilter.selectedBTCOptions = owner.selectedBTCOptions
                owner.offerFilter.selectedFriendDegreeOptions = owner.selectedFriendDegreeOptions
                owner.offerFilter.currency = owner.currency

                owner.route.send(.applyFilterTapped(owner.offerFilter))
            }
            .store(in: cancelBag)

        userAction
            .filter { $0 == .resetFilter }
            .withUnretained(self)
            .sink { owner, _ in
                owner.resetFilter()
            }
            .store(in: cancelBag)

        locationActionBindings(userAction: userAction)
    }

    private func locationActionBindings(userAction: AnyPublisher<UserAction, Never>) {
        userAction
            .filter { $0 == .addLocation }
            .withUnretained(self)
            .sink { owner, _ in
                var newLocations = owner.locations
                let count = newLocations.count + 1

                // TODO: - Manage Locations when implementing maps + coordinates

                let stubLocation = OfferLocationItemData(id: count,
                                                         name: "Prague \(count)",
                                                         distance: "\(count)km")
                newLocations.append(stubLocation)
                owner.locations = newLocations
            }
            .store(in: cancelBag)

        userAction
            .compactMap { action -> Int? in
                if case let .deleteLocation(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .sink { owner, id in
                guard let index = owner.locations.firstIndex(where: { $0.id == id }) else {
                    return
                }

                var newLocations = owner.locations
                newLocations.remove(at: index)
                owner.locations = newLocations
            }
            .store(in: cancelBag)
    }

    private func resetFilter() {
        currentAmountRange = amountRange
        selectedFeeOptions = []
        feeAmount = 1
        locations = []
        selectedPaymentMethodOptions = []
        selectedBTCOptions = []
        selectedFriendDegreeOptions = []
        offerFilter.reset(with: currentAmountRange)
        currency = Constants.OfferInitialData.currency
    }
}
