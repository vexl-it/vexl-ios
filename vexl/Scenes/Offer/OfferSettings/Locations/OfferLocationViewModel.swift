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
    private var didUserPickFromSuggestions = false
    private let cancelBag: CancelBag = .init()

    init(location: OfferLocation? = nil) {
        self.location = location
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
                    owner.didUserPickFromSuggestions = true
                    owner.isTextFieldFocused = false
                    owner.location = OfferLocation(locationSuggestion: suggestionInfo)
                }
            }
            .store(in: cancelBag)
    }

    private func setupBindings() {
        $isTextFieldFocused
            .dropFirst()
            .filter { !$0 }
            .withUnretained(self)
            .sink { owner, _ in
                if !owner.didUserPickFromSuggestions {
                    owner.name = ""
                }

                owner.didUserPickFromSuggestions = false
                owner.state = .noUserInteraction
            }
            .store(in: cancelBag)

        $name
            .dropFirst()
            .filter { $0.isEmpty }
            .map { _ in State.empty }
            .assign(to: &$state)

        $name
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.location = nil
            })
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .withUnretained(self)
            .flatMap { owner, text in
                owner.mapyService.getSuggestions(for: text)
            }
            .map { suggestions -> State in
                suggestions.isEmpty ? .empty : .results(suggestions)
            }
            .replaceError(with: .error)
            .withUnretained(self)
            .filter { owner, _ in owner.isTextFieldFocused }
            .map(\.1)
            .assign(to: &$state)
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
