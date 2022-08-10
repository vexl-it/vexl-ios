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
    @Inject var groupManager: GroupManagerType

    // MARK: - View Bindings

    @Published var groupViewModels: [GroupCellViewModel] = []
    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Action Bindings

    enum UserAction: Equatable {
        case dismissTap, joinGroupTap, createGroupTap, leaveGroupTap(group: ManagedGroup)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case joinGroupTapped
        case leaveGroupTapped(group: ManagedGroup)
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
        userRepository.user?
            .publisher(for: \.groups)
            .compactMap { $0?.allObjects as? [ManagedGroup] }
            .map { [action] groups in
                groups.map { group in
                    GroupCellViewModel(group: group, action: action)
                }
            }
            .assign(to: &$groupViewModels)
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

        action
            .filter { $0 == .createGroupTap }
            .asVoid()
            .flatMap { [groupManager, primaryActivity] in
                groupManager.createGroup(
                    name: (0..<3)
                        .map { _ in Int.random(in: 0..<Constants.randomNameSyllables.count) }
                        .map { Constants.randomNameSyllables[$0] }
                        .joined()
                        .capitalizeFirstLetter + " Group" ,
                    logo: R.image.chainCamp()!,
                    expiration: Date(timeIntervalSinceNow: 60 * 60 * 24 * 14),
                    closureAt: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
                )
                .track(activity: primaryActivity)
                .materialize()
                .compactMap(\.value)
            }
            .sink()
            .store(in: cancelBag)

        action
            .compactMap { action -> ManagedGroup? in
                guard case let .leaveGroupTap(group) = action else {
                    return nil
                }
                return group
            }
            .map { group -> Route in
                .leaveGroupTapped(group: group)
            }
            .subscribe(route)
            .store(in: cancelBag)
    }

    func leave(group: ManagedGroup) {
        groupManager
            .leave(group: group)
            .track(activity: primaryActivity)
            .sink()
            .store(in: cancelBag)
    }
}
