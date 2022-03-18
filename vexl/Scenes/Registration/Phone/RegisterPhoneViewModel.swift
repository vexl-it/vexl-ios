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

    // MARK: - Property Injection

    @Inject var userService: UserServiceType

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

    // swiftlint:disable function_body_length
    private func setupBindings() {
        $phoneNumber
            .withUnretained(self)
            .map { $0.validatePhoneNumber($1) && $0.currentState == .phoneInput }
            .assign(to: &$isActionEnabled)

        $validationCode
            .withUnretained(self)
            .map { $0.validateCode($1) && $0.currentState == .codeInput }
            .assign(to: &$isActionEnabled)

        $currentState
            .withUnretained(self)
            .sink { owner, state in
                switch state {
                case .phoneInput:
                    owner.isActionEnabled = owner.validatePhoneNumber(owner.phoneNumber)
                case .codeInput:
                    owner.isActionEnabled = owner.validateCode(owner.validationCode)
                case .codeInputValidation:
                    owner.isActionEnabled = false
                case .codeInputSuccess:
                    owner.isActionEnabled = true
                }
            }
            .store(in: cancelBag)

        $currentState
            .useAction(action: .codeInput)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.userService.validatePhone(phoneNumber: owner.phoneNumber)
                    .catch { error in
                        Just(false)
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { _ in
                
            })
            .sink { _ in
                
            }
            .store(in: cancelBag)

        action
            .useAction(action: .nextTap)
            .withUnretained(self)
            .filter { $0.0.currentState == .codeInputSuccess }
            .sink { owner, _ in
                owner.route.send(.continueTapped)
            }
            .store(in: cancelBag)

        action
            .withUnretained(self)
            .filter { $0.1 == .nextTap && $0.0.currentState != .codeInputSuccess }
            .sink { owner, _ in
                owner.currentState = owner.currentState.next
            }
            .store(in: cancelBag)

        action
            .withUnretained(self)
            .filter { $0.0.currentState != .codeInputSuccess }
            .sink { owner, _ in
                if owner.currentState == .codeInputValidation {
                    after(3) {
                        owner.currentState = owner.currentState.next
                    }
                }
            }
            .store(in: cancelBag)

//        action
//            .withUnretained(self)
//            .sink { owner, action in
//                switch action {
//                case .nextTap:
//                    switch owner.currentState {
//                    case .codeInput, .codeInputValidation, .phoneInput:
//                        owner.currentState = owner.currentState.next
//                        if owner.currentState == .codeInputValidation {
//                            // Temporal simulation of the validation of the code
//                            after(3) {
//                                owner.currentState = owner.currentState.next
//                            }
//                        }
//                    case .codeInputSuccess:
//                        owner.route.send(.continueTapped)
//                    }
//                }
//            }
//            .store(in: cancelBag)
    }

    private func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        !phoneNumber.isEmpty
    }

    private func validateCode(_ code: String) -> Bool {
        !code.isEmpty
    }
}
