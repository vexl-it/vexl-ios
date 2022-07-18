//
//  CreateOfferViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class CreateOfferViewModel: ViewModelType, ObservableObject {

    enum UserAction: Equatable {
        case pause
        case delete
        case addLocation
        case deleteLocation(id: Int)
        case dismissTap
        case createOffer
    }

    enum State {
        case initial
        case loaded
        case loading
    }

    @Inject private var authenticationManager: AuthenticationManagerType
    @Inject private var offerRepository: OfferRepositoryType
    @Inject private var chatService: ChatServiceType
    @Inject private var contactsMananger: ContactsManagerType
    @Inject private var contactsService: ContactsServiceType

    // MARK: - Action Binding

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    @Published var description: String = ""

    @Published var amountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
    @Published var currentAmountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer

    @Published var selectedFeeOption: OfferFeeOption = .withoutFee
    @Published var feeAmount: Double = 0

    @Published var locations: [OfferLocationItemData] = []

    @Published var selectedTradeStyleOption: OfferTradeLocationOption = .online

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []

    @Published var selectedBTCOption: [OfferAdvancedBTCOption] = []
    @Published var selectedFriendDegreeOption: OfferFriendDegree = .firstDegree

    @Published var deleteTimeUnit: OfferTriggerDeleteTimeUnit = .days
    @Published var deleteTime: String = Constants.defaultDeleteTime

    @Published var state: State = .loaded
    @Published var error: Error?

    @Published var currency: Currency = Constants.OfferInitialData.currency

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case offerCreated
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var expiration: TimeInterval {
        let time = Double(deleteTime) ?? 0
        let currentTimestamp = Date().timeIntervalSince1970
        var additionalSeconds: TimeInterval

        switch deleteTimeUnit {
        case .days:
            additionalSeconds = time * Constants.daysToSecondsMultiplier
        case .weeks:
            additionalSeconds = time * Constants.weeksToSecondsMultiplier
        case .months:
            additionalSeconds = time * Constants.monthsToSecondsMultiplier
        }

        return currentTimestamp + additionalSeconds
    }

    var feeValue: Int {
        guard selectedFeeOption == .withFee else {
            return 0
        }
        return Int(((maxFee - minFee) * feeAmount) + minFee)
    }

    private var friendLevel: ContactFriendLevel {
        switch selectedFriendDegreeOption {
        case .firstDegree:
            return .first
        case .secondDegree:
            return .second
        }
    }

    var isCreateEnabled: Bool {
        guard (selectedFeeOption == .withFee && feeAmount > 0) || (selectedFeeOption == .withoutFee) else {
            return false
        }

        guard !selectedPaymentMethodOptions.isEmpty && !selectedBTCOption.isEmpty else {
            return false
        }

        return !description.isEmpty
    }

    var headerTitle: String {
        switch offerType {
        case .sell:
            return L.offerSellCreateTitle()
        case .buy:
            return L.offerBuyCreateTitle()
        }
    }

    var actionTitle: String {
        switch offerType {
        case .sell:
            return L.offerCreateActionTitle()
        case .buy:
            return L.offerCreateBuyActionTitle()
        }
    }

    var minFee: Double = Constants.OfferInitialData.minFee
    var maxFee: Double = Constants.OfferInitialData.maxFee
    let offerKey = ECCKeys()
    let offerType: OfferType

    private let cancelBag: CancelBag = .init()

    init(offerType: OfferType) {
        self.offerType = offerType
        setupActivity()
        setupDataBindings()
        setupBindings()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .withUnretained(self)
            .sink { owner, isLoading in
                guard owner.state != .initial else {
                    return
                }
                owner.state = isLoading ? .loading : .loaded
            }
            .store(in: cancelBag)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    // MARK: - Bindings

    private func setupDataBindings() {
    }

    private func setupBindings() {
        let action = self.action.share().eraseToAnyPublisher()

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

                // TODO: - Manage Locations when implementing maps + coordinates

                let stubLocation = OfferLocationItemData(id: count,
                                                         name: "Prague \(count)",
                                                         distance: "\(count)km")
                newLocations.append(stubLocation)
                owner.locations = newLocations
            }
            .store(in: cancelBag)

        action
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

        action
            .filter { $0 == .createOffer }
            .map { _ in ECCKeys() }
            .print("[\(Thread.current)] [OfferCreate] will create offer")
            .withUnretained(self)
            .flatMap { owner, keys in
                owner.offerRepository
                    .createOffer(
                        offerId: nil,
                        groupUuid: GroupUUID.none,
                        offerPublicKey: keys.publicKey,
                        offerPrivateKey: keys.privateKey,
                        currency: owner.currency,
                        minAmount: Double(owner.currentAmountRange.lowerBound),
                        maxAmount: Double(owner.currentAmountRange.upperBound),
                        description: owner.description,
                        feeState: owner.selectedFeeOption,
                        feeAmount: Double(owner.feeValue),
                        locationState: owner.selectedTradeStyleOption,
                        paymentMethods: owner.selectedPaymentMethodOptions,
                        btcNetworks: owner.selectedBTCOption,
                        friendLevel: owner.selectedFriendDegreeOption,
                        type: owner.offerType,
                        activePriceState: OfferTrigger.none,
                        activePriceValue: 0.0,
                        active: true,
                        expiration: Date(timeIntervalSince1970: owner.expiration)
                    )
                    .materialize()
                    .compactMap(\.value)
                    .print("[\(Thread.current)] [OfferCreate] finished")
            }
//            .receive(on: RunLoop.main)
            .print("[\(Thread.current)] [OfferCreate] finished2")
            .map { _ in .offerCreated }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
