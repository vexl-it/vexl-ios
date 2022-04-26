//
//  CreateOfferViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import Foundation
import Cleevio
import SwiftUI

class CreateOfferViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case pause
        case delete
        case addLocation
        case deleteLocation(id: Int)
        case dismissTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

    @Published var amountRange: ClosedRange<Int>
    @Published var currentAmountRange: ClosedRange<Int>

    @Published var selectedFeeOption: OfferFeeOption = .withoutFee
    @Published var feeAmount: Double = 0

    @Published var locations: [OfferLocationItemViewData] = OfferLocationItemViewData.stub()

    @Published var selectedTradeStyleOption: OfferTradeStyleOption = .online

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []

    @Published var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption = .firstDegree
    @Published var selectedTypeOption: [OfferAdvancedTypeOption] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    var minFee: Double = 0
    var maxFee: Double = 10
    var feeValue: Double? {
        guard selectedFeeOption == .withFee else {
            return nil
        }
        return (maxFee - minFee) * feeAmount
    }

    let currencySymbol = "$"

    init() {
        amountRange = 0...30_000
        currentAmountRange = 0...30_000
        setupBindings()
    }

    private func setupBindings() {
        action
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .addLocation }
            .withUnretained(self)
            .sink { owner, _ in
                var newLocations = owner.locations
                let count = newLocations.count + 1
                let stubLocation = OfferLocationItemViewData(id: count,
                                                             name: "Prague \(count)",
                                                             distance: "\(count)km")
                newLocations.append(stubLocation)
                owner.locations = newLocations
            }
            .store(in: cancelBag)

        action
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
