//
//  ChatViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio

final class ChatViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case selectFilter(option: ChatFilterOption)
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var filter: ChatFilterOption = .all
    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    private func setupActionBindings() {
        action
            .compactMap { action -> ChatFilterOption? in
                if case let .selectFilter(option) = action { return option }
                return nil
            }
            .withUnretained(self)
            .sink { owner, option in
                owner.filter = option
            }
            .store(in: cancelBag)
    }
}
