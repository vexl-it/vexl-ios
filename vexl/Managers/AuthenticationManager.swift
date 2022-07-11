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

protocol AuthenticationManagerType {
    var isUserLoggedIn: Bool { get }
    var isUserLoggedInPublisher: AnyPublisher<Bool, Never> { get }

    var userKeys: ECCKeys { get }
    var userHash: String? { get }
    var userSignature: String? { get }

    var securityHeader: SecurityHeader? { get }
    var facebookSecurityHeader: SecurityHeader? { get }

    func logoutUser(force: Bool)
    func logoutUserPublisher(force: Bool) -> AnyPublisher<Void, Never>
}
final class AuthenticationManager: AuthenticationManagerType {

    // MARK: - Properties

    var isUserLoggedIn: Bool { checkAuthorization(for: userRepository.user) }
    var isUserLoggedInPublisher: AnyPublisher<Bool, Never> {
        userRepository.userPublisher
            .map(checkAuthorization(for:))
            .eraseToAnyPublisher()
    }

    @Inject private var userRepository: UserRepositoryType
    @Inject private var facebookManager: FacebookManagerType

    var userKeys: ECCKeys {
        guard let pubK = userRepository.user?.profile?.publicKey?.publicKey,
              let privK = Keychain.standard[.privateKey(publicKey: pubK)] else {
            logoutUser(force: true)
            return ECCKeys()
        }
        return ECCKeys(pubKey: pubK, privKey: privK)
    }

    var userHash: String? {
        userRepository.user?.userHash
    }

    @KeychainStore(key: .userSignature)
    var userSignature: String?

    private let cancelBag: CancelBag = .init()

    // MARK: - Variables for user registration

    var securityHeader: SecurityHeader? {
        guard let hash = userHash, let signature = userSignature else {
            return nil
        }
        return SecurityHeader(
            hash: hash,
            publicKey: userKeys.publicKey,
            signature: signature
        )
    }

    var facebookSecurityHeader: SecurityHeader? {
        guard let hash = facebookManager.facebookHash,
              let signature = facebookManager.facebookSignature else {
            return nil
        }
        return SecurityHeader(
            hash: hash,
            publicKey: userKeys.publicKey,
            signature: signature
        )
    }

    private func checkAuthorization(for user: ManagedUser?) -> Bool {
        user != nil &&
        Keychain.standard[.userSignature] != nil &&
        user?.profile?.publicKey?.publicKey != nil &&
        user?.profile?.publicKey?.publicKey
            .flatMap { Keychain.standard[.privateKey(publicKey: $0)] } != nil
    }
}

// MARK: - Methods

extension AuthenticationManager {
    func logoutUserPublisher(force: Bool) -> AnyPublisher<Void, Never> {
        @Inject var userService: UserServiceType
        @Inject var contactService: ContactsServiceType
        @Inject var offerService: OfferServiceType
        @Inject var cryptocurrencyValueManager: CryptocurrencyValueManagerType
        @Inject var syncInboxManager: SyncInboxManagerType
        @Inject var persistanceManager: PersistenceStoreManagerType

        let serverPublishers: AnyPublisher<Void, Never> = {
                if !force {
                    return userService
                        .deleteUser()
                        .nilOnError()
                        .flatMap { _ in
                            contactService
                                .deleteUser()
                                .nilOnError()
                        }
                        .flatMap { _ in
                            offerService
                                .deleteOffers()
                                .nilOnError()
                        }
                        .asVoid()
                        .eraseToAnyPublisher()
                } else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
            }()

        return serverPublishers
            .handleEvents(receiveOutput: {
                cryptocurrencyValueManager.stopPollingCoinData()
                cryptocurrencyValueManager.stopFetchingChartData()
                syncInboxManager.stopSyncingInboxes()
            })
            .flatMap {
                persistanceManager
                    .wipe()
                    .nilOnError()
            }
            .asVoid()
            .eraseToAnyPublisher()
    }

    func logoutUser(force: Bool) {
        logoutUserPublisher(force: force)
            .sink()
            .store(in: cancelBag)
    }
}
