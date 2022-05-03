//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

protocol ContactsServiceType {
    func createUser(forFacebook isFacebook: Bool) -> AnyPublisher<Void, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error>
    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error>
    func getActiveFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookUserData, Error>
    func getFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookUserData, Error>
    func getContacts(fromFacebook: Bool, friendLevel: ContactFriendLevel, pageLimit: Int?) -> AnyPublisher<Paged<ContactKey>, Error>
}

final class ContactsService: BaseService, ContactsServiceType {

    func createUser(forFacebook isFacebook: Bool) -> AnyPublisher<Void, Error> {
        request(endpoint: ContactsRouter.createUser(useFacebookHeader: isFacebook))
            .eraseToAnyPublisher()
    }

    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error> {
        request(type: ContactsImported.self, endpoint: ContactsRouter.importContacts(contacts: contacts))
            .eraseToAnyPublisher()
    }

    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error> {
        request(type: ContactsAvailable.self, endpoint: ContactsRouter.getAvailableContacts(contacts: contacts))
            .eraseToAnyPublisher()
    }

    func getFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookUserData, Error> {
        request(type: FacebookUserData.self, endpoint: ContactsRouter.getFacebookContacts(id: id, accessToken: accessToken))
            .eraseToAnyPublisher()
    }

    func getActiveFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookUserData, Error> {
        request(type: FacebookUserData.self, endpoint: ContactsRouter.getAvailableFacebookContacts(id: id, accessToken: accessToken))
            .eraseToAnyPublisher()
    }

    func getContacts(fromFacebook: Bool, friendLevel: ContactFriendLevel, pageLimit: Int?) -> AnyPublisher<Paged<ContactKey>, Error> {
        request(type: Paged<ContactKey>.self,
                endpoint: ContactsRouter.getContacts(useFacebookHeader: fromFacebook,
                                                     friendLevel: friendLevel,
                                                     pageLimit: pageLimit))
            .eraseToAnyPublisher()
    }
}
