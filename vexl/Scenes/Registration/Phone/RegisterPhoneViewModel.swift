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
    @Inject var userRepository: UserRepositoryType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var contactsService: ContactsServiceType

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
    private var codeInputSuccess: AnyPublisher<CodeValidation, Never>!

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
        case backTapped
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

    private var phoneVerificationId: Int?

    // MARK: - Timer

    private let cancelBag: CancelBag = .init()
    private var timer: Timer.TimerPublisher?
    private let newKeys: ECCKeys = .init() // Generates new pair of keys

    init() {
        setupActivity()
        setupPhoneInputActionBindings()
        setupValidationActionBindings()
        setupChallengeActionBindings()
        setupStateBindings()
        timerBindings()
    }

    func updateToPreviousState() {
        switch currentState {
        case .phoneInput:
            route.send(.backTapped)
        case .codeInput:
            clearState()
        case .codeInputValidation, .codeInputSuccess:
            break
        }
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

    private func setupPhoneInputActionBindings() {

        let phoneInput = action
            .filter { $0 == .sendPhoneNumber }
            .withUnretained(self)

        let sendCode = action
            .filter { $0 == .sendCode }
            .withUnretained(self)
            .filter { $0.0.currentState == .codeInput }

        Publishers.Merge(phoneInput, sendCode)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner
                    .userService
                    .requestVerificationCode(phoneNumber: owner.phoneNumber)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.triggerCountdown.send(response.expirationDate)
            })
            .sink { owner, response in
                owner.phoneVerificationId = response.verificationId
                owner.currentState = .codeInput
            }
            .store(in: cancelBag)
    }

    private func setupValidationActionBindings() {
        let validateCode: AnyPublisher<Int, Never> = action
            .filter { $0 == .validateCode }
            .withUnretained(self)
            .filter { $0.0.currentState == .codeInput }
            .handleEvents(receiveOutput: { owner, _ in
                owner.currentState = .codeInputValidation
            })
            .compactMap { owner, _ in
                owner.phoneVerificationId
            }
            .eraseToAnyPublisher()

        let verificationID: AnyPublisher<CodeValidation?, Never> = validateCode
            .withUnretained(self)
            .flatMap { owner, verificationId in
                owner
                    .userService
                    .confirmValidationCode(
                        id: verificationId,
                        code: owner.validationCode,
                        key: owner.newKeys.publicKey
                    )
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .map(\.value)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let updateAfterCodeValidation: AnyPublisher<CodeValidation, Never> = verificationID
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, validation in
                if validation == nil && owner.currentState == .codeInputValidation {
                    owner.currentState = .codeInput
                }
            })
            .compactMap(\.1)
            .eraseToAnyPublisher()

        codeInputSuccess = updateAfterCodeValidation
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if !response.phoneVerified {
                    owner.error = RegistryError.invalidValidationCode
                }
            })
            .map(\.1)
            .filter(\.phoneVerified)
            .eraseToAnyPublisher()
    }

    // swiftlint:disable:next function_body_length
    private func setupChallengeActionBindings() {
        let resolveChallenge: AnyPublisher<ChallengeValidation, Never> = codeInputSuccess
            .withUnretained(self)
            .flatMap { owner, response in
                owner.cryptoService
                    .signECDSA(keys: owner.newKeys, message: response.challenge)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap { $0.value }
            }
            .withUnretained(self)
            .flatMap { owner, signature in
                owner
                    .userService
                    .validateChallenge(key: owner.newKeys.publicKey, signature: signature)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap { $0.value }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if !response.challengeVerified {
                    owner.error = RegistryError.invalidChallenge
                } else {
                    owner.currentState = .codeInputSuccess
                }
            })
            .map(\.1)
            .share()
            .eraseToAnyPublisher()

        let challengeSuccess = resolveChallenge
            .filter(\.challengeVerified)
            .eraseToAnyPublisher()

        resolveChallenge
            .filter { !$0.challengeVerified }
            .sink { _ in
                // TODO: Handle failed challenge
            }
            .store(in: cancelBag)

        let createUser = challengeSuccess
            .withUnretained(self)
            .flatMap { owner, response in
                owner.userRepository
                    .createNewUser(newKeys: owner.newKeys, signature: response.signature, hash: response.hash)
                    .asVoid()
                    .materialize()
                    .track(activity: owner.primaryActivity)
                    .compactMap(\.value)
                    .receive(on: RunLoop.main)
            }

        let zip = Publishers.Zip(createUser, userRepository.userPublisher.filterNil().receive(on: RunLoop.main))

        let createUserBE = zip
            .flatMapLatest(with: self) { owner, _ in
                owner.contactsService
                    .createUser(forFacebook: false)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }

        let createInbox = createUserBE
            .flatMapLatest(with: self) { owner, _ in
                owner.chatService
                    .createInbox(publicKey: owner.newKeys.publicKey,
                                 pushToken: Constants.pushNotificationToken)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }

        createInbox
            .asVoid()
            .withUnretained(self)
            .sink { owner in
                owner.route.send(.continueTapped)
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
        triggerCountdown
            .withUnretained(self)
            .sink { owner, date in
                owner.createCountdown(with: date)
            }
            .store(in: cancelBag)
    }

    // MARK: - Helper methods

    private func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let parsedPhoneNumber = try? Formatters.phoneNumberFormatter.parse(phoneNumber)
        return !phoneNumber.isEmpty && parsedPhoneNumber != nil
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
        phoneVerificationId = nil
        timer?.connect().cancel()
    }
}
