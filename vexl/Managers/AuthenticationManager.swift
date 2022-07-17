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
    var currentAuthenticationState: AuthenticationManager.AuthenticationState { get }
    var authenticationStatePublisher: AnyPublisher<AuthenticationManager.AuthenticationState, Never> { get }
    var updatedCurrentUser: AnyPublisher<User?, Never> { get }

    func setUser(_ user: User, withAvatar avatar: Data?)
    func updateUser(_ user: EditUser)
    func setFacebookUser(id: String?, token: String?)
    func logoutUser()
}

@available(*, deprecated)
protocol UserSecurityType {
    var userSecurity: UserSecurity { get set }
    var userKeys: ECCKeys { get }
    var userSignature: String? { get }
    var userHash: String? { get }
    var userFacebookHash: String? { get }
    var userFacebookSignature: String? { get }
    var securityHeader: SecurityHeader? { get }
    var facebookSecurityHeader: SecurityHeader? { get }

    func setUserSignature(_ userSignature: UserSignature)
    func setUserKeys(_ userKeys: ECCKeys)
    func setHash(_ challengeValidation: ChallengeValidation)
    func setFacebookSignature(_ facebookSignature: ChallengeValidation)
    func generateUserKey()
}

final class AuthenticationManager: AuthenticationManagerType, TokenHandlerType {

    enum AuthenticationState {
        case signedIn
        case signedOut
    }

    // MARK: - Properties

    @DidSet var authenticationState: AuthenticationState = .signedOut

    @Published private(set) var accessToken: String?
    @Published private(set) var refreshToken: String?

    var currentAuthenticationState: AuthenticationState {
        authenticationState
    }

    var authenticationStatePublisher: AnyPublisher<AuthenticationState, Never> {
        $authenticationState.eraseToAnyPublisher()
    }

    var updatedCurrentUser: AnyPublisher<User?, Never> {
        updateCurrentUser
            .eraseToAnyPublisher()
    }

    private let updateCurrentUser = PassthroughSubject<User?, Never>()
    private let cancelBag: CancelBag = .init()
    private let userDefaults: UserDefaults

    // MARK: - Variables for user registration

    var userSecurity: UserSecurity {
        get {
            guard let userSecurity: UserSecurity = Keychain.standard[codable: .userSecurity] else {
                let newUserSecurity: UserSecurity = .init()
                Keychain.standard[codable: .userSecurity] = newUserSecurity
                return newUserSecurity
            }
            return userSecurity
        }
        set { Keychain.standard[codable: .userSecurity] = newValue }
    }

    private(set) var currentUser: User?

    // MARK: - Initialization

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        authentication()
    }

    func setUser(_ user: User, withAvatar avatar: Data? = nil) {
        self.currentUser = user
        self.currentUser?.avatarImage = avatar
        saveUser()
    }

    func updateUser(_ user: EditUser) {
        var newUser = self.currentUser
        newUser?.username = user.username
        newUser?.avatarImage = user.avatar?.dataFromBase64
        self.currentUser = newUser
        saveUser()
        updateCurrentUser.send(newUser)
    }

    func setFacebookUser(id: String?, token: String?) {
        self.currentUser?.facebookId = id
        self.currentUser?.facebookToken = token
        saveUser()
    }

    // TODO: - Storing this in the UserDefaults is just a temporal solution for the PoC, later we should
    // discuss how to store the data in the device: CoreData, Encrypted Files, not Realm, etc.

    func saveUser() {
        userDefaults.set(value: currentUser, forKey: .storedUser)
        authenticationState = .signedIn
    }

    func saveSecurity() {
        userDefaults.set(value: userSecurity, forKey: .storedSecurity)
    }

    func authentication() {
        self.currentUser = userDefaults.codable(forKey: .storedUser)
        self.userSecurity = userDefaults.codable(forKey: .storedSecurity) ?? .init()

        authenticationState = currentUser == nil ? .signedOut : .signedIn
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
    var userKeys: ECCKeys {
        guard let keys = userSecurity.keys else {
            let newKeys = ECCKeys()
            setUserKeys(newKeys)
            return newKeys
        }
        return keys
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
        SecurityHeader(hash: userHash, publicKey: userKeys.publicKey, signature: userSignature)
    }
    var facebookSecurityHeader: SecurityHeader? {
        SecurityHeader(hash: userFacebookHash, publicKey: userKeys.publicKey, signature: userFacebookSignature)
    }

    func setUserSignature(_ userSignature: UserSignature) {
        self.userSecurity.signature = userSignature.signed
        saveSecurity()
    }

    func setUserKeys(_ userKeys: ECCKeys) {
        self.userSecurity.keys = userKeys
        saveSecurity()
    }

    func setHash(_ challengeValidation: ChallengeValidation) {
        self.userSecurity.hash = challengeValidation.hash
        self.userSecurity.signature = challengeValidation.signature
        saveSecurity()
    }

    func setFacebookSignature(_ facebookSignature: ChallengeValidation) {
        self.userSecurity.facebookSignature = facebookSignature.signature
        self.userSecurity.facebookHash = facebookSignature.hash
        saveSecurity()
    }

    func clearSecurity() {
        self.userSecurity.hash = nil
        self.userSecurity.signature = nil
        self.userSecurity.keys = nil
    }

    func generateUserKey() {
        let newKeys = ECCKeys()
        setUserKeys(newKeys)
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

        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject)
    }

    func logoutUser() {
        clearUser()
        authenticationState = .signedOut
    }
}
