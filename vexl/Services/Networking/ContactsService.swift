//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

struct ContactUser: Codable { }

struct ContactsImport: Codable { }

struct ContactsAvailable: Codable { }

protocol ContactsServiceType {
    func createUser(with key: String, hash: String) -> AnyPublisher<ContactUser, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImport, Error>
    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error>
}

class ContactsService: BaseService, ContactsServiceType {

    var contactsManager: ContactsManager

    init(contactsManager: ContactsManager) {
        self.contactsManager = contactsManager
    }

    func createUser(with key: String, hash: String) -> AnyPublisher<ContactUser, Error> {
        request(type: ContactUser.self, endpoint: ContactsRouter.createUser(key: key, hash: hash))
            .eraseToAnyPublisher()
    }

    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImport, Error> {
        request(type: ContactsImport.self, endpoint: ContactsRouter.importContacts(contacts: contacts))
            .eraseToAnyPublisher()
    }

    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error> {
        request(type: ContactsAvailable.self, endpoint: ContactsRouter.getAvailableContacts(contacts: contacts))
            .eraseToAnyPublisher()
    }
}
