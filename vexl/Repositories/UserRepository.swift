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
    func getUser(for context: NSManagedObjectContext) -> ManagedUser?
    func update(with userResponse: User, avatar: Data?) -> AnyPublisher<ManagedUser, Error>
    func update(username: String, avatarURL: String?, avatar: Data?) -> AnyPublisher<Void, Error>
}

final class UserRepository: UserRepositoryType {

    // MARK: - Public properties

    var user: ManagedUser? { users.first }

    // MARK: - Computed variables

    var userPublisher: AnyPublisher<ManagedUser?, Never> {
        $users.publisher.map(\.objects.first).eraseToAnyPublisher()
    }

    // MARK: - Dependencies

    @Inject private var userMicroService: UserServiceType
    @Inject private var persistenceManager: PersistenceStoreManagerType

    // MARK: - Private properties

    @Fetched private var users: [ManagedUser]

    private var cancelBag: CancelBag = .init()
    private lazy var context: NSManagedObjectContext = persistenceManager.viewContext

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?) -> AnyPublisher<ManagedUser, Error> {
        persistenceManager.insert(context: persistenceManager.viewContext) { context in
            Keychain.standard[.privateKey(publicKey: newKeys.publicKey)] = newKeys.privateKey
            Keychain.standard[.userSignature] = signature

            let keyPair = ManagedKeyPair(context: context)
            let profile = ManagedProfile(context: context)
            let user = ManagedUser(context: context)
            let inbox = ManagedInbox(context: context)

            inbox.type = .created
            keyPair.publicKey = newKeys.publicKey
            keyPair.privateKey = newKeys.privateKey
            keyPair.inbox = inbox
            profile.keyPair = keyPair
            user.profile = profile
            user.userHash = hash

            return user
        }
        .eraseToAnyPublisher()
    }

    func getUser(for context: NSManagedObjectContext) -> ManagedUser? {
        guard let objId = user?.objectID else {
            return nil
        }
        return persistenceManager.loadSyncroniously(type: ManagedUser.self, context: context, objectID: objId)
    }

    func update(with userResponse: User, avatar: Data?) -> AnyPublisher<ManagedUser, Error> {
        guard let user = user else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return persistenceManager.update(context: context) { [user] _ in
            user.userId = Int64(userResponse.userId ?? 0)
            user.profile?.name = userResponse.username
            user.profile?.avatarURL = userResponse.avatarURL
            user.profile?.avatar = avatar
            return user
        }
    }

    func update(username: String, avatarURL: String?, avatar: Data?) -> AnyPublisher<Void, Error> {
        guard let user = user else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return persistenceManager.update(context: context) { [user] _ in
            user.profile?.name = username
            if avatar != nil {
                user.profile?.avatarURL = avatarURL
                user.profile?.avatar = avatar
            }
            return user
        }
        .asVoid()
        .eraseToAnyPublisher()
    }
}
