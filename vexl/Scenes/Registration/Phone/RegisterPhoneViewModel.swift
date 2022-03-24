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
        case sendPhoneNumber
        case validateCode
        case sendCode
    }

    let action: ActionSubject<UserAction> = .init()
    private let triggerCountdown: ActionSubject<Date?>  = .init()
    private let temporalGenerateSignature: ActionSubject<String> = .init()

    // MARK: - View Bindings

    @Published var phoneNumber = ""
    @Published var validationCode = ""
    @Published var isActionEnabled = false
    @Published var currentState = ViewState.phoneInput

    @Published var loading = false
    @Published var error: Error?

    @Published var countdown = 0

    // MARK: - Activities

    var primaryActivity: Activity = .init()
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

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
        setupActivity()
        setupActionBindings()
        setupStateBindings()
        timerBindings()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    // swiftlint:disable function_body_length
    private func setupActionBindings() {

        let phoneInput = action
            .useAction(action: .sendPhoneNumber)
            .withUnretained(self)

        let sendCode = action
            .useAction(action: .sendCode)
            .withUnretained(self)
            .filter { $0.0.currentState == .codeInput }

        Publishers.Merge(phoneInput, sendCode)
            .flatMap { owner, _ in
                // TODO: - temporal remove/replace when C library is available
                owner.userService.generateKeys()
                    .track(activity: owner.primaryActivity)
                    .materializeIgnoreCompleted()
            }
            .withUnretained(self)
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

        let validateCode = action
            .useAction(action: .validateCode)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.currentState = .codeInputValidation
            })
            .compactMap { owner, _ in
                guard let verificationId = owner.authenticationManager.phoneVerification?.verificationId else { return nil }
                return verificationId
            }
            .withUnretained(self)
            .flatMap { owner, verificationId in
                owner
                    .userService
                    .confirmValidationCode(id: verificationId,
                                           code: owner.validationCode,
                                           key: owner.authenticationManager.userKeys?.publicKey ?? "")
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let updateAfterCodeValidation = validateCode
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if response.value == nil && owner.currentState == .codeInputValidation {
                    owner.currentState = .codeInput
                }
            })
            .compactMap { $0.1.value }
            .eraseToAnyPublisher()

        updateAfterCodeValidation
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.temporalGenerateSignature.send(response.challenge)
                owner.currentState = response.phoneVerified ? .codeInputSuccess : .codeInput
            })
            .filter { $0.0.currentState == .codeInputSuccess }
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .sink { owner, _ in
                owner.route.send(.continueTapped)
                owner.clearState()
            }
            .store(in: cancelBag)

        // Temporal delete me
        temporalGenerateSignature
            .withUnretained(self)
            .flatMap { owner, challenge in
                owner
                    .userService
                    .generateSignature(challenge: challenge,
                                       privateKey: owner.authenticationManager.userKeys?.privateKey ?? "")
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap { $0.value }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0.signed }
            .withUnretained(self)
            .flatMap { owner, signature in
                owner
                    .userService
                    .validateChallenge(key: owner.authenticationManager.userKeys?.publicKey ?? "",
                                       signature: signature)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
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

    private func clearState() {
        phoneNumber = ""
        validationCode = ""
        currentState = .phoneInput
        authenticationManager.clearPhoneVerification()
        timer?.connect().cancel()
    }
}
