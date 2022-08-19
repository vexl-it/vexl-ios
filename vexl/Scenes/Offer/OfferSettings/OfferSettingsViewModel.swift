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

    @Inject var userRepository: UserRepositoryType
    @Inject var offerRepository: OfferRepositoryType
    @Inject var offerService: OfferServiceType
    @Inject var mapyService: MapyServiceType

    @Fetched(sortDescriptors: [ NSSortDescriptor(key: "name", ascending: true) ])
    var fetchedGroups: [ManagedGroup]

    enum UserAction: Equatable {
        case activate
        case delete
        case addLocation
        case deleteLocation(id: String)
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
    @Published var feeAmount: Double = Constants.OfferInitialData.minFee

    @Published var selectedTradeStyleOption: OfferTradeLocationOption = .online

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []

    @Published var selectedBTCOption: [OfferAdvancedBTCOption] = []
    @Published var selectedFriendDegreeOption: OfferFriendDegree = .firstDegree

    @Published var selectedPriceTrigger: OfferTrigger = .none
    @Published var selectedPriceTriggerAmount: String = "0"

    @Published var deleteTimeUnit: OfferTriggerDeleteTimeUnit = .days
    @Published var deleteTime: String = Constants.defaultOfferDeleteTime

    @Published var isActive = true

    @Published var groupRows: [[ManagedGroup]] = []
    @Published var selectedGroup: ManagedGroup?

    @Published var state: State = .loaded
    @Published var error: Error?

    @Published var currency: Currency? = Constants.OfferInitialData.currency

    @Published var locationViewModels: [OfferLocationViewModel] = []

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
        let additionalSeconds: TimeInterval = {
            switch deleteTimeUnit {
            case .days:
                return time * Constants.daysToSecondsMultiplier
            case .weeks:
                return time * Constants.weeksToSecondsMultiplier
            case .months:
                return time * Constants.monthsToSecondsMultiplier
            }
        }()
        return Date().timeIntervalSince1970 + additionalSeconds
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

        return !description.isEmpty && !locationViewModels.compactMap(\.location).isEmpty
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

    var minFee: Double = Constants.OfferInitialData.minFee
    var maxFee: Double = Constants.OfferInitialData.maxFee
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
        setupCurrencyBindings()
        setupDataBindings()
        setupActivity()
        setupBindings()
        setupDeleteBinding()
    }

    // MARK: - Bindings

    private func setupDataBindings() {
        if let offer = offer {
            isActive = offer.active
            description = offer.offerDescription ?? ""
            currency = offer.currency ?? .usd
            currentAmountRange = Int(offer.minAmount)...Int(offer.maxAmount)
            selectedFeeOption = offer.feeState ?? .withoutFee
            feeAmount = offer.feeAmount
            selectedTradeStyleOption = offer.locationState ?? .personal
            selectedPaymentMethodOptions = offer.paymentMethods
            selectedBTCOption = offer.btcNetworks
            selectedFriendDegreeOption = offer.friendLevel ?? .firstDegree
            selectedPriceTrigger = offer.activePriceState ?? .none
            selectedPriceTriggerAmount = "\(Int(offer.activePriceValue))"

            let managedLocations = offer.locations?.allObjects as? [ManagedOfferLocation] ?? []
            locationViewModels = managedLocations.map {
                OfferLocationViewModel(location: $0.offerLocation)
            }
        }

        $fetchedGroups
            .publisher
            .map(\.objects)
            .map { $0.splitIntoChunks(by: 2) }
            .assign(to: &$groupRows)
    }

    private func setupCurrencyBindings() {
        $currency
            .withUnretained(self)
            .sink { owner, option in
                switch option {
                case .eur, .usd:
                    owner.amountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
                    owner.currentAmountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
                case .czk:
                    owner.amountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOfferCZK
                    owner.currentAmountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOfferCZK
                case .none:
                    break
                }
            }
            .store(in: cancelBag)
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
                let locationViewModel = OfferLocationViewModel()
                owner.setupLocationBindings(for: locationViewModel)
                owner.locationViewModels.append(locationViewModel)
            }
            .store(in: cancelBag)

        sharedAction
            .compactMap { action -> String? in
                if case let .deleteLocation(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .sink { owner, id in
                guard let index = owner.locationViewModels.firstIndex(where: { $0.id == id }) else {
                    return
                }

                var newLocations = owner.locationViewModels
                newLocations.remove(at: index)
                owner.locationViewModels = newLocations
            }
            .store(in: cancelBag)

        setupCreateOfferAction()
    }

    func setupCreateOfferAction() { // swiftlint:disable:this function_body_length
        let provider: (ManagedOffer) -> Void = { [weak self] offer in
            guard let owner = self else { return }
            offer.group = owner.selectedGroup
            offer.currency = owner.currency
            offer.minAmount = Double(owner.currentAmountRange.lowerBound)
            offer.maxAmount = Double(owner.currentAmountRange.upperBound)
            offer.offerDescription = owner.description
            offer.feeState = owner.selectedFeeOption
            offer.feeAmount = owner.feeAmount
            offer.locationState = owner.selectedTradeStyleOption
            offer.paymentMethods = owner.selectedPaymentMethodOptions
            offer.btcNetworks = owner.selectedBTCOption
            offer.friendLevel = owner.selectedFriendDegreeOption
            offer.type = owner.offerType
            offer.activePriceState = owner.selectedPriceTrigger
            offer.activePriceValue = owner.priceTriggerAmount
            offer.active = owner.isActive
            offer.expirationDate = Date(timeIntervalSince1970: owner.expiration)
            offer.createdAt = Date()
        }

        let receiverPublicKeys = action
            .filter { $0 == .createOffer }
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[String], Never> in
                owner.offerService
                    .getReceiverPublicKeys(
                        friendLevel: owner.friendLevel,
                        group: owner.selectedGroup,
                        includeUserPublicKey: owner.userRepository.user?.profile?.keyPair?.publicKey
                    )
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .share()

        // IDEA FOR DISCUSSION: show alert to user when the number of receiverPublicKeys is greater than some treshold (lets say 500 pks).
        // If it would be more, we could show the alert and then progress bar
        // If it would be less, we could run the encryption on the backgroun using SyncQueue

        let update = receiverPublicKeys
            .withUnretained(self)
            .flatMap { owner, receiverPublicKeys -> AnyPublisher<(Bool, ManagedOffer, [String])?, Never> in
                guard let offer = owner.offer else {
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
                return owner.offerRepository
                    .update(
                        offer: offer,
                        locations: owner.locationViewModels.compactMap(\.location),
                        provider: provider
                    )
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { (false, $0, receiverPublicKeys) }
                    .eraseToAnyPublisher()
            }

        let create = receiverPublicKeys
            .withUnretained(self)
            .flatMap { owner, receiverPublicKeys -> AnyPublisher<(Bool, ManagedOffer, [String])?, Never> in
                guard owner.offer == nil else {
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
                return owner.offerRepository
                    .createOffer(
                        keys: owner.offerKey,
                        locations: owner.locationViewModels.compactMap(\.location),
                        provider: provider
                    )
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { (true, $0, receiverPublicKeys) }
                    .eraseToAnyPublisher()
            }

        let offerData = Publishers.Zip(create, update)
            .compactMap { $0 ?? $1 }

        let encryption = offerData
            .flatMap { [offerService, primaryActivity] isCreating, offer, receiverPublicKeys in
                // TODO: devide receiverPublicKeys into chunks of (lets say) 100. These chunks can be incement number for progress bar
                // NOTE: Use `receiverPublicKeys.splitIntoChunks(by: 100)` to do that
                offerService
                    .encryptOffer(offer: offer, publicKeys: receiverPublicKeys)
                    .track(activity: primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { (isCreating, $0, offer) }

                // NOTE: The progress bar *could* be interuptable. If user would decide to hide the progress bar, you could:
                // 1. collect all encrypted payloads and send them to BE
                // 2. collect all publicKeys, that are yet to be encrypted and call
                //    `SyncQueue.add(type: .offerEncryptionUpdate, object: offer, publicKeys: publicKeys)`
                //
                // This will cause the operation to be split into two steps, one that ran on users foreground and creted the offer
                // and second that will run on background and will fill the rest of the contact payloads.
            }

        let beRequest = encryption
            .flatMap { [offerService, expiration, primaryActivity] isCreating, payloads, offer -> AnyPublisher<(OfferPayload, ManagedOffer), Never> in
                guard !isCreating, let id = offer.id else {
                    return offerService
                        .createOffer(
                            expiration: Date(timeIntervalSince1970: expiration),
                            offerPayloads: payloads
                        )
                        .track(activity: primaryActivity)
                        .materialize()
                        .compactMap(\.value)
                        .map { ($0, offer) }
                        .eraseToAnyPublisher()
                }
                return offerService
                    .updateOffers(offerID: id, offerPayloads: payloads)
                    .track(activity: primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { ($0, offer) }
                    .eraseToAnyPublisher()
            }

        let updateOfferId = beRequest
            .flatMap { [offerRepository, primaryActivity] responsePayload, offer -> AnyPublisher<Void, Never> in
                guard let id = responsePayload.offerId else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
                return offerRepository
                    .update(offer: offer, locations: nil) { offer in
                        offer.id = id
                    }
                    .asVoid()
                    .track(activity: primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }

        updateOfferId
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
                    .deleteOffers(withIDs: [id])
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.offerDeleted)
            }
            .store(in: cancelBag)
    }

    // TODO: this is a hotfix so BE doesn't return error when creating the offer.
    // A better solution would be to have an alert o message in the form to tell the user what is missing
    private func setupLocationBindings(for locationViewModel: OfferLocationViewModel) {
        locationViewModel.$name
            .withUnretained(self)
            .sink { owner, _ in
                owner.objectWillChange.send()
            }
            .store(in: cancelBag)
    }
}
