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

    @Inject var offerService: OfferServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case pause
        case delete
        case addLocation
        case deleteLocation(id: Int)
        case dismissTap
        case createOffer
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

    @Published var amountRange: ClosedRange<Int> = 0...0
    @Published var currentAmountRange: ClosedRange<Int> = 0...0

    @Published var selectedFeeOption: OfferFeeOption = .withoutFee
    @Published var feeAmount: Double = 0

    @Published var locations: [OfferLocationItemData] = []

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
    var maxFee: Double = 0
    var feeValue: Int? {
        guard selectedFeeOption == .withFee else {
            return nil
        }
        return Int((maxFee - minFee) * feeAmount)
    }

    var currencySymbol = ""

    init() {
        setupDataBindings()
        setupBindings()
    }

    private func setupDataBindings() {
        offerService
            .getInitialOfferData()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, data in
                owner.amountRange = data.minOffer...data.maxOffer
                owner.currentAmountRange = data.minOffer...data.maxOffer
                owner.minFee = data.minFee
                owner.maxFee = data.maxFee
                owner.currencySymbol = data.currencySymbol
                owner.locations = data.locations
            }
            .store(in: cancelBag)
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
                let stubLocation = OfferLocationItemData(id: count,
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

        action
            .filter { $0 == .createOffer }
            .withUnretained(self)
            .sink { _, _ in
                print("created!")
            }
            .store(in: cancelBag)
    }
}
