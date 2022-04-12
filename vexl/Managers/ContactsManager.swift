//
//  ContactsManager.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine
import Contacts

protocol ContactsManagerType {
    var availablePhoneContacts: [ContactInformation] { get }

    func fetchPhoneContacts() -> [ContactInformation]
    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error>
}

final class ContactsManager: ContactsManagerType {

    @Inject var contactsService: ContactsServiceType

    // MARK: - Properties

    private var userPhoneContacts: [ContactInformation] = []
    private(set) var availablePhoneContacts: [ContactInformation] = []

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

    func getActivePhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error> {
        contactsService
            .getAvailableContacts(contacts)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, contacts in
                let availableContacts = owner.userPhoneContacts.filter { contacts.newContacts.contains($0.phone) }
                owner.availablePhoneContacts = availableContacts
            })
            .map { $0.0.availablePhoneContacts }
            .eraseToAnyPublisher()
    }
}
