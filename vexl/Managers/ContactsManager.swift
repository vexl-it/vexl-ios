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

protocol ContactsManangerType {
    var contacts: CurrentValueSubject<ContactsManager.Content, Never> { get set }
}

final class ContactsManager: ContactsManangerType {

    enum Content: Equatable {
        case loading
        case empty
        case content(items: [ImportContactItem])

        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.empty, .empty):
                return true
            case (.content, content):
                return true
            default:
                return false
            }
        }
    }

    var contacts: CurrentValueSubject<Content, Never> = .init(.loading)

    func fetchPhoneContacts() {
        var contacts = [ImportContactItem]()
        //let fullName = CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
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
                let userContact = ImportContactItem(id: contact.identifier,
                                                    name: "\(contact.givenName) \(contact.familyName)",
                                                    phone: phone,
                                                    avatar: avatar)
                contacts.append(userContact)
            }
            self.contacts.send(.content(items: contacts))
        } catch {
            self.contacts.send(.empty)
        }
    }
}
