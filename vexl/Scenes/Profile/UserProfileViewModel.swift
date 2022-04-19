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

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
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
    let username: String = "Diego"
    var contacts: String {
        "34"
    }
    var currencySymbol: String {
        "$"
    }
    var amount: String {
        "1234"
    }
    var avatar: Data? {
        R.image.onboarding.emptyAvatar()?.jpegData(compressionQuality: 1)
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
}
