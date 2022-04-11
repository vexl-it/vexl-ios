//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

protocol ContactsServiceType {
    func createUser() -> AnyPublisher<Void, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error>
    func getAvailableContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error>
}

class ContactsService: BaseService, ContactsServiceType {

    var contactsManager: ContactsManagerType

    init(contactsManager: ContactsManagerType) {
        self.contactsManager = contactsManager
    }

    func createUser() -> AnyPublisher<Void, Error> {
        request(endpoint: ContactsRouter.createUser)
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
}
