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
import PhoneNumberKit
import KeychainAccess

final class RegisterPhoneViewModel: ViewModelType {

    // MARK: - Property Injection

    @Inject var userService: UserServiceType
    @Inject var userRepository: UserRepositoryType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var contactsService: ContactsServiceType
    @Inject var notificationManager: NotificationManagerType

    @KeychainStore(key: .userCountryCode)
    private var userCountryCode: String?
    private var phoneRegistrationData: PhoneRegistrationData?

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

    var phoneSubtitle: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: L.registerPhoneCodeInputSubtitle(""),
                                                         attributes: [.font: Appearance.TextStyle.description.font,
                                                                      .foregroundColor: UIColor(Appearance.Colors.gray3)])
        attributedString.append(NSAttributedString(string: phoneNumber,
                                                   attributes: [.font: Appearance.TextStyle.descriptionSemiBold.font,
                                                                .foregroundColor: UIColor(Appearance.Colors.black1)]))
        return attributedString
    }

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

    private var parsedPhoneNumber: PhoneNumber? {
        try? Formatters.phoneNumberFormatter.parse(phoneNumber)
    }

    var currentRegionCode: String {
        guard let region = parsedPhoneNumber?.regionID else {
            return Locale.current.regionCode ?? ""
        }
        return "\(region)"
    }
    var currentPhoneNumber: String {
        guard let number = parsedPhoneNumber?.nationalNumber else {
            return ""
        }
        return "\(number)"
    }
    var shouldRequestVerificationCode: Bool {
        guard let verification = currentPhoneVerification else { return true }
        return verification.expirationDate?.compare(Date()) == .orderedAscending
    }
    var currentPhoneVerification: PhoneVerification? {
        phoneRegistrationData?.getVerification(forPhone: phoneNumber)
    }

    // MARK: - Timer

    private let cancelBag: CancelBag = .init()
    private var timer: Timer.TimerPublisher?
    private let newKeys: ECCKeys = .init() // Generates new pair of keys

    init() {
        setupKeychain()
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

    private func setupKeychain() {
        let keychainContent: PhoneRegistrationData? = Keychain.standard[codable: .phoneRegistration]
        if keychainContent == nil {
            Keychain.standard[codable: .phoneRegistration] = PhoneRegistrationData()
        }
        phoneRegistrationData = Keychain.standard[codable: .phoneRegistration]
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
            .flatMap { owner, _ -> AnyPublisher<PhoneVerification, Never> in
                if let verification = owner.currentPhoneVerification, !owner.shouldRequestVerificationCode {
                    return Just(verification)
                        .eraseToAnyPublisher()
                } else {
                    return owner.userService
                        .requestVerificationCode(phoneNumber: owner.phoneNumber)
                        .track(activity: owner.primaryActivity)
                        .materialize()
                        .compactMap(\.value)
                        .eraseToAnyPublisher()
                }
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.triggerCountdown.send(response.expirationDate)
            })
            .sink { owner, response in
                owner.phoneRegistrationData?.add(phone: owner.phoneNumber, verification: response)
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
                owner.currentPhoneVerification?.verificationId
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
                    .createNewUser(newKeys: owner.newKeys, signature: response.signature, hash: response.hash, phoneNumber: owner.phoneNumber)
                    .asVoid()
                    .materialize()
                    .track(activity: owner.primaryActivity)
                    .compactMap(\.value)
                    .receive(on: RunLoop.main)
            }

        let zip = Publishers.Zip(createUser, userRepository.userPublisher.filterNil().receive(on: RunLoop.main))

        let notificationToken = zip
            .flatMap { [notificationManager] _ in
                notificationManager.isRegisteredForNotifications
                    .flatMap { isRegistered -> AnyPublisher<String?, Never> in
                        guard isRegistered else {
                            return Just(nil)
                                .eraseToAnyPublisher()
                        }
                        return notificationManager.notificationToken
                            .asOptional()
                            .eraseToAnyPublisher()
                    }
            }

        let createUserBE = notificationToken
            .flatMapLatest(with: self) { owner, token in
                owner.contactsService
                    .createUser(forFacebook: false, firebaseToken: token)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { _ in token }
                    .eraseToAnyPublisher()
            }

        let createInbox = createUserBE
            .flatMapLatest(with: self) { owner, token in
                owner.chatService
                    .createInbox(eccKeys: owner.newKeys, pushToken: token)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }

        createInbox
            .asVoid()
            .withUnretained(self)
            .sink { owner in
                owner.userCountryCode = owner.getUserCountryCode()
                owner.phoneRegistrationData?.removeAll()
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

    private func getUserCountryCode() -> String? {
        guard let phoneNumber = try? Formatters.phoneNumberFormatter.parse(currentPhoneNumber),
                let region = phoneNumber.regionID,
                let countryCode = Formatters.phoneNumberFormatter.countryCode(for: region) else {
            return nil
        }
        return "+\(countryCode)"
    }

    private func clearState() {
        validationCode = ""
        currentState = .phoneInput
        timer?.connect().cancel()
    }
}
