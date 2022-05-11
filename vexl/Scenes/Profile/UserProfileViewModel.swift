//
//  UserProfileViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class UserProfileViewModel: ViewModelType, ObservableObject {

    @Inject var authenticationManager: AuthenticationManagerType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case itemTap(option: Option)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()
    // TODO: - Remove hardcoded values
    var username: String {
        authenticationManager.currentUser?.username ?? ""
    }

    var contacts: String {
        "34"
    }

    var avatar: Data? {
        authenticationManager.currentUser?.avatarImage ?? R.image.onboarding.emptyAvatar()?.jpegData(compressionQuality: 1)
    }

    var options: [OptionGroup] {
        Option.groupedOptions
    }

    func subtitle(for item: UserProfileViewModel.Option) -> String? {
        switch item {
        case .contacts:
            return item.subtitle(withParam: contacts)
        default:
            return nil
        }
    }

    init() {
        setupBindings()
    }

    private func setupBindings() {
        action
            .compactMap { action -> Option? in
                if case let .itemTap(option) = action { return option } else { return nil }
            }
            .filter { $0 == .logout }
            .withUnretained(self)
            .sink { owner, _ in
                owner.authenticationManager.logoutUser()
            }
            .store(in: cancelBag)
    }
}
