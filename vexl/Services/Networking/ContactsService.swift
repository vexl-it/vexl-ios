//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

struct ContactUser: Decodable {
    var id: Int
    var publicKey: String
    var hash: String
}

struct ContactsImport: Decodable {
    var imported: Bool
    var message: String
}

struct ContactsAvailable: Decodable {
    var newContacts: [String]
}

struct FacebookContacts: Decodable {

    var facebookUser: FacebookUser

    struct FacebookUser: Decodable {
        var id: String
        var name: String
        var friends: [String]
    }
}

protocol ContactsServiceType {
    func createUser(withPublicKey key: String, hash: String) -> AnyPublisher<ContactUser, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImport, Error>
    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error>
    func getAvailableFacebookContacts() -> AnyPublisher<FacebookContacts, Error>
    func getFacebookContacts() -> AnyPublisher<FacebookContacts, Error>
}

class ContactsService: BaseService, ContactsServiceType {

    var contactsManager: ContactsManager

    init(contactsManager: ContactsManager) {
        self.contactsManager = contactsManager
    }

    func createUser(withPublicKey key: String, hash: String) -> AnyPublisher<ContactUser, Error> {
        request(type: ContactUser.self, endpoint: ContactsRouter.createUser(key: key, hash: hash))
            .withUnretained(self)
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImport, Error> {
        request(type: ContactsImport.self, endpoint: ContactsRouter.importContacts(contacts: contacts))
            .eraseToAnyPublisher()
    }

    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error> {
        request(type: ContactsAvailable.self, endpoint: ContactsRouter.getAvailableContacts(contacts: contacts))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.contactsManager.setAvailable(phoneContacts: contacts.newContacts)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func getFacebookContacts() -> AnyPublisher<FacebookContacts, Error> {
        AnyPublisher<FacebookContacts, Error>(Future { promise in
            after(2) {
                promise(.success(.init(facebookUser: .init(id: "1", name: "2", friends: []))))
            }
        })
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.contactsManager.setFacebookFriendsWithApp(contacts: contacts.facebookUser.friends)
        })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func getAvailableFacebookContacts() -> AnyPublisher<FacebookContacts, Error> {
        AnyPublisher(Future { promise in
            after(2) {
                promise(.success(.init(facebookUser: .init(id: "1", name: "2", friends: []))))
            }
        })
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.contactsManager.setAvailable(facebookContacts: contacts.facebookUser.friends)
        })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }
}
