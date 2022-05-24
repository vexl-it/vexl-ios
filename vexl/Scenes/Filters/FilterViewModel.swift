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
        case applyFilter
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentAmountRange: ClosedRange<Int> = 1...10_000
    var amountRange: ClosedRange<Int> = 1...10_000

    @Published var selectedFeeOption: OfferFeeOption = .withoutFee
    @Published var feeAmount: Double = 0

    @Published var locations: [OfferLocationItemData] = []

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []

    @Published var selectedBTCOption: [OfferAdvancedBTCOption] = []
    @Published var selectedFriendSources: [OfferAdvancedFriendSourceOption] = []
    @Published var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption = .firstDegree

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case applyFilterTapped(OfferFilter)
    }

    var route: CoordinatingSubject<Route> = .init()
    let primaryActivity: Activity = .init()

    // MARK: - Variables

    private var offerFilter: OfferFilter
    private let cancelBag: CancelBag = .init()

    init(offerFilter: OfferFilter) {
        self.offerFilter = offerFilter
        setupBindings()
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
                owner.offerFilter.selectedFeeOption = owner.selectedFeeOption
                owner.offerFilter.feeAmount = owner.feeAmount
                owner.offerFilter.locations = owner.locations
                owner.offerFilter.selectedPaymentMethodOptions = owner.selectedPaymentMethodOptions
                owner.offerFilter.selectedBTCOption = owner.selectedBTCOption
                owner.offerFilter.selectedFriendSources = owner.selectedFriendSources
                owner.offerFilter.selectedFriendDegreeOption = owner.selectedFriendDegreeOption

                owner.route.send(.applyFilterTapped(owner.offerFilter))
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
                switch action {
                case let .deleteLocation(id):
                    return id
                default:
                    return nil
                }
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
}
