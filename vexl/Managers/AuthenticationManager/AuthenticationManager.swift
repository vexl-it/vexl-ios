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
import FBSDKLoginKit
import FBSDKCoreKit

typealias BearerToken = String

protocol TokenHandlerType {
    var accessToken: BearerToken? { get }
    var refreshToken: BearerToken? { get }
}

protocol AuthenticationManagerType {
    var currentUser: User? { get }

    func logoutUser()
}

protocol UserSecurityType {

    var userSecurity: UserSecurity { get set }
    var userKeys: UserKeys? { get }
    var userSignature: String? { get }
    var userHash: String? { get }
    var userFacebookHash: String? { get }
    var userFacebookSignature: String? { get }
    var securityHeader: SecurityHeader? { get }
    var facebookSecurityHeader: SecurityHeader? { get }

    func setUserSignature(_ userSignature: UserSignature)
    func setUserKeys(_ userKeys: UserKeys)
    func setHash(_ challengeValidation: ChallengeValidation)
    func setFacebookUser(id: String?, token: String?)
    func setFacebookSignature(_ facebookSignature: ChallengeValidation)
}

final class AuthenticationManager: AuthenticationManagerType, TokenHandlerType {
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

    var userSecurity: UserSecurity = .init()
    private(set) var currentUser: User?

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

    func setUser(_ user: User) {
        self.currentUser = user
    }
}

// MARK: - Facebook

extension AuthenticationManager {

    func loginWithFacebook(fromViewController viewController: UIViewController? = nil) -> AnyPublisher<String?, Error> {
        Future { promise in
            let loginManager = LoginManager()
            loginManager.logIn(permissions: [.publicProfile, .userFriends], viewController: nil) { [weak self] result in
                switch result {
                case .cancelled:
                    promise(.success(nil))
                case let .failed(error):
                    promise(.failure(error))
                case let .success(_, _, token):
                    self?.setFacebookUser(id: token?.userID, token: token?.tokenString)
                    promise(.success(token?.userID))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - User Security properties

extension AuthenticationManager: UserSecurityType {
    var userKeys: UserKeys? {
        userSecurity.keys
    }
    var userSignature: String? {
        userSecurity.signature
    }
    var userHash: String? {
        userSecurity.hash
    }

    var userFacebookHash: String? {
        userSecurity.facebookHash
    }
    var userFacebookSignature: String? {
        userSecurity.facebookSignature
    }

    var securityHeader: SecurityHeader? {
        SecurityHeader(hash: userHash, publicKey: userKeys?.publicKey, signature: userSignature)
    }
    var facebookSecurityHeader: SecurityHeader? {
        SecurityHeader(hash: userFacebookHash, publicKey: userKeys?.publicKey, signature: userFacebookSignature)
    }

    func setUserSignature(_ userSignature: UserSignature) {
        self.userSecurity.signature = userSignature.signed
    }

    func setUserKeys(_ userKeys: UserKeys) {
        self.userSecurity.keys = userKeys
    }

    func setHash(_ challengeValidation: ChallengeValidation) {
        self.userSecurity.hash = challengeValidation.hash
        self.userSecurity.signature = challengeValidation.signature
    }

    func setFacebookUser(id: String?, token: String?) {
        self.currentUser?.facebookId = id
        self.currentUser?.facebookToken = token
    }

    func setFacebookSignature(_ facebookSignature: ChallengeValidation) {
        self.userSecurity.facebookSignature = facebookSignature.signature
        self.userSecurity.facebookHash = facebookSignature.hash
    }

    func clearSecurity() {
        self.userSecurity.hash = nil
        self.userSecurity.signature = nil
        self.userSecurity.keys = nil
    }
}

// MARK: - Methods

extension AuthenticationManager {

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
