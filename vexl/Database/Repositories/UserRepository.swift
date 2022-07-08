//
//  UserRepository.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation
import Combine
import KeychainAccess
import Cleevio
import CoreData

protocol UserRepositoryType {
    var currentUser: CurrentValueSubject<ManagedUser?, Never> { get }
    var userKeys: ECCKeys { get }
    var userHash: String? { get }
    var userSignature: String? { get }

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?) -> AnyPublisher<ManagedUser, Error>
    func update(with userResponse: User, avatar: Data?) -> AnyPublisher<ManagedUser, Error>

    func logout()
}

final class UserRepository: UserRepositoryType {
    @Inject private var userMicroService: UserServiceType
    @Inject private var persistenceManager: PersistenceStoreManagerType

    var currentUser: CurrentValueSubject<ManagedUser?, Never> = .init(nil)

    private var cancelBag: CancelBag = .init()
    private lazy var context: NSManagedObjectContext = persistenceManager.viewContext

    var userKeys: ECCKeys {
        guard let pubK = currentUser.value?.profile?.publicKey?.publicKey,
              let privK = Keychain.standard[.privateKey(publicKey: pubK)] else {
            self.logout()
            return .init()
        }
        return ECCKeys(pubKey: pubK, privKey: privK)
    }

    var userHash: String? {
        currentUser.value?.userHash
    }

    var userSignature: String? {
        Keychain.standard[.userSignature]
    }

    init() {
        persistenceManager.load(type: ManagedUser.self, context: persistenceManager.viewContext)
            .catch { _ in Just([]) }
            .compactMap(\.first)
            .asOptional()
            .subscribe(currentUser)
            .store(in: cancelBag)
    }

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?) -> AnyPublisher<ManagedUser, Error> {
        persistenceManager.insert(context: persistenceManager.viewContext) { context in
            Keychain.standard[.privateKey(publicKey: newKeys.publicKey)] = newKeys.privateKey
            Keychain.standard[.userSignature] = signature

            let publicKey = ManagedPublicKey(context: context)
            let profile = ManagedProfile(context: context)
            let user = ManagedUser(context: context)

            publicKey.publicKey = newKeys.publicKey
            profile.publicKey = publicKey
            user.profile = profile
            user.userHash = hash

            return user
        }
        .handleEvents(receiveOutput: { [weak self] user in
            self?.currentUser.send(user)
        })
        .eraseToAnyPublisher()
    }

    func update(with userResponse: User, avatar: Data?) -> AnyPublisher<ManagedUser, Error> {
        guard let user = currentUser.value else {
            return Fail(error: PersistenceError.unknownUser)
                .eraseToAnyPublisher()
        }
        return persistenceManager.update(context: context) { [user] in

            user.userId = Int64(userResponse.userId)
            user.profile?.name = userResponse.username
            user.profile?.avatarURL = userResponse.avatarURL
            user.profile?.avatar = avatar

            return user
        }
    }

    func logout() {
        // TODO: logout
    }
}
