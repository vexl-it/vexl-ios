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

enum OfferSettingsError: LocalizedError {
    case locationError

    var errorDescription: String? {
        switch self {
        case .locationError:
            return L.errorMissingOfferLocation()
        }
    }
}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
final class OfferSettingsViewModel: ViewModelType, ObservableObject {

    @Inject var userRepository: UserRepositoryType
    @Inject var offerRepository: OfferRepositoryType
    @Inject var offerService: OfferServiceType
    @Inject var encryptionService: EncryptionServiceType
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

    @Published var encryptionProgress = 0
    @Published var encryptionMaxProgress = 0
    @Published var showEncryptionLoader = false

    @Published var offer: Offer = .init()
    @Published var primaryActivity: Activity = .init()
    var errorIndicator: ErrorIndicator { primaryActivity.error }
    var activityIndicator: ActivityIndicator { primaryActivity.indicator }

    @Published var deleteTimeUnit: OfferTriggerDeleteTimeUnit = .days
    @Published var deleteTime: String = Constants.defaultOfferDeleteTime
    @Published var groupRows: [[ManagedGroup]] = []
    @Published var state: State = .loaded
    @Published var error: Error?

    @Published var locationViewModels: [OfferLocationViewModel] = []
    lazy var minAmountTextFieldViewModel: OfferAmountTextFieldViewModel = .init(
        type: .min,
        offerPublisher: $offer,
        rangeSetter: { [weak self] newRange in
            self?.offer.setRange(newRange)
        }
    )
    lazy var maxAmountTextFieldViewModel: OfferAmountTextFieldViewModel = .init(
        type: .max,
        offerPublisher: $offer,
        rangeSetter: { [weak self] newRange in
            self?.offer.setRange(newRange)
        }
    )

    let triggerCurrency: Currency

    var isOfferNew: Bool { managedOffer == nil }
    var isButtonActive: Bool { isCreateEnabled && (offer != Offer(managedOffer: managedOffer) || areLocationsUpdated) }

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
        guard let amount = Double(offer.selectedPriceTriggerAmount) else {
            return 0
        }
        return amount
    }

    private var friendLevel: ContactFriendLevel {
        switch offer.selectedFriendDegreeOption {
        case .firstDegree:
            return .first
        case .secondDegree:
            return .second
        }
    }

    private var isCreateEnabled: Bool {
        guard (offer.selectedFeeOption == .withFee && offer.feeAmount > 0) || (offer.selectedFeeOption == .withoutFee) else {
            return false
        }

        guard !offer.selectedPaymentMethodOptions.isEmpty == true && !offer.selectedBTCOption.isEmpty else {
            return false
        }

        return !offer.description.isEmpty == true && !locationViewModels.compactMap(\.location).isEmpty
    }

    private var areLocationsUpdated: Bool {
        guard !locationViewModels.compactMap(\.location).isEmpty else {
            return false
        }

        guard locationViewModels.compactMap(\.location).allSatisfy(\.isValid) else {
            return false
        }

        let currentLocations = locationViewModels.compactMap(\.location)
        return currentLocations != initialLocations
    }

    var headerTitle: String {
        switch offerType {
        case .sell:
            return L.offerSellCreateTitle()
        case .buy:
            return L.offerBuyCreateTitle()
        }
    }

    private var isOfferModified: Bool {
        managedOffer?.description != offer.description
    }

    var actionTitle: String {
        if managedOffer != nil {
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

    var currentOfferLocations: [OfferLocation] {
        locationViewModels.compactMap(\.location)
    }

    var showDeleteButton: Bool {
        managedOffer != nil
    }

    var showDeleteTrigger: Bool {
        // TODO: - Add it back when the BE is ready to use expiration times. (VEX-848)
        // managedOffer == nil
        false
    }

    var userAvatar: Data? {
        userRepository.user?.profile?.avatarData
    }

    var minFee: Double = Constants.OfferInitialData.minFee
    var maxFee: Double = Constants.OfferInitialData.maxFee
    var offerKey: ECCKeys
    let offerType: OfferType

    private var initialLocations: [OfferLocation] = []
    private var managedOffer: ManagedOffer?
    private let secondsToWaitForOfferLoader = RunLoop.SchedulerTimeType.Stride(3)

    private let cancelBag: CancelBag = .init()

    init(offer: ManagedOffer) {
        self.offerKey = offer.inbox?.keyPair?.keys ?? ECCKeys()
        self.offerType = offer.currentUserPerspectiveOfferType ?? .buy
        self.managedOffer = offer
        self.triggerCurrency = offer.activePriceCurrency ?? .usd
        setup()
    }

    init(offerType: OfferType, offerKey: ECCKeys) {
        @Inject var cryptoManager: CryptocurrencyValueManagerType
        self.offerType = offerType
        self.offerKey = offerKey
        self.triggerCurrency = cryptoManager.selectedCurrency.value
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
        if let managedOffer = managedOffer {
            offer.update(with: managedOffer)
            let managedLocations = managedOffer.locations?.allObjects as? [ManagedOfferLocation] ?? []
            locationViewModels = managedLocations.map { [currentOfferLocations] in
                OfferLocationViewModel(location: $0.offerLocation, currentLocations: currentOfferLocations)
            }
            initialLocations = managedLocations.compactMap(\.offerLocation)
        }

        $fetchedGroups
            .publisher
            .map(\.objects)
            .map { $0.splitIntoChunks(by: 2) }
            .assign(to: &$groupRows)
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
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.showEncryptionLoader = false
            })
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
                owner.offer.isActive.toggle()
            }
            .store(in: cancelBag)

        sharedAction
            .filter { $0 == .addLocation }
            .withUnretained(self)
            .sink { owner, _ in
                let locationViewModel = OfferLocationViewModel(location: nil, currentLocations: owner.currentOfferLocations)
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
            offer.group = owner.offer.selectedGroup
            offer.currency = owner.offer.currency
            offer.minAmount = Double(owner.offer.calculatedAmountRange.lowerBound)
            offer.maxAmount = Double(owner.offer.calculatedAmountRange.upperBound)
            offer.offerDescription = owner.offer.description
            offer.feeState = owner.offer.selectedFeeOption
            offer.feeAmount = floor(owner.offer.feeAmount)
            offer.locationState = owner.offer.selectedTradeStyleOption
            offer.paymentMethods = owner.offer.selectedPaymentMethodOptions
            offer.btcNetworks = owner.offer.selectedBTCOption
            offer.friendLevel = owner.offer.selectedFriendDegreeOption
            offer.offerTypeRawType = owner.offerType.rawValue
            offer.activePriceState = owner.offer.selectedPriceTrigger
            offer.activePriceValue = owner.priceTriggerAmount
            offer.activePriceCurrency = owner.triggerCurrency
            offer.active = owner.offer.isActive
            offer.expirationDate = Date(timeIntervalSince1970: owner.expiration)
            offer.createdAt = Date()
            offer.generateSymmetricKey()
        }

        let checkLocations = action
            .filter { $0 == .createOffer }
            .asVoid()
            .withUnretained(self)
            .flatMap { owner -> AnyPublisher<Void, Never> in
                Future<Void, Error> { promise in
                    let hasValidSuggestion = owner.locationViewModels.allSatisfy { $0.location?.isMapySuggestion == true }
                    guard hasValidSuggestion && !owner.locationViewModels.isEmpty else {
                        promise(.failure(OfferSettingsError.locationError))
                        return
                    }
                    promise(.success(()))
                }
                .track(activity: owner.primaryActivity)
            }

        let userPublicKey = checkLocations
            .withUnretained(self)
            .flatMap { owner, _ in
                Future<String, Error> { [weak owner] promise in
                    guard let userPublicKey = owner?.userRepository.user?.profile?.keyPair?.publicKey else {
                        promise(.failure(PersistenceError.insufficientData))
                        return
                    }
                    promise(.success(userPublicKey))
                }
                .track(activity: owner.primaryActivity)
            }

        let receiverPublicKeys = userPublicKey
            .withUnretained(self)
            .flatMap { owner, userPublicKey -> AnyPublisher<PKsEnvelope, Never> in
                owner.offerService
                    .getReceiverPublicKeys(
                        friendLevel: owner.friendLevel,
                        groups: [owner.offer.selectedGroup].compactMap { $0 },
                        includeUserPublicKey: userPublicKey
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
            .flatMap { owner, receiverPublicKeys -> AnyPublisher<(Bool, ManagedOffer, PKsEnvelope)?, Never> in
                guard let offer = owner.managedOffer else {
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
            .flatMap { owner, receiverPublicKeys -> AnyPublisher<(Bool, ManagedOffer, PKsEnvelope)?, Never> in
                guard owner.managedOffer == nil else {
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

        let disableIdleTimer = offerData
            .handleEvents(receiveOutput: { _ in
                UIApplication.shared.isIdleTimerDisabled = true
            })

        let encryption = disableIdleTimer
            .withUnretained(self)
            .flatMap { owner, zip in
                let (isCreating, offer, receiverPublicKeys) = zip
                return owner.encryptOffer(isCreating: isCreating, offer: offer, publicKeyEnvelope: receiverPublicKeys)

                // NOTE: The progress bar *could* be interuptable. If user would decide to hide the progress bar, you could:
                // 1. collect all encrypted payloads and send them to BE
                // 2. collect all publicKeys, that are yet to be encrypted and call
                //    `SyncQueue.add(type: .offerEncryptionUpdate, object: offer, publicKeys: publicKeys)`
                //
                // This will cause the operation to be split into two steps, one that ran on users foreground and creted the offer
                // and second that will run on background and will fill the rest of the contact payloads.
            }

        let beRequest = encryption
            .withUnretained(self)
            .flatMap { [offerService] owner, zip -> AnyPublisher<(OfferPayload, ManagedOffer), Never> in
                let (isCreating, payload, offer) = zip
                if !isCreating, let adminID = offer.adminID {
                    return offerService
                        .updateOffers(adminID: adminID, offerPayload: payload)
                        .track(activity: owner.primaryActivity)
                        .materialize()
                        .compactMap(\.value)
                        .map { ($0, offer) }
                        .eraseToAnyPublisher()
                }
                return offerService
                    .createOffer(offerPayload: payload)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { ($0, offer) }
                    .eraseToAnyPublisher()
            }

        let updateOfferId = beRequest
            .flatMap { [offerRepository, primaryActivity] responsePayload, offer -> AnyPublisher<Void, Never> in
                guard let adminID = responsePayload.adminId,
                    offer.adminID != adminID,
                    offer.offerID != responsePayload.offerId else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
                return offerRepository
                    .update(offer: offer, locations: nil) { offer in
                        offer.offerID = responsePayload.offerId
                        offer.adminID = adminID
                    }
                    .asVoid()
                    .track(activity: primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }

        let enableIdleTimer = updateOfferId
            .handleEvents(receiveOutput: { _ in
                UIApplication.shared.isIdleTimerDisabled = false
            })

        enableIdleTimer
            .delay(for: secondsToWaitForOfferLoader, scheduler: RunLoop.main)
            .map { _ in .offerCreated }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupDeleteBinding() {
        guard let adminID = managedOffer?.adminID, let offerID = managedOffer?.offerID else {
            return
        }
        action
            .filter { $0 == .delete }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.offerService
                    .deleteOffers(adminIDs: [adminID])
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.offerRepository
                    .deleteOffers(offerIDs: [offerID])
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

    /// The receiver keys are split into groups of X keys.
    /// After that each group is encrypted using the `OfferService` - `encryptOffer` method.
    /// Once the encryption is done, the progress number is updated so that it is visualized in the progress view
    /// When all the groups have finish encrypting, the publishers are collected an a single array of payloads is sent to the stream.
    private func encryptOffer(isCreating: Bool,
                              offer: ManagedOffer,
                              publicKeyEnvelope: PKsEnvelope) -> AnyPublisher<(Bool, OfferRequestPayload, ManagedOffer), Never> {
        guard let symmetricKey = offer.symmetricKey else {
            return Fail(error: AESError.couldMotGeneratePassword)
                .trackError(errorIndicator)
                .eraseToAnyPublisher()
        }

        let receiverPublicKeys = publicKeyEnvelope.allPublicKeys
        let receiverChunksRatio = (Double(receiverPublicKeys.count) / Double(Constants.encryptionKeySplitAmount))
        let receiverChunksCount = Int(receiverChunksRatio.rounded(.up))

        let chuncks = offerService
            .generateOfferPayloadPrivateParts(envelope: publicKeyEnvelope, symmetricKey: symmetricKey)
            .flatMap { $0.splitIntoChunks(by: Constants.encryptionKeySplitAmount).publisher }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, chunks in
                owner.showEncryptionLoader = true
                owner.encryptionProgress = 0
                owner.encryptionMaxProgress = chunks.count + 1
            })
            .map(\.1)

        let privatePartEncryption = chuncks
            .flatMap { [offerService] privateParts in
                offerService.encryptOfferPayloadPrivateParts(privateParts: privateParts)
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, payloads in
                owner.encryptionProgress += payloads.count
            })
            .map { $0.1 }
            .collect(receiverChunksCount)
            .map { chunks in chunks.flatMap { $0 } }
            .eraseToAnyPublisher()

        let publicPartEncryption = privatePartEncryption
            .flatMap { [encryptionService] privateParts -> AnyPublisher<(String, [OfferPayloadPrivateWrapperEncrypted]), Error> in
                encryptionService
                    .encryptOfferPayloadPublic(offer: offer, symmetricKey: symmetricKey)
                    .map { ($0, privateParts) }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.encryptionProgress += 1
            })
            .map { $0.1 }

        let requestPayload = publicPartEncryption
            .withUnretained(self)
            .map { (owner: OfferSettingsViewModel, tupl: (String, [OfferPayloadPrivateWrapperEncrypted])) -> OfferRequestPayload in
                let (publicPart, privateParts) = tupl
                return OfferRequestPayload(
                    offerType: owner.offerType.rawValue,
                    expiration: Int(owner.expiration),
                    payloadPublic: publicPart,
                    offerPrivateList: privateParts
                )
            }

        return requestPayload
            .map { (isCreating, $0, offer) }
            .trackError(errorIndicator)
            .eraseToAnyPublisher()
    }
}
