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
    var availablePhoneContacts: [ContactInformation] { get }
    var availableFacebookContacts: [ContactInformation] { get }

    func fetchPhoneContacts() -> [ContactInformation]
    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error>

    func fetchFacebookContacts(id: String, accessToken: String) -> AnyPublisher<[ContactInformation], Error>
    func getActiveFacebookContacts(_ contacts: [String], withId id: String, token: String) -> AnyPublisher<[ContactInformation], Error>
    func hashPhoneContacts(_ availableContacts: [String]) -> AnyPublisher<[String], Error>
}

final class ContactsManager: ContactsManagerType {

    @Inject var contactsService: ContactsServiceType
    @Inject var cryptoService: CryptoServiceType

    // MARK: - Properties

    private var userPhoneContacts: [ContactInformation] = []
    private(set) var availablePhoneContacts: [ContactInformation] = []

    private var userFacebookContacts: [ContactInformation] = []
    private(set) var availableFacebookContacts: [ContactInformation] = []

    func fetchPhoneContacts() -> [ContactInformation] {
        var contacts = [ContactInformation]()
        let keys = [CNContactPhoneNumbersKey,
                    CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactImageDataKey,
                    CNContactIdentifierKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        let contactStore = CNContactStore()

        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
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
            .withUnretained(self)
            .flatMap { owner, hashedAvailableContacts -> AnyPublisher<([String], [String]), Error> in
                let userContacts = owner.userPhoneContacts.map(\.sourceIdentifier)
                return owner.hashPhoneContacts(userContacts)
                    .map { (hashedAvailableContacts.newContacts, $0) }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                owner.availablePhoneContacts = []
                let (hashedAvailableContacts, hashedUserContacts) = contacts
                for (index, contact) in hashedUserContacts.enumerated() {
                    if hashedAvailableContacts.contains(contact) {
                        owner.availablePhoneContacts.append(owner.userPhoneContacts[index])
                    }
                }
            })
            .map(\.0.availablePhoneContacts)
            .eraseToAnyPublisher()
    }

    func hashPhoneContacts(_ availableContacts: [String]) -> AnyPublisher<[String], Error> {
        let phoneNumber = Formatters.phoneNumberFormatter
        let countryCode = phoneNumber.countryCode(for: Locale.current.regionCode ?? "")

        let trimmedIdentifiers = availableContacts.map { identifier -> String in
            let trimmedIdentifier = identifier.removeWhitespaces()
            if let countryCode = countryCode, !trimmedIdentifier.contains("+") {
                return "\(countryCode)\(trimmedIdentifier)"
            }
            return trimmedIdentifier
        }

        return trimmedIdentifiers.publisher
            .withUnretained(self)
            .flatMap { owner, contact in
                owner.cryptoService
                    .hashHMAC(password: Constants.contactsHashingPassword, message: contact)
                    .eraseToAnyPublisher()
            }
            .collect()
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
