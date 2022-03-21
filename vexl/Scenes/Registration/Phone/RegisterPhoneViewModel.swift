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

    // MARK: - Property Injection

    @Inject var userService: UserServiceType
    @Inject var authenticationManager: AuthenticationManager

    // MARK: - View State

    enum ViewState {
        case phoneInput
        case codeInput
        case codeInputValidation
        case codeInputSuccess
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
        case sendCode
    }

    let action: ActionSubject<UserAction> = .init()
    let triggerCountdown: ActionSubject<Date?>  = .init()

    // MARK: - View Bindings

    @Published var phoneNumber = ""
    @Published var validationCode = ""
    @Published var isActionEnabled = false
    @Published var currentState = ViewState.phoneInput

    @Published var loading = false
    @Published var error: Error?

    @Published var countdown = 0

    // MARK: - Activities

    var primaryActivity: Activity
    var errorIndicator: ErrorIndicator = .init()
    var activityIndicator: ActivityIndicator = .init()

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

    // MARK: - Timer

    private var timer: Timer.TimerPublisher?
    private let cancelBag: CancelBag = .init()

    init() {
        self.primaryActivity = .init(indicator: activityIndicator, error: errorIndicator)
        setupActivity()
        setupActionBindings()
        setupStateBindings()
        timerBindings()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

//        TODO: - how to solve this? if the property is type Error, it needs to be optional?
//        errorIndicator
//            .errors
//            .assign(to: &$error)
    }

    private func setupActionBindings() {

        action
            .useAction(action: .nextTap)
            .withUnretained(self)
            .filter { $0.0.currentState == .phoneInput }
            .flatMap { owner, _ in
                owner.userService.requestVerificationCode(phoneNumber: owner.phoneNumber)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap { $0.value }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.triggerCountdown.send(response.expirationDate)
            })
            .sink { owner, _ in
                owner.currentState = .codeInput
            }
            .store(in: cancelBag)

        let onCodeInput = action
            .useAction(action: .nextTap)
            .withUnretained(self)
            .filter { $0.0.currentState == .codeInput }

        Publishers.CombineLatest(onCodeInput, authenticationManager.phoneVerification)
            .compactMap { $0.1?.verificationId }
            .withUnretained(self)
            .filter { $0.0.currentState == .codeInput }
            .handleEvents(receiveOutput: { owner, _ in
                owner.currentState = .codeInputValidation
            })
            .flatMap { owner, verificationId -> AnyPublisher<CodeValidationResponse?, Never> in
                owner.userService.confirmValidationCode(id: verificationId,
                                                        code: owner.validationCode,
                                                        key: owner.authenticationManager.getPublicKey())
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .map { $0.value }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink { owner, response in
                guard response != nil else {
                    owner.currentState = .codeInput
                    return
                }

                owner.currentState = .codeInputSuccess
                owner.route.send(.continueTapped)
            }
            .store(in: cancelBag)

        action
            .useAction(action: .sendCode)
            .withUnretained(self)
            .sink { owner, _ in
                owner.createCountdown(with: UserService.temporal)
            }
            .store(in: cancelBag)
    }

    private func setupStateBindings() {
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
    }

    private func timerBindings() {
        timer?
            .withUnretained(self)
            .sink { owner, _ in
                owner.countdown -= 1
                if owner.countdown == 0 {
                    owner.timer?.connect().cancel()
                }
            }
            .store(in: cancelBag)

        triggerCountdown
            .withUnretained(self)
            .sink { owner, date in
                owner.createCountdown(with: date)
            }
            .store(in: cancelBag)
    }

    // MARK: - Helper methods

    private func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        !phoneNumber.isEmpty
    }

    private func validateCode(_ code: String) -> Bool {
        !code.isEmpty && code.count == 6
    }

    private func createCountdown(with expirationDate: Date?) {
        calculateCountdown(expirationDate: expirationDate)
        timer = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .default)
        _ = timer?.connect()

        timer?
            .withUnretained(self)
            .sink { owner, _ in
                owner.countdown -= 1
                if owner.countdown == 0 {
                    owner.timer?.connect().cancel()
                }
            }
            .store(in: cancelBag)
    }

    private func calculateCountdown(expirationDate: Date?) {
        guard let expirationDate = expirationDate else {
            countdown = -1
            return
        }

        countdown = Int(expirationDate.timeIntervalSinceNow)
    }
}
