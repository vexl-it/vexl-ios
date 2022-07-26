//
//  ContactsRepository.swift
//  vexl
//
//  Created by Adam Salih on 08.07.2022.
//

import Foundation
import Combine
import CoreData

protocol ContactsRepositoryType {
    func save(contacts: [(ContactInformation, String)]) -> AnyPublisher<[ManagedContact], Error>
    func getContacts(hashes: [String]) -> AnyPublisher<[ManagedContact], Error>
}

final class ContactsRepository: ContactsRepositoryType {
    @Inject private var persistence: PersistenceStoreManagerType

    private lazy var context: NSManagedObjectContext = persistence.viewContext

    func save(contacts: [(ContactInformation, String)]) -> AnyPublisher<[ManagedContact], Error> {
        persistence.insert(context: context) { context in
            contacts.map { contact, hash in
                let managedContact = ManagedContact(context: context)
                managedContact.hmacHash = hash
                managedContact.id = contact.id
                managedContact.name = contact.name
                managedContact.phoneNumber = contact.phone
                managedContact.avatar = contact.avatar
                managedContact.avatarURL = contact.avatarURL
                managedContact.sourceRawType = contact.source.rawValue
                return managedContact
            }
        }
    }

    func getContacts(hashes: [String]) -> AnyPublisher<[ManagedContact], Error> {
        guard !hashes.isEmpty else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let context = persistence.viewContext
        let array = NSArray(array: hashes)
        return persistence.load(
            type: ManagedContact.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            predicate: NSPredicate(format: "hmacHash contains[cd] %@", array)
        )
    }
}
