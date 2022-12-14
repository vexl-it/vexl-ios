//
//  PhoneContactsManager.swift
//  vexl
//
//  Created by Diego Espinoza on 27/03/22.
//

import Foundation
import Combine
import Contacts
import FBSDKCoreKit
import FBSDKLoginKit

protocol PhoneContactsManagerType {
    var availableFacebookContacts: [ContactInformation] { get }

    func fetchPhoneContacts() -> AnyPublisher<[ContactInformation], Never>
    func getUserPhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error>

    func fetchFacebookContacts(id: String, accessToken: String) -> AnyPublisher<[ContactInformation], Error>
    func getActiveFacebookContacts(_ contacts: [String], withId id: String, token: String) -> AnyPublisher<[ContactInformation], Error>
}

final class PhoneContactsManager: PhoneContactsManagerType {

    @Inject var contactsService: ContactsServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var encryptionService: EncryptionServiceType
    @Inject var userRepository: UserRepositoryType

    // MARK: - Properties

    private var userPhoneContacts: [ContactInformation] = []

    private var userFacebookContacts: [ContactInformation] = []
    private(set) var availableFacebookContacts: [ContactInformation] = []
    private(set) var privateQueue = DispatchQueue(label: "PhoneContactsQueue")

    func fetchPhoneContacts() -> AnyPublisher<[ContactInformation], Never> {
        userRepository.userPublisher
            .compactMap { $0?.profile?.phoneNumber?.removeWhitespaces() }
            .first()
            .withUnretained(self)
            .flatMap { owner, userPhone in
                owner.fetchContactsButFilter(userPhone: userPhone)
            }
            .eraseToAnyPublisher()
    }

    private func fetchContactsButFilter(userPhone: String) -> AnyPublisher<[ContactInformation], Never> {
        Future { [weak self] promise in
            guard let owner = self else {
                promise(.success([]))
                return
            }
            owner.privateQueue.async {
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
                        for phone in contact.phoneNumbers.map(\.value.stringValue) {
                            guard !userPhone.contains(phone.removeWhitespaces()) else {
                                return
                            }

                            let avatar = contact.imageData
                            let userContact = ContactInformation(id: UUID().uuidString,
                                                                 name: "\(contact.givenName) \(contact.familyName)",
                                                                 phone: phone,
                                                                 avatar: avatar,
                                                                 source: .phone)
                            contacts.append(userContact)
                        }
                    }
                    owner.userPhoneContacts = contacts
                    promise(.success(contacts))
                } catch {
                    owner.userPhoneContacts = []
                    promise(.success([]))
                }
            }
        }
        .eraseToAnyPublisher()
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

    func getUserPhoneContacts(_ contacts: [String]) -> AnyPublisher<[ContactInformation], Error> {
        guard !contacts.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return contactsService
            .getActivePhoneContacts(contacts)
            .map(\.newContacts)
            .withUnretained(self)
            .flatMap { owner, hashedAvailableContacts -> AnyPublisher<[ContactInformation], Error> in
                owner.encryptionService.hashContacts(contacts: owner.userPhoneContacts)
                    .map { hashedContacts -> [ContactInformation] in
                        hashedContacts.map { contact in
                            let isSelected = !hashedAvailableContacts.contains(contact.1)
                            var newContact = contact.0
                            newContact.isSelected = isSelected
                            newContact.isStored = isSelected
                            return newContact
                        }
                        .sorted(by: { $0.name < $1.name })
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // TODO: - Update how facebook contacts work once the contacts can be fetched.

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
