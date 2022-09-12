//
//  OfferLocationViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 11.08.2022.
//

import Foundation
import Cleevio
import Combine

final class OfferLocationViewModel: ViewModelType, ObservableObject, Identifiable {
    var id = UUID().uuidString

    @Inject var mapyService: MapyServiceType

    enum UserAction: Equatable {
        case suggestionTap(LocationSuggestion)
    }

    enum State: Equatable {
        case noUserInteraction
        case empty
        case results([LocationSuggestion])
        case error
    }

    // MARK: - Action Binding

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var state: State = .noUserInteraction
    @Published var name: String = ""
    @Published var isTextFieldFocused: Bool = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var location: OfferLocation?
    var currentLocations: [OfferLocation]
    var canBeModified = true
    private let cancelBag: CancelBag = .init()

    init(location: OfferLocation? = nil, currentLocations: [OfferLocation]) {
        self.location = location
        self.currentLocations = currentLocations
        self.name = location?.city ?? ""

        setupBindings()
        setupActions()
    }

    private func setupActions() {
        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case .suggestionTap(let suggestionInfo):
                    owner.name = suggestionInfo.city
                    owner.isTextFieldFocused = false
                    owner.canBeModified = false
                    owner.location = OfferLocation(locationSuggestion: suggestionInfo)
                }
            }
            .store(in: cancelBag)
    }

    private func setupBindings() {
        $isTextFieldFocused
            .filter { !$0 }
            .map { _ in State.noUserInteraction }
            .assign(to: &$state)

        $name
            .dropFirst()
            .filter { $0.isEmpty }
            .map { _ in State.empty }
            .assign(to: &$state)

        $name
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] text in
                if self?.location == nil {
                    self?.location = OfferLocation(city: text)
                } else {
                    self?.location?.city = text
                }
            })
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .withUnretained(self)
            .flatMap { owner, text -> AnyPublisher<(OfferLocationViewModel, [LocationSuggestion], String), Error> in
                owner.mapyService
                    .getSuggestions(for: text)
                    .map { (owner, $0, text) }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { owner, suggestions, text in
                if let match = suggestions.first(where: { $0.city == text }) {
                    owner.location = OfferLocation(locationSuggestion: match)
                }
            })
            .map { [currentLocations] _, suggestions, _ -> State in
                suggestions.isEmpty ? .empty : .results(Self.filterSuggestedLocations(suggestions, locations: currentLocations))
            }
            .replaceError(with: .error)
            .withUnretained(self)
            .filter { owner, _ in owner.isTextFieldFocused }
            .map(\.1)
            .assign(to: &$state)
    }

    private static func filterSuggestedLocations(_ suggestions: [LocationSuggestion], locations: [OfferLocation]) -> [LocationSuggestion] {
        let filtered = suggestions.filter { suggestion in
            !locations.contains(where: { $0.isEqual(toSuggestion: suggestion) })
        }
        return filtered
    }
}

extension OfferLocationViewModel.State {
    static func == (lhs: OfferLocationViewModel.State, rhs: OfferLocationViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.noUserInteraction, .noUserInteraction):
            return true
        case (.empty, .empty):
            return true
        case (.error, .error):
            return true
        case let (.results(lhsSuggestions), .results(rhsSuggestions)):
            return lhsSuggestions.map(\.city) == rhsSuggestions.map(\.city)
        default:
            return false
        }
    }
}
