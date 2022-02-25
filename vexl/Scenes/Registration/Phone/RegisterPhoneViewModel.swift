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

    // TODO: Add countdown after to show retry timer
    
    // MARK: - View State

    enum ViewState {
        case phoneInput
        case codeInput
        case codeInputValidation
        case codeInputSuccess

        var next: ViewState {
            switch self {
            case .phoneInput:
                return .codeInput
            case .codeInput:
                return .codeInputValidation
            case .codeInputValidation:
                return .codeInputSuccess
            case .codeInputSuccess:
                return .codeInputSuccess
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
    @Published var isActionEnabled = false
    @Published var currentState = ViewState.phoneInput

    var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var showCodeInput: Bool {
        [RegisterPhoneViewModel.ViewState.codeInput, .codeInputValidation, .codeInputSuccess].contains(currentState)
    }

    var codeInputEnabled: Bool {
        [RegisterPhoneViewModel.ViewState.codeInput].contains(currentState)
    }

    var actionTitle: String {
        switch currentState {
        case .phoneInput, .codeInput:
            return L.continue()
        case .codeInputValidation:
            return L.registerPhoneCodeInputVerifying()
        case .codeInputSuccess:
            return L.registerPhoneCodeInputSuccess()
        }
    }

    var actionColor: SolidButtonColor {
        switch currentState {
        case .codeInput, .phoneInput:
            return SolidButtonColor.welcome
        case .codeInputValidation:
            return SolidButtonColor.verifying
        case .codeInputSuccess:
            return SolidButtonColor.success
        }
    }

    private let cancelBag: CancelBag = .init()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $phoneNumber
            .withUnretained(self)
            .map { !$1.isEmpty && $0.currentState == .phoneInput }
            .assign(to: &$isActionEnabled)

        $validationCode
            .withUnretained(self)
            .map { !$1.isEmpty && $0.currentState == .codeInput }
            .assign(to: &$isActionEnabled)

        $currentState
            .withUnretained(self)
            .sink { owner, state in
                switch state {
                case .phoneInput:
                    owner.isActionEnabled = !owner.phoneNumber.isEmpty
                case .codeInput:
                    owner.isActionEnabled = !owner.validationCode.isEmpty
                case .codeInputValidation:
                    owner.isActionEnabled = false
                case .codeInputSuccess:
                    owner.isActionEnabled = true
                }
            }
            .store(in: cancelBag)

        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case .nextTap:
                    owner.currentState = owner.currentState.next

                    if owner.currentState == .codeInputValidation {
                        // Temporal simulation of the validation of the code
                        after(3) {
                            owner.currentState = owner.currentState.next
                        }
                    }
                }
            }
            .store(in: cancelBag)
    }
}
