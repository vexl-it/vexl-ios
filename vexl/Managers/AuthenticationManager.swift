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

    private(set) var phoneVerification: PhoneConfirmation?
    private(set) var codeConfirmation: CodeValidation?
    private(set) var userKeys: UserKeys?
    private(set) var userSignature: UserSignature?
    private(set) var challengeValidation: ChallengeValidation?
    private(set) var facebookSignature: FacebookUserSignature?

    private(set) var currentUser: User?

    var securityHeader: SecurityHeader? {
        guard let signature = challengeValidation?.signature,
              let publicKey = userKeys?.publicKey,
              let hash = challengeValidation?.hash else {
                  return nil
              }
        return SecurityHeader(hash: hash, publicKey: publicKey, signature: signature)
    }

    var facebookSecurityHeader: SecurityHeader? {
        guard let signature = facebookSignature?.signature,
              let publicKey = userKeys?.publicKey,
              let hash = facebookSignature?.hash else {
                  return nil
              }
        return SecurityHeader(hash: hash, publicKey: publicKey, signature: signature)
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

    func setUser(_ user: User) {
        self.currentUser = user
    }

    func setFacebookSignature(_ facebookSignature: FacebookUserSignature) {
        self.facebookSignature = facebookSignature
    }

    func setUserSignature(_ userSignature: UserSignature) {
        self.userSignature = userSignature
    }

    func setUserKeys(_ userKeys: UserKeys) {
        self.userKeys = userKeys
    }

    func clearPhoneVerification() {
        self.phoneVerification = nil
    }

    func setPhoneVerification(_ phoneVerification: PhoneConfirmation) {
        self.phoneVerification = phoneVerification
    }

    func setHash(_ challengeValidation: ChallengeValidation) {
        self.challengeValidation = challengeValidation
    }

    func clearHash() {
        self.challengeValidation = nil
    }

    func setCodeConfirmation(_ codeConfirmation: CodeValidation) {
        self.codeConfirmation = codeConfirmation
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
        currentUser = nil
        let userDefaults = UserDefaults.standard

        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject)
        userDefaults.synchronize()
    }

    func logoutUser() {
        clearUser()
        authenticationState = .signedOut
    }
}
