//
//  AuthenticationManager.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Combine
import KeychainAccess
import Cleevio

typealias BearerToken = String

protocol TokenHandlerType {
    var accessToken: BearerToken? { get }
    var refreshToken: BearerToken? { get }
}

final class AuthenticationManager: TokenHandlerType {
    enum AuthenticationState {
        case signedIn
        case signedOut
    }

    // MARK: - Properties

    @Published private(set) var authenticationState: AuthenticationState = .signedOut

    @Published private(set) var accessToken: String?
    @Published private(set) var refreshToken: String?

    private let cancelBag: CancelBag = .init()

    // MARK: - Variables for user registration

    private(set) var phoneVerification = CurrentValueSubject<PhoneConfirmationResponse?, Never>(nil)
    private(set) var codeConfirmation = CurrentValueSubject<CodeValidationResponse?, Never>(nil)
    private(set) var userKeys: UserKeys?

    // MARK: - Initialization

    init() {
        accessToken = Keychain.standard[.accessToken]
        refreshToken = Keychain.standard[.refreshToken]
        setupSubscription()
    }

    private func setupSubscription() {
        $accessToken
            .sink { accessToken in
                Keychain.standard[.accessToken] = accessToken
            }
            .store(in: cancelBag)

        $refreshToken
            .sink { refreshToken in
                Keychain.standard[.refreshToken] = refreshToken
            }
            .store(in: cancelBag)

        $accessToken
            .map { $0 ?? "" }
            .map { $0.isEmpty ? .signedOut : .signedIn }
            .assign(to: &$authenticationState)
    }
}

// MARK: - Methods

extension AuthenticationManager {

    func setUserKeys(_ userKeys: UserKeys) {
        self.userKeys = userKeys
    }

    func setPhoneVerification(_ phoneVerification: PhoneConfirmationResponse) {
        self.phoneVerification.send(phoneVerification)
    }

    func setCodeConfirmation(_ codeValidation: CodeValidationResponse) {
        self.codeConfirmation.send(codeValidation)
    }

    // MARK: - Base Authentication Methods

    func setAccessToken(token: String) {
        accessToken = token
    }

    func setRefreshToken(token: String) {
        refreshToken = token
    }

    private func clearUser() {
        accessToken = nil
        refreshToken = nil
        let userDefaults = UserDefaults.standard

        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject)
        userDefaults.synchronize()
    }

    func logoutUser() {
        clearUser()
        authenticationState = .signedOut
    }
}
