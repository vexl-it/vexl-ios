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

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?, phoneNumber: String) -> AnyPublisher<ManagedUser, Error>
    func getUser(for context: NSManagedObjectContext) -> ManagedUser?
    func update(username: String?, avatar: Data?, avatarURL: String?, anonymizedUsername: String?) -> AnyPublisher<ManagedUser, Error>
    func getInboxes() -> [ManagedInbox]
}

extension UserRepositoryType {
    func update(
        username: String? = nil,
        avatar: Data? = nil,
        avatarURL: String? = nil,
        anonymizedUsername: String? = nil
    ) -> AnyPublisher<ManagedUser, Error> {
        update(username: username, avatar: avatar, avatarURL: avatarURL, anonymizedUsername: anonymizedUsername)
    }
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

    func createNewUser(newKeys: ECCKeys, signature: String?, hash: String?, phoneNumber: String) -> AnyPublisher<ManagedUser, Error> {
        persistenceManager.insert(context: persistenceManager.newEditContext()) { context in

            let keyPair = ManagedKeyPair(context: context)
            let profile = ManagedProfile(context: context)
            let user = ManagedUser(context: context)
            let inbox = ManagedInbox(context: context)

            inbox.type = .created
            keyPair.publicKey = newKeys.publicKey
            keyPair.privateKey = newKeys.privateKey
            keyPair.inbox = inbox
            profile.keyPair = keyPair
            profile.phoneNumber = phoneNumber
            profile.phoneNumberHmac = try? phoneNumber.removeWhitespaces().hmac.hash(password: Constants.contactsHashingPassword)
            user.profile = profile
            user.userHash = hash
            user.signature = signature

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

    func update(username: String?, avatar: Data?, avatarURL: String?, anonymizedUsername: String?) -> AnyPublisher<ManagedUser, Error> {
        guard let user = user else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return persistenceManager.update(context: context) { [user] _ in
            if let username {
                user.profile?.name = username
            }
            if let avatarURL {
                user.profile?.avatarURL = avatarURL
            }
            if let avatar  {
                user.profile?.avatar = avatar
            }
            if let anonymizedUsername {
                user.profile?.anonymizedUsername = anonymizedUsername
            }
            return user
        }
    }

    func getInboxes() -> [ManagedInbox] {
        let offers = user?.offers?.allObjects as? [ManagedOffer] ?? []
        let offerInboxes = offers.compactMap(\.inbox)
        let userInbox = user?.profile?.keyPair?.inbox
        return offerInboxes + [userInbox].compactMap { $0 }
    }
}
