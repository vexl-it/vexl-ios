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

    @Inject var userRepository: UserRepositoryType

    // MARK: - Fetch Bindings

    @Fetched(sortDescriptors: [ NSSortDescriptor(key: "name", ascending: true) ])
    var fetchedGroups: [ManagedGroup]

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case addLocation
        case deleteLocation(id: String)
        case resetFilter
        case applyFilter
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Dependencies

    @Inject var offerService: OfferServiceType

    // MARK: - View Bindings

    @Published var currentAmountRange: ClosedRange<Int>
    @Published var amountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer

    @Published var selectedFeeOptions: [OfferFeeOption] = []
    @Published var feeAmount: Double

    @Published var selectedPaymentMethodOptions: [OfferPaymentMethodOption]

    @Published var selectedBTCOptions: [OfferAdvancedBTCOption]
    @Published var selectedFriendDegreeOptions: [OfferFriendDegree]

    @Published var groupRows: [[ManagedGroup]] = []
    @Published var selectedGroups: [ManagedGroup] = []

    @Published var currency: Currency?

    @Published var locationViewModels: [OfferLocationViewModel] = []

    lazy var minAmountTextFieldViewModel: OfferAmountTextFieldViewModel = .init(
        type: .min,
        currentAmountRangePublisher: $currentAmountRange.eraseToAnyPublisher(),
        sliderBoundsPublisher: $amountRange.eraseToAnyPublisher(),
        currencyPublisher: $currency.filterNil().eraseToAnyPublisher(),
        rangeSetter: { [weak self] newRange in
            self?.setRange(newRange)
        }
    )
    lazy var maxAmountTextFieldViewModel: OfferAmountTextFieldViewModel = .init(
        type: .max,
        currentAmountRangePublisher: $currentAmountRange.eraseToAnyPublisher(),
        sliderBoundsPublisher: $amountRange.eraseToAnyPublisher(),
        currencyPublisher: $currency.filterNil().eraseToAnyPublisher(),
        rangeSetter: { [weak self] newRange in
            self?.setRange(newRange)
        }
    )

    var filterType: String { offerFilter.type.title }
    var formatedFeeAmount: String {
        // TODO: use NumberFormatter for percentages
        "< \(Int(feeAmount))%"
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case applyFilterTapped(OfferFilter)
    }

    var route: CoordinatingSubject<Route> = .init()
    let primaryActivity: Activity = .init()

    // MARK: - Variables
    var userAvatar: Data? {
        userRepository.user?.profile?.avatarData
    }
    var minFee: Double = Constants.OfferInitialData.minFee
    var maxFee: Double = Constants.OfferInitialData.maxFee
    private var currentLocations: [OfferLocation] {
        locationViewModels.compactMap(\.location)
    }
    private var currencyStepValue: Int {
        currency == .czk ? Constants.OfferInitialData.maxOfferCZKStep : Constants.OfferInitialData.maxOfferStep
    }
    private var initialAmountRange: ClosedRange<Int>?
    private var offerFilter: OfferFilter
    private let cancelBag: CancelBag = .init()

    init(offerFilter: OfferFilter) {
        self.offerFilter = offerFilter
        self.initialAmountRange = offerFilter.currentAmountRange
        currentAmountRange = offerFilter.currentAmountRange ?? Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
        selectedFeeOptions = offerFilter.selectedFeeOptions
        feeAmount = offerFilter.feeAmount
        locationViewModels = offerFilter.locations.map { OfferLocationViewModel(location: $0, currentLocations: offerFilter.locations) }
        selectedPaymentMethodOptions = offerFilter.selectedPaymentMethodOptions
        selectedBTCOptions = offerFilter.selectedBTCOptions
        selectedFriendDegreeOptions = offerFilter.selectedFriendDegreeOptions
        selectedGroups = offerFilter.selectedGroups
        setupCurrencyBindings(currency: offerFilter.currency)
        setupBindings()
    }

    func isFriendDegreeSelected(for option: OfferFriendDegree) -> Bool {
        selectedFriendDegreeOptions.contains(option)
    }

    private func setupCurrencyBindings(currency: Currency?) {
        if let currency = currency {
            self.currency = currency
        }

        $currency
            .removeDuplicates()
            .withUnretained(self)
            .sink { owner, option in
                let minOffer = Constants.OfferInitialData.minOffer
                let maxOffer = Constants.OfferInitialData.maxOffer
                let maxOfferCZK = Constants.OfferInitialData.maxOfferCZK

                switch option {
                case .eur, .usd:
                    owner.amountRange = minOffer...maxOffer
                    if let initialRange = owner.initialAmountRange {
                        owner.setRange(initialRange)
                    } else {
                        owner.currentAmountRange = minOffer...maxOffer
                    }
                case .czk:
                    owner.amountRange = minOffer...maxOfferCZK
                    if let initialRange = owner.initialAmountRange {
                        owner.setRange(initialRange)
                    } else {
                        owner.currentAmountRange = minOffer...maxOfferCZK
                    }
                case .none:
                    break
                }

                if let option = option {
                    owner.minAmountTextFieldViewModel.resetInitialRangeValues(withCurrency: option)
                    owner.maxAmountTextFieldViewModel.resetInitialRangeValues(withCurrency: option)
                }
                owner.initialAmountRange = nil
            }
            .store(in: cancelBag)
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
                owner.offerFilter.currentAmountRange = owner.currency.flatMap { _ in owner.currentAmountRange }
                owner.offerFilter.selectedFeeOptions = owner.selectedFeeOptions
                owner.offerFilter.feeAmount = owner.feeAmount
                owner.offerFilter.locations = owner.locationViewModels.compactMap(\.location)
                owner.offerFilter.selectedPaymentMethodOptions = owner.selectedPaymentMethodOptions
                owner.offerFilter.selectedBTCOptions = owner.selectedBTCOptions
                owner.offerFilter.selectedFriendDegreeOptions = owner.selectedFriendDegreeOptions
                owner.offerFilter.currency = owner.currency
                owner.offerFilter.selectedGroups = owner.selectedGroups

                owner.route.send(.applyFilterTapped(owner.offerFilter))
            }
            .store(in: cancelBag)

        userAction
            .filter { $0 == .resetFilter }
            .withUnretained(self)
            .sink { owner, _ in
                owner.resetFilter()
            }
            .store(in: cancelBag)

        locationActionBindings(userAction: userAction)

        $fetchedGroups
            .publisher
            .map(\.objects)
            .map { $0.splitIntoChunks(by: 2) }
            .assign(to: &$groupRows)
    }

    private func locationActionBindings(userAction: AnyPublisher<UserAction, Never>) {
        userAction
            .filter { $0 == .addLocation }
            .withUnretained(self)
            .sink { owner, _ in
                owner.locationViewModels.append(OfferLocationViewModel(location: nil, currentLocations: owner.currentLocations))
            }
            .store(in: cancelBag)

        userAction
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
    }

    private func resetFilter() {
        currentAmountRange = amountRange
        selectedFeeOptions = []
        feeAmount = 1
        locationViewModels = []
        selectedPaymentMethodOptions = []
        selectedBTCOptions = []
        selectedFriendDegreeOptions = []
        offerFilter.reset(with: currentAmountRange)
        selectedGroups = []
        currency = nil
    }

    private func setRange(_ range: ClosedRange<Int>) {
        let min = range.lowerBound / currencyStepValue
        let max = range.upperBound / currencyStepValue
        self.currentAmountRange = min...max
    }
}
