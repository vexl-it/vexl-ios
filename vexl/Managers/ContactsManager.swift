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

struct ImportContactItem: Identifiable {
    var id: String
    var name: String
    var phone: String
    var avatar: Data?
    var avatarURL: String?
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

    // MARK: - Properties

    private var userPhoneContacts: [ImportContactItem] = []
    private(set) var availablePhoneContacts: [ImportContactItem] = []

    private var userFacebookContacts: [ImportContactItem] = []
    private(set) var availableFacebookContacts: [ImportContactItem] = []

    func fetchPhoneContacts() -> [ImportContactItem] {
        var contacts = [ImportContactItem]()
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
            self.userPhoneContacts = contacts
            return contacts
        } catch {
            self.userPhoneContacts = []
            return []
        }
    }

    func fetchFacebookContacts() -> AnyPublisher<[ImportContactItem], Error> {
        AnyPublisher(Future { [weak self] promise in

            guard AccessToken.current != nil else {
                promise(.failure(UserError.facebookAccess))
                return
            }

            let params = ["fields": "id, name, picture"]
            self?.userFacebookContacts = []

            let request = GraphRequest(graphPath: "me/friends", parameters: params, httpMethod: .get)
            request.start { _, result, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    guard let dictonary = result as? [String: Any],
                          let data = dictonary["data"] as? [[String: Any]] else {
                              promise(.failure(UserError.fetchFacebookFriends))
                              return
                    }

                    var contacts = [ImportContactItem]()

                    for item in data {
                        guard let name = item["name"] as? String,
                              let id = item["id"] as? String else {
                                  continue
                              }

                        let pictureData = item["data"] as? [String: Any]
                        let pictureURL = pictureData?["url"] as? String
                        let contact = ImportContactItem(id: id, name: name, phone: "", avatarURL: pictureURL)
                        contacts.append(contact)
                    }

                    promise(.success(contacts))
                    self?.userFacebookContacts = contacts
                }
            }
        })
    }

    func setAvailable(phoneContacts: [String]) {
        let availableContacts = userPhoneContacts.filter { phoneContacts.contains($0.phone) }
        availablePhoneContacts = availableContacts
    }

    func setFacebookFriendsWithApp(contacts: [String]) {
        let filteredContacts = userFacebookContacts.filter { contacts.contains($0.id) }
        userFacebookContacts = filteredContacts
    }

    func setAvailable(facebookContacts: [String]) {
        let availableContacts = userFacebookContacts.filter { facebookContacts.contains($0.id) }
        availableFacebookContacts = availableContacts
    }
}
