//
//  ContactsManager.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine
import Contacts
import FBSDKCoreKit
import FBSDKLoginKit

protocol ContactsManagerType {
    var availableFacebookContacts: [ContactInformation] { get }

    func fetchPhoneContacts() -> AnyPublisher<[ContactInformation], Never>
    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error>

    func fetchFacebookContacts(id: String, accessToken: String) -> AnyPublisher<[ContactInformation], Error>
    func getActiveFacebookContacts(_ contacts: [String], withId id: String, token: String) -> AnyPublisher<[ContactInformation], Error>
}

final class ContactsManager: ContactsManagerType {

    @Inject var contactsService: ContactsServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var encryptionService: EncryptionServiceType
    @Inject var userRepository: UserRepositoryType

    // MARK: - Properties

    private var userPhoneContacts: [ContactInformation] = []

    private var userFacebookContacts: [ContactInformation] = []
    private(set) var availableFacebookContacts: [ContactInformation] = []

    func fetchPhoneContacts() -> AnyPublisher<[ContactInformation], Never> {
        userRepository.userPublisher
            .compactMap { $0?.profile?.phoneNumber?.removeWhitespaces() }
            .first()
            .withUnretained(self)
            .map { owner, userPhone in
                owner.fetchContactsButFilter(userPhone: userPhone)
            }
            .eraseToAnyPublisher()
    }

    private func fetchContactsButFilter(userPhone: String) -> [ContactInformation] {
        var contacts: [ContactInformation] = []
        let keys = [
            CNContactPhoneNumbersKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactImageDataKey,
            CNContactIdentifierKey
        ] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        let contactStore = CNContactStore()

        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                guard let phone = contact.phoneNumbers.first?.value.stringValue, !userPhone.contains(phone.removeWhitespaces()) else {
                    return
                }

                let avatar = contact.imageData
                let userContact = ContactInformation(id: contact.identifier,
                                                     name: "\(contact.givenName) \(contact.familyName)",
                                                     phone: phone,
                                                     avatar: avatar,
                                                     source: .phone)
                contacts.append(userContact)
            }
            self.userPhoneContacts = contacts
            return contacts
        } catch {
            self.userPhoneContacts = []
            return []
        }
    }

    func fetchFacebookContacts(id: String, accessToken: String) -> AnyPublisher<[ContactInformation], Error> {
        contactsService
            .getFacebookContacts(id: id, accessToken: accessToken)
            .map { contacts in
                contacts.facebookUser.friends.map { user in
                    ContactInformation(id: user.id,
                                       name: user.name,
                                       phone: "",
                                       avatarURL: user.profilePicture?.data?.url,
                                       source: .facebook)
                }
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.userFacebookContacts = contacts
            })
            .map(\.1)
            .eraseToAnyPublisher()
    }

    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error> {
        contactsService
            .getActivePhoneContacts(contacts)
            .map(\.newContacts)
            .withUnretained(self)
            .flatMap { owner, hashedAvailableContacts -> AnyPublisher<[ContactInformation], Error> in
                owner.encryptionService.hashContacts(contacts: owner.userPhoneContacts)
                    .map { hashedContacts in
                        hashedContacts
                            .filter { hashedAvailableContacts.contains($0.1) }
                            .map { $0.0 }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getActiveFacebookContacts(_ contacts: [String], withId id: String, token: String) -> AnyPublisher<[ContactInformation], Error> {
        contactsService
            .getActiveFacebookContacts(id: id, accessToken: token)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                let friends = contacts.facebookUser.friends.map { $0.id }
                owner.availableFacebookContacts = owner.userFacebookContacts.filter { friends.contains($0.sourceIdentifier) }
            })
            .map(\.0.availableFacebookContacts)
            .eraseToAnyPublisher()
    }
}
