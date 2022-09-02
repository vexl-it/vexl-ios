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
            .withUnretained(self)
            .map { $0.0.checkAuthorization(for: $0.1) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    @Inject private var userRepository: UserRepositoryType
    @Inject private var facebookManager: FacebookManagerType

    var userKeys: ECCKeys {
        let keyPair = userRepository.user?.profile?.keyPair
        guard let pubK = keyPair?.publicKey, let privK = keyPair?.privateKey else {
            logoutUser(force: true)
            return ECCKeys()
        }
        return ECCKeys(pubKey: pubK, privKey: privK)
    }

    var userHash: String? {
        userRepository.user?.userHash
    }

    var userSignature: String? {
        userRepository.user?.signature
    }

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
        userSignature != nil &&
        user?.profile?.keyPair?.publicKey != nil &&
        user?.profile?.keyPair?.privateKey != nil &&
        user?.profile?.name != nil
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
                        .flatMap { [contactService] _ in
                            contactService
                                .deleteUser()
                                .justOnError()
                                .eraseToAnyPublisher()
                        }
                        .flatMap { [persistanceManager] _ -> AnyPublisher<Void, Never> in
                            let offers = persistanceManager.loadSyncroniously(
                                type: ManagedOffer.self,
                                context: persistanceManager.viewContext,
                                predicate: NSPredicate(format: "user != nil")
                            )
                            return offerService
                                .deleteOffers(adminIDs: offers.compactMap(\.adminID))
                                .justOnError()
                                .eraseToAnyPublisher()
                        }
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
                try? Keychain.standard.removeAll()
                UserDefaultsConfig.hasSeenOnboarding = false
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
