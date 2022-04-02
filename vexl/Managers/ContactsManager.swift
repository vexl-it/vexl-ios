//
//  ContactsManager.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine
import Contacts

struct ImportContactItem: Identifiable {
    var id: String
    var name: String
    var phone: String
    var avatar: Data?
    var isSelected = false

    static func stub() -> [ImportContactItem] {
        [
            ImportContactItem(id: "1", name: "Diego Espinoza 1", phone: "999 944 222", avatar: nil),
            ImportContactItem(id: "2", name: "Diego Espinoza 2", phone: "929 944 222", avatar: nil),
            ImportContactItem(id: "3", name: "Diego Espinoza 3", phone: "969 944 222", avatar: nil),
            ImportContactItem(id: "4", name: "Diego Espinoza 4", phone: "969 944 222", avatar: nil),
            ImportContactItem(id: "5", name: "Diego Test 4", phone: "969 944 222", avatar: nil)
        ]
    }
}

final class ContactsManager {

    // MARK: - Bindings

    var phoneContacts: CurrentValueSubject<[ContactInformation], Never> = .init([])

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

    func fetchFacebookContacts() -> [String] {
        return []
    }

    func setAvailable(phoneContacts: [String]) {
        let availableContacts = userPhoneContacts.filter { item in
            phoneContacts.contains(item.phone)
        }
        availablePhoneContacts = availableContacts
        self.phoneContacts.send(availableContacts)
    }
}
