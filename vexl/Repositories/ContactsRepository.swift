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
    func delete(contacts: [(ContactInformation, String)]) -> AnyPublisher<Void, Error>
    func getContacts(hashes: [String]) -> AnyPublisher<[ManagedContact], Error>
    func getCommonFriends(hashes: [String]) -> AnyPublisher<[ManagedContact], Error>
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

    func delete(contacts: [(ContactInformation, String)]) -> AnyPublisher<Void, Error> {
        persistence.delete(context: context) { [persistence] context -> [ManagedContact] in
            let hashes = contacts.map(\.1)
            let storedContacts = persistence.loadSyncroniously(type: ManagedContact.self,
                                                               context: context,
                                                               predicate: NSPredicate(format: "hmacHash in %@", hashes))
            return storedContacts
        }
    }

    func getContacts(hashes: [String]) -> AnyPublisher<[ManagedContact], Error> {
        loadContacts(with: hashes, predicate: "hmacHash contains[cd] %@")
    }

    func getCommonFriends(hashes: [String]) -> AnyPublisher<[ManagedContact], Error> {
        loadContacts(with: hashes, predicate: "hmacHash IN %@")
    }

    private func loadContacts(with hashes: [String], predicate: String) -> AnyPublisher<[ManagedContact], Error> {
        guard !hashes.isEmpty else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let context = persistence.viewContext
        let array = NSArray(array: hashes)
        return persistence.load(
            type: ManagedContact.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            predicate: NSPredicate(format: predicate, array)
        )
    }
}
