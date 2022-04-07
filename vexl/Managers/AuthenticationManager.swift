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

    private var phoneValidation: PhoneConfirmation = .init()
    private var userSecurity: UserSecurity = .init()

    var phoneConfirmation: PhoneVerification? {
        phoneValidation.phoneVerification
    }
    var codeValidation: CodeValidation? {
        phoneValidation.codeValidation
    }
    var userKeys: UserKeys? {
        userSecurity.keys
    }
    var userSignature: String? {
        userSecurity.signature
    }
    var userHash: String? {
        userSecurity.hash
    }

    var securityHeader: SecurityHeader? {
        SecurityHeader(hash: userSignature, publicKey: userKeys?.publicKey, signature: userHash)
    }

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

    func setUserSignature(_ userSignature: UserSignature) {
        self.userSecurity.signature = userSignature.signed
    }

    func setUserKeys(_ userKeys: UserKeys) {
        self.userSecurity.keys = userKeys
    }

    func clearPhoneVerification() {
        self.phoneValidation.phoneVerification = nil
    }

    func setPhoneConfirmation(_ phoneVerification: PhoneVerification) {
        self.phoneValidation.phoneVerification = phoneVerification
    }

    func setCodeValidation(_ codeValidation: CodeValidation) {
        self.phoneValidation.codeValidation = codeValidation
    }

    func setHash(_ challengeValidation: ChallengeValidation) {
        self.userSecurity.hash = challengeValidation.hash
        self.userSecurity.signature = challengeValidation.signature
    }

    func clearSecurity() {
        self.userSecurity.hash = nil
        self.userSecurity.signature = nil
        self.userSecurity.keys = nil
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
        clearSecurity()
        let userDefaults = UserDefaults.standard

        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject)
        userDefaults.synchronize()
    }

    func logoutUser() {
        clearUser()
        authenticationState = .signedOut
    }
}
