//
//  GroupsViewModel.swift
//  vexl
//
//  Created by Adam Salih on 01.08.2022.
//

import Foundation
import Cleevio
import Combine

final class GroupsViewModel: ViewModelType, ObservableObject {

    // MARK: - Dependency Bindings

    @Inject var userRepository: UserRepositoryType

    // MARK: - View Bindings

    @Published var groups: [ManagedGroup] = []
    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Action Bindings

    enum UserAction: Equatable {
        case dismissTap, joinGroupTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case joinGroupTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        setupDataBindings()
        setupActivityBindings()
        setupActionBindings()
    }

    private func setupDataBindings() {
        userRepository.user?.profile?
            .publisher(for: \.groups)
            .compactMap { $0?.allObjects as? [ManagedGroup] }
            .assign(to: &$groups)
    }

    private func setupActivityBindings() {
        primaryActivity.indicator
            .loading
            .assign(to: &$isLoading)

        primaryActivity.error
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupActionBindings() {
        let action = action.share()

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .joinGroupTap }
            .map { _ -> Route in .joinGroupTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
