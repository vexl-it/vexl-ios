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
        case loading
        case results([LocationSuggestion])
        case error
    }

    // MARK: - Action Binding

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    @Published var state: State = .noUserInteraction
    @Published var name: String = ""
    @Published var isTextFieldFocused: Bool = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var location: LocationSuggestion?
    private var currentSuggestions: [LocationSuggestion] = []
    private let cancelBag: CancelBag = .init()

    init() {
        setupBindings()
        setupActions()
    }

    private func setupActions() {
        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case .suggestionTap(let suggestionInfo):
                    owner.name = suggestionInfo.suggestion
                    owner.isTextFieldFocused = false
                    owner.location = suggestionInfo
                }
            }
            .store(in: cancelBag)
    }

    private func setupBindings() {
        activityIndicator
            .loading
            .withUnretained(self)
            .filter { owner, isLoading in
                isLoading && owner.currentSuggestions.isEmpty
            }
            .map { _ in State.loading }
            .assign(to: &$state)

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
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .withUnretained(self)
            .flatMap { owner, text in
                owner.mapyService.getSuggestions(for: text)
                    .track(activity: owner.primaryActivity)
            }
            .handleEvents(receiveOutput: { [weak self] suggestions in
                self?.currentSuggestions = suggestions
            })
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
        case (.loading, .loading):
            return true
        case (.error, .error):
            return true
        case let (.results(lhsSuggestions), .results(rhsSuggestions)):
            return lhsSuggestions.map(\.suggestion) == rhsSuggestions.map(\.suggestion)
        default:
            return false
        }
    }
}
