//
//  RegisterPhoneViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import Foundation
import Combine
import Cleevio
import SwiftUI

final class RegisterPhoneViewModel: ViewModelType {

    // MARK: - View State

    enum State {
        case phoneInput
        case codeInput

        var next: State {
            switch self {
            case .phoneInput:
                return .codeInput
            case .codeInput:
                return .codeInput
            }
        }
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var phoneNumber = ""
    @Published var validationCode = ""
    @Published var isContinueEnabled = false
    @Published var currentState = State.phoneInput

    var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $phoneNumber
            .withUnretained(self)
            .map { !$1.isEmpty && $0.currentState == .phoneInput }
            .assign(to: &$isContinueEnabled)

        $validationCode
            .withUnretained(self)
            .map { !$1.isEmpty && $0.currentState == .codeInput }
            .assign(to: &$isContinueEnabled)

        $currentState
            .withUnretained(self)
            .sink { owner, state in
                switch state {
                case .phoneInput:
                    owner.isContinueEnabled = !owner.phoneNumber.isEmpty
                case .codeInput:
                    owner.isContinueEnabled = !owner.validationCode.isEmpty
                }
            }
            .store(in: cancelBag)

        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case .nextTap:
                    owner.currentState = owner.currentState.next
                }
            }
            .store(in: cancelBag)
    }
}
