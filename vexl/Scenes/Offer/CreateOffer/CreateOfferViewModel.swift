//
//  CreateOfferViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import Foundation
import Cleevio
import SwiftUI

final class CreateOfferViewModel: ViewModelType, ObservableObject {

    typealias OfferData = (offer: Offer, contacts: [ContactKey])

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

    @Inject var userSecurity: UserSecurityType
    @Inject var offerService: OfferServiceType
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

    @Published var state: State = .initial
    @Published var error: Error?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case offerCreated
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

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

    var minFee: Double = 0
    var maxFee: Double = 0
    var currencySymbol = ""
    let offerKey = ECCKeys()
    let offerType: OfferType

    private let cancelBag: CancelBag = .init()

    init(offerType: OfferType) {
        self.offerType = offerType
        setupActivity()
        setupDataBindings()
        setupBindings()
        setupCreateOfferBinding()
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
            }
            .store(in: cancelBag)
    }

    private func setupBindings() {
        action
            .share()
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)

        action
            .share()
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
            .share()
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
                                  type: owner.offerType)

                // Adding owner publicKey to the list so that it can be decrypted, displayed and modified

                var contacts = contacts.phone.items + contacts.facebook.items
                contacts.append(ContactKey(publicKey: owner.userSecurity.userKeys.publicKey))
                return OfferData(offer: offer, contacts: contacts)
            }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .withUnretained(self)
            .flatMap { owner, offerData in
                owner.offerService
                    .encryptOffer(withContactKey: offerData.contacts.map(\.publicKey),
                                  offerKey: owner.offerKey,
                                  offer: offerData.offer)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }

        let createOffer = encryptOffer
            .withUnretained(self)
            .flatMap { owner, encryptedOffer in
                owner.offerService
                    .createOffer(encryptedOffers: encryptedOffer)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }

        createOffer
            .withUnretained(self)
            .flatMap { owner, response in
                owner.offerService
                    .storeOfferKey(key: owner.offerKey, withId: response.offerId, offerType: owner.offerType)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .subscribe(on: RunLoop.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.offerCreated)
            }
            .store(in: cancelBag)
    }
}
