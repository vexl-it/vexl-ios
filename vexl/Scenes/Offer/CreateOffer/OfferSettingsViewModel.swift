//
//  OfferActionViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 11/07/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class OfferSettingsViewModel: ViewModelType, ObservableObject {

    @Inject var authenticationManager: AuthenticationManagerType
    @Inject var offerRepository: OfferRepositoryType
    @Inject var chatService: ChatServiceType
    @Inject var contactsMananger: ContactsManagerType
    @Inject var contactsService: ContactsServiceType
    @Inject var offerService: OfferServiceType

    enum UserAction: Equatable {
        case activate
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

    @Published var selectedPriceTrigger: OfferTrigger = .none
    @Published var selectedPriceTriggerAmount: String = "0"

    @Published var deleteTimeUnit: OfferTriggerDeleteTimeUnit = .days
    @Published var deleteTime: String = Constants.defaultDeleteTime

    @Published var isActive = true

    @Published var state: State = .loaded
    @Published var error: Error?

    @Published var currency: Currency = Constants.OfferInitialData.currency

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case offerCreated
        case offerDeleted
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

    var priceTriggerAmount: Double {
        guard let amount = Double(selectedPriceTriggerAmount) else {
            return 0
        }
        return amount
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
        if offer != nil {
            switch offerType {
            case .sell:
                return L.offerUpdateActionTitle()
            case .buy:
                return L.offerUpdateBuyActionTitle()
            }
        }
        switch offerType {
        case .sell:
            return L.offerCreateActionTitle()
        case .buy:
            return L.offerCreateBuyActionTitle()
        }
    }

    var showDeleteButton: Bool {
        offer != nil
    }

    var showDeleteTrigger: Bool {
        offer == nil
    }

    var minFee: Double = 0
    var maxFee: Double = 0
    var currencySymbol = ""
    var offerKey: ECCKeys
    let offerType: OfferType

    private var offer: ManagedOffer?
    private let cancelBag: CancelBag = .init()

    init(offer: ManagedOffer) {
        self.offerKey = offer.inbox?.keyPair?.keys ?? ECCKeys()
        self.offerType = offer.type ?? .buy
        self.offer = offer
        setup()
    }

    init(offerType: OfferType, offerKey: ECCKeys) {
        self.offerType = offerType
        self.offerKey = offerKey
        setup()
    }

    func setup() {
        setupDataBindings()
        setupActivity()
        setupBindings()
        setupDeleteBinding()
    }

    // MARK: - Bindings

    private func setupDataBindings() {
        if let offer = offer {
            description = offer.offerDescription ?? ""
            currentAmountRange = Int(offer.minAmount)...Int(offer.maxAmount)
            selectedFeeOption = offer.feeState ?? .withoutFee
            feeAmount = offer.feeAmount
            selectedTradeStyleOption = offer.locationState ?? .personal
            selectedPaymentMethodOptions = offer.paymentMethods
            selectedBTCOption = offer.btcNetworks
            selectedFriendDegreeOption = offer.friendLevel ?? .firstDegree
            selectedPriceTrigger = offer.activePriceState ?? .none
            selectedPriceTriggerAmount = "\(Int(offer.activePriceValue))"
        }
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

    private func setupBindings() {
        let sharedAction = action.share()

        sharedAction
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)

        sharedAction
            .filter { $0 == .activate }
            .withUnretained(self)
            .sink { owner, _ in
                owner.isActive.toggle()
            }
            .store(in: cancelBag)

        sharedAction
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

        sharedAction
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

        setupCreateOfferAction()
    }

    func setupCreateOfferAction() {
        action
            .filter { $0 == .createOffer }
            .asVoid()
            .withUnretained(self)
            .flatMap { owner -> AnyPublisher<ManagedOffer, Never> in
                let provider: (ManagedOffer) -> Void = { [weak self] offer in
                    guard let owner = self else { return }
                    offer.id = nil
                    offer.groupUuid = GroupUUID.none
                    offer.currency = owner.currency
                    offer.minAmount = Double(owner.currentAmountRange.lowerBound)
                    offer.maxAmount = Double(owner.currentAmountRange.upperBound)
                    offer.offerDescription = owner.description
                    offer.feeState = owner.selectedFeeOption
                    offer.feeAmount = Double(owner.feeValue)
                    offer.locationState = owner.selectedTradeStyleOption
                    offer.paymentMethods = owner.selectedPaymentMethodOptions
                    offer.btcNetworks = owner.selectedBTCOption
                    offer.friendLevel = owner.selectedFriendDegreeOption
                    offer.type = owner.offerType
                    offer.activePriceState = OfferTrigger.none
                    offer.activePriceValue = 0.0
                    offer.active = true
                    offer.expirationDate = Date(timeIntervalSince1970: owner.expiration)
                    offer.createdAt = Date()
                }
                if let offer = owner.offer {
                    return owner.offerRepository
                        .update(offer: offer, provider: provider)
                        .materialize()
                        .compactMap(\.value)
                        .eraseToAnyPublisher()
                } else {
                    return owner.offerRepository
                        .createOffer(keys: owner.offerKey, provider: provider)
                        .materialize()
                        .compactMap(\.value)
                        .eraseToAnyPublisher()
                }
            }
            .map { _ in .offerCreated }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupDeleteBinding() {
        guard let id = offer?.id else {
            return
        }
        action
            .filter { $0 == .delete }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.offerService
                    .deleteOffers(offerIds: [id])
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.offerRepository
                    .deleteOffers(with: [id])
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.offerDeleted)
            }
            .store(in: cancelBag)
    }
}