//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

struct FacebookContacts: Decodable {

    var facebookUser: FacebookUser

    struct FacebookUser: Decodable {
        var id: String
        var name: String
        var friends: [FacebookUser]
    }
}

protocol ContactsServiceType {
    func createUser(withPublicKey key: String, hash: String, forFacebook isFacebook: Bool) -> AnyPublisher<ContactUser, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error>
    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error>
    func getAvailableFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookContacts, Error>
    func getFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookContacts, Error>
}

class ContactsService: BaseService, ContactsServiceType {

    var contactsManager: ContactsManager

    init(contactsManager: ContactsManager) {
        self.contactsManager = contactsManager
    }

    func createUser(withPublicKey key: String, hash: String, forFacebook isFacebook: Bool) -> AnyPublisher<ContactUser, Error> {
        request(type: ContactUser.self, endpoint: ContactsRouter.createUser(key: key, hash: hash, useFacebookHeader: isFacebook))
            .withUnretained(self)
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error> {
        request(type: ContactsImported.self, endpoint: ContactsRouter.importContacts(contacts: contacts))
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

    func getFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookContacts, Error> {
        request(type: FacebookContacts.self, endpoint: ContactsRouter.getFacebookContacts(id: id, accessToken: accessToken))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.contactsManager.setFacebookFriendsWithApp(contacts: contacts.facebookUser.friends.map { $0.id })
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func getAvailableFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookContacts, Error> {
        request(type: FacebookContacts.self, endpoint: ContactsRouter.getAvailableFacebookContacts(id: id, accessToken: accessToken))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.contactsManager.setAvailable(facebookContacts: contacts.facebookUser.friends.map { $0.id })
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }
}
