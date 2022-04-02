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

final class ContactsManager {

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

    func fetchFacebookContacts() -> AnyPublisher<[ContactInformation], Error> {
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

                    var contacts = [ContactInformation]()

                    for item in data {
                        guard let name = item["name"] as? String,
                              let id = item["id"] as? String else {
                                  continue
                              }

                        let pictureData = item["data"] as? [String: Any]
                        let pictureURL = pictureData?["url"] as? String
                        let contact = ContactInformation(id: id, name: name, phone: "", avatarURL: pictureURL, source: .facebook)
                        contacts.append(contact)
                    }

                    promise(.success(contacts))
                    self?.userFacebookContacts = contacts
                }
            }
        })
    }

    func setAvailable(phoneContacts: [String]) {
        let availableContacts = userPhoneContacts.filter { phoneContacts.contains($0.sourceIdentifier) }
        availablePhoneContacts = availableContacts
    }

    func setFacebookFriendsWithApp(contacts: [String]) {
        let filteredContacts = userFacebookContacts.filter { contacts.contains($0.sourceIdentifier) }
        userFacebookContacts = filteredContacts
    }

    func setAvailable(facebookContacts: [String]) {
        let availableContacts = userFacebookContacts.filter { facebookContacts.contains($0.sourceIdentifier) }
        availableFacebookContacts = availableContacts
    }
}
