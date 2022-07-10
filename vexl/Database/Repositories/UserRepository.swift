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
    var userPublisher: AnyPublisher<ManagedUser?, Never> { get }
    var user: ManagedUser? { get }

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?) -> AnyPublisher<ManagedUser, Error>
    func update(with userResponse: User, avatar: Data?) -> AnyPublisher<ManagedUser, Error>
}

class UserRepository: UserRepositoryType {

    var user: ManagedUser? { users.first }

    var userPublisher: AnyPublisher<ManagedUser?, Never> {
        $users.map(\.first).eraseToAnyPublisher()
    }

    @Inject private var userMicroService: UserServiceType
    @Inject private var persistenceManager: PersistenceStoreManagerType

    @Fetched private var users: [ManagedUser]

    private var cancelBag: CancelBag = .init()
    private lazy var context: NSManagedObjectContext = persistenceManager.viewContext

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?) -> AnyPublisher<ManagedUser, Error> {
        persistenceManager.insert(context: persistenceManager.viewContext) { context in
            Keychain.standard[.privateKey(publicKey: newKeys.publicKey)] = newKeys.privateKey
            Keychain.standard[.userSignature] = signature

            let publicKey = ManagedPublicKey(context: context)
            let profile = ManagedProfile(context: context)
            let user = ManagedUser(context: context)
            let inbox = ManagedInbox(context: context)

            inbox.type = .created
            publicKey.publicKey = newKeys.publicKey
            publicKey.inbox = inbox
            profile.publicKey = publicKey
            user.profile = profile
            user.userHash = hash

            return user
        }
        .eraseToAnyPublisher()
    }

    func update(with userResponse: User, avatar: Data?) -> AnyPublisher<ManagedUser, Error> {
        guard let user = user else {
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
}
