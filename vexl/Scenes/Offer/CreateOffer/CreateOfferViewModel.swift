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

    @Inject var offerService: OfferServiceType
    @Inject var contactsMananger: ContactsManagerType
    @Inject var contactsService: ContactsServiceType

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

    @Published var selectedTradeStyleOption: OfferTradeStyleOption = .online

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []

    @Published var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption = .firstDegree
    @Published var selectedTypeOption: [OfferAdvancedTypeOption] = []

    @Published var isLoadingData = false
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private var contactsPublicKeys: [ContactKey] = []
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
        setupActivity()
        setupDataBindings()
        setupBindings()
        setupCreateOfferBinding()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    // MARK: - Bindings

    private func setupDataBindings() {
        isLoadingData = true
        offerService
            .getInitialOfferData()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, data in
                owner.isLoadingData = false
                owner.amountRange = data.minOffer...data.maxOffer
                owner.currentAmountRange = data.minOffer...data.maxOffer
                owner.minFee = data.minFee
                owner.maxFee = data.maxFee
                owner.currencySymbol = data.currencySymbol
            }
            .store(in: cancelBag)

        contactsService
            .getContacts(fromFacebook: false)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, response in
                owner.contactsPublicKeys.append(contentsOf: response.items)
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

    private func setupCreateOfferBinding() {
        action
            .share()
            .filter { $0 == .createOffer }
            .withUnretained(self)
            .sink { owner, _ in
                let minAmount = try? "\(owner.currentAmountRange.lowerBound)".ecc.encrypt(publicKey: owner.contactsPublicKeys[0].publicKey)
                print(minAmount)
            }
            .store(in: cancelBag)
//        action
//            .share()
//            .filter { $0 == .createOffer }
//            .withUnretained(self)
//            .map { owner, _ in
//                Offer(minAmount: owner.currentAmountRange.lowerBound,
//                      maxAmount: owner.currentAmountRange.upperBound,
//                      description: owner.description,
//                      feeState: owner.selectedFeeOption.rawValue,
//                      feeAmount: owner.feeAmount,
//                      locationState: owner.selectedTradeStyleOption.rawValue,
//                      paymentMethods: owner.selectedPaymentMethodOptions.map(\.rawValue),
//                      btcNetwork: owner.selectedTypeOption.map(\.rawValue),
//                      friendLevel: owner.selectedFriendDegreeOption.rawValue)
//            }
//            .withUnretained(self)
//            .sink { owner, offer in
//                let x: [EncryptedOffer] = owner.offerService
//                    .encryptOffer(withContactKey: owner.contactsPublicKeys.map { $0.publicKey },
//                                  offerKey: ECCKeys(),
//                                  offer: offer)
//                print(x)
//            }
//            .store(in: cancelBag)
//            .flatMap { owner, offer in
//                owner.offerService
//                    .encryptOffer(withContactKey: owner.contactsPublicKeys.map { $0.publicKey },
//                                  offerKey: ECCKeys(),
//                                  offer: offer)
//                    .track(activity: owner.primaryActivity)
//                    .materialize()
//                    .compactMap(\.value)
//            }
//            .withUnretained(self)
//            .flatMap { owner, encryptedOffer in
//                owner.offerService
//                    .createOffer(encryptedOffers: encryptedOffer)
//                    .track(activity: owner.primaryActivity)
//                    .materialize()
//                    .compactMap(\.value)
//            }
//            .sink { response in
//                print(response)
//            }
//            .store(in: cancelBag)
    }
}
