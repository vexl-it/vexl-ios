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

typealias OfferData = (offer: Offer, contacts: [ContactKey])
typealias OfferAndEncryptedOffers = (offer: Offer, encryptedOffers: [EncryptedOffer])
typealias OfferAndEncryptedOffer = (offer: Offer, encryptedOffer: EncryptedOffer)

// TODO: - Update file and class models once the offer DB migration is done. We are keeping this name to avoid conflicts

class CreateOfferViewModel: ViewModelType, ObservableObject {

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

    @Inject var userSecurity: UserSecurityType
    @Inject var offerService: OfferServiceType
    @Inject var chatService: ChatServiceType
    @Inject var contactsMananger: ContactsManagerType
    @Inject var contactsService: ContactsServiceType

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

    @Published var amountRange: ClosedRange<Int> = 0...0
    @Published var currentAmountRange: ClosedRange<Int> = 0...0

    @Published var selectedFeeOption: OfferFeeOption = .withoutFee
    @Published var feeAmount: Double = 0

    @Published var locations: [OfferLocationItemData] = []

    @Published var selectedTradeStyleOption: OfferTradeLocationOption = .online

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []

    @Published var selectedBTCOption: [OfferAdvancedBTCOption] = []
    @Published var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption = .firstDegree

    @Published var selectedPriceTrigger: OfferTrigger = .none
    @Published var selectedPriceTriggerAmount: String = "0"

    @Published var deleteTimeUnit: OfferTriggerDeleteTimeUnit = .days
    @Published var deleteTime: String = Constants.defaultDeleteTime

    @Published var isActive = true

    @Published var state: State = .initial
    @Published var error: Error?

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
        ""
    }

    var showDeleteButton: Bool {
        false
    }

    var showDeleteTrigger: Bool {
        true
    }

    var minFee: Double = 0
    var maxFee: Double = 0
    var currencySymbol = ""
    var offerKey: ECCKeys
    let offerType: OfferType

    let cancelBag: CancelBag = .init()

    init(offerType: OfferType, offerKey: ECCKeys) {
        self.offerType = offerType
        self.offerKey = offerKey
        setupDataBindings()
        setupActivity()
        setupBindings()
        setupCreateOfferBinding()
    }

    func prepareOffer(encryptedOffers: [EncryptedOffer], expiration: TimeInterval) -> AnyPublisher<EncryptedOffer, Error> {
        fatalError("Need to override implementation for this method")
    }

    func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        fatalError("Need to override implementation for this method")
    }

    func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        fatalError("Need to override implementation for this method")
    }

    func setInitialValues(data: OfferInitialData) {
        fatalError("Need to override implementation for this method")
    }

    // MARK: - Bindings

    private func setupDataBindings() {
        offerService
            .getInitialOfferData()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, data in
                owner.state = .loaded
                owner.amountRange = data.minOffer...data.maxOffer
                owner.currentAmountRange = data.minOffer...data.maxOffer
                owner.minFee = data.minFee
                owner.maxFee = data.maxFee
                owner.currencySymbol = data.currencySymbol

                owner.setInitialValues(data: data)
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
    }

    // swiftlint: disable function_body_length
    private func setupCreateOfferBinding() {
        let fetchContacts = action
            .share()
            .filter { $0 == .createOffer }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.contactsService
                    .getAllContacts(friendLevel: owner.friendLevel,
                                    hasFacebookAccount: owner.userSecurity.facebookSecurityHeader != nil,
                                    pageLimit: Constants.pageMaxLimit)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }

        let encryptOffer = fetchContacts
            .withUnretained(self)
            .map { owner, contacts -> OfferData in
                let offer = Offer(minAmount: owner.currentAmountRange.lowerBound,
                                  maxAmount: owner.currentAmountRange.upperBound,
                                  description: owner.description,
                                  feeState: owner.selectedFeeOption,
                                  feeAmount: Double(owner.feeValue),
                                  locationState: owner.selectedTradeStyleOption,
                                  paymentMethods: owner.selectedPaymentMethodOptions,
                                  btcNetwork: owner.selectedBTCOption,
                                  friendLevel: owner.selectedFriendDegreeOption,
                                  type: owner.offerType,
                                  priceTriggerState: owner.selectedPriceTrigger,
                                  priceTriggerValue: owner.priceTriggerAmount,
                                  isActive: owner.isActive,
                                  source: .created)

                // Adding owner publicKey to the list so that it can be decrypted, displayed and modified
                // Also we remove the duplicate keys that can arrive because of the 2nd level friend

                var contacts = contacts.phone.items + contacts.facebook.items
                contacts.append(ContactKey(publicKey: owner.userSecurity.userKeys.publicKey))
                let contactsWithoutDuplicates = Array(Set(contacts))
                return OfferData(offer: offer, contacts: contactsWithoutDuplicates)
            }
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .withUnretained(self)
            .flatMap { owner, offerData in
                owner.offerService
                    .encryptOffer(withContactKey: offerData.contacts.map(\.publicKey),
                                  offerKey: owner.offerKey,
                                  offer: offerData.offer)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { OfferAndEncryptedOffers(offer: offerData.offer, encryptedOffers: $0) }
                    .eraseToAnyPublisher()
            }

        let createOffer = encryptOffer
            .withUnretained(self)
            .flatMap { owner, offerAndEncryptedOffers in
                owner.prepareOffer(encryptedOffers: offerAndEncryptedOffers.encryptedOffers, expiration: owner.expiration)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { OfferAndEncryptedOffer(offer: offerAndEncryptedOffers.offer, encryptedOffer: $0) }
                    .eraseToAnyPublisher()
            }

        createOffer
            .flatMapLatest(with: self) { owner, offerAndEncryptedOffer -> AnyPublisher<Void, Never> in
                var newOffer = offerAndEncryptedOffer.offer
                newOffer.offerId = offerAndEncryptedOffer.encryptedOffer.offerId
                newOffer.offerPublicKey = owner.offerKey.publicKey
                newOffer.offerPrivateKey = owner.offerKey.privateKey

                return owner.storeOffers(offers: [newOffer], areCreated: true)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .flatMapLatest(with: self) { owner, _ in
                // TODO: setup firebase notifications to get a proper token
                owner.createInbox(offerKey: owner.offerKey,
                                  pushToken: Constants.pushNotificationToken)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .receive(on: RunLoop.main)
            .map { _ in .offerCreated }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
