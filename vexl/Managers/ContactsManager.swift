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
    var userPhoneContacts: [ContactInformation] { get set }

    func fetchPhoneContacts() -> [ContactInformation]
    func setAvailable(phoneContacts: [String])
}

final class ContactsManager: ContactsManagerType {

    // MARK: - Properties

    var userPhoneContacts: [ContactInformation] = []
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

    func setAvailable(phoneContacts: [String]) {
        let availableContacts = userPhoneContacts.filter { phoneContacts.contains($0.phone) }
        availablePhoneContacts = availableContacts
    }
}
