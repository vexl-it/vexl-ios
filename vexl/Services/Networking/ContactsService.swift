//
//  ContactService.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine

typealias UserContacts = (phone: [ContactKey], facebook: [ContactKey])

protocol ContactsServiceType {
    func createUser(forFacebook isFacebook: Bool, firebaseToken: String?) -> AnyPublisher<Void, Error>
    func updateUser(token: String) -> AnyPublisher<Void, Error>
    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error>
    func removeContacts(_ contacts: [String], fromFacebook: Bool) -> AnyPublisher<Void, Error>
    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<ContactsAvailable, Error>
    func getActiveFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookUserData, Error>
    func getFacebookContacts(id: String, accessToken: String) -> AnyPublisher<FacebookUserData, Error>
    func getContacts(fromFacebook: Bool, friendLevel: ContactFriendLevel, pageLimit: Int?) -> AnyPublisher<[ContactKey], Error>
    func getAllContacts(friendLevel: ContactFriendLevel,
                        hasFacebookAccount: Bool,
                        pageLimit: Int?) -> AnyPublisher<UserContacts, Error>
    func deleteUser() -> AnyPublisher<Void, Error>
    func countPhoneContacts() -> AnyPublisher<Int, Error>

    func getCommonFriends(publicKeys: [String]) -> AnyPublisher<[String: [String]], Error>
}

final class ContactsService: BaseService, ContactsServiceType {

    func createUser(forFacebook isFacebook: Bool, firebaseToken: String?) -> AnyPublisher<Void, Error> {
        request(endpoint: ContactsRouter.createUser(token: firebaseToken, useFacebookHeader: isFacebook))
            .eraseToAnyPublisher()
    }

    func updateUser(token: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ContactsRouter.updateUser(token: token))
            .eraseToAnyPublisher()
    }

    func importContacts(_ contacts: [String]) -> AnyPublisher<ContactsImported, Error> {
        request(type: ContactsImported.self, endpoint: ContactsRouter.importContacts(contacts: contacts))
            .eraseToAnyPublisher()
    }

    func removeContacts(_ contacts: [String], fromFacebook: Bool) -> AnyPublisher<Void, Error> {
        request(endpoint: ContactsRouter.removeContacts(contacts: contacts, fromFacebook: fromFacebook))
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

    func getContacts(fromFacebook: Bool, friendLevel: ContactFriendLevel, pageLimit: Int?) -> AnyPublisher<[ContactKey], Error> {
        request(
            type: Paged<ContactKey>.self,
            endpoint: ContactsRouter.getContacts(
                useFacebookHeader: fromFacebook,
                friendLevel: friendLevel,
                pageLimit: pageLimit
            )
        )
        .map { pagedContacts in
            let pubKeys = Set(pagedContacts.items.map(\.publicKey))
            return pubKeys.map(ContactKey.init)
        }
        .eraseToAnyPublisher()
    }

    func getAllContacts(friendLevel: ContactFriendLevel,
                        hasFacebookAccount: Bool,
                        pageLimit: Int?) -> AnyPublisher<UserContacts, Error> {

        getContacts(fromFacebook: false, friendLevel: friendLevel, pageLimit: pageLimit)
            .eraseToAnyPublisher()
            .withUnretained(self)
            .flatMap { owner, contacts -> AnyPublisher<([ContactKey], [ContactKey]), Error> in
                if hasFacebookAccount {
                    return owner.getContacts(fromFacebook: true, friendLevel: friendLevel, pageLimit: pageLimit)
                        .map { (contacts, $0) }
                        .eraseToAnyPublisher()
                } else {
                    return Just((contacts, []))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .map { UserContacts(phone: $0.0, facebook: $0.1) }
            .eraseToAnyPublisher()
    }

    func deleteUser() -> AnyPublisher<Void, Error> {
        request(endpoint: ContactsRouter.deleteUser)
    }

    func countPhoneContacts() -> AnyPublisher<Int, Error> {
        request(type: ContactsCount.self, endpoint: ContactsRouter.countPhoneContacts)
            .map(\.count)
            .eraseToAnyPublisher()
    }

    func getCommonFriends(publicKeys: [String]) -> AnyPublisher<[String: [String]], Error> {
        request(type: CommonFriends.self, endpoint: ContactsRouter.getCommonFriends(publicKeys: publicKeys))
            .map(\.asDictionary)
            .eraseToAnyPublisher()
    }
}
