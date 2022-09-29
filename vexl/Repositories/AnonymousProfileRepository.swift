//
//  AnonymousProfileRepository.swift
//  vexl
//
//  Created by Adam Salih on 21.09.2022.
//

import Foundation
import Combine
import CoreData

protocol AnonymousProfileRepositoryType {
    func saveNewContacts(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error>
    func getProfileType(context: NSManagedObjectContext, type: AnonymousProfileType) -> ManagedAnonymousProfileType
    func getProfiles(publicKeys: [String], type: AnonymousProfileType, context: NSManagedObjectContext?) -> [ManagedAnonymousProfile]
}

final class AnonymousProfileRepository: AnonymousProfileRepositoryType {
    @Inject var persistenceManager: PersistenceStoreManagerType

    func saveNewContacts(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error> {
        persistenceManager.insert(context: persistenceManager.viewContext) { [weak self] context -> [ManagedAnonymousProfile] in
            [AnonymousProfileType.firstDegree, .secondDegree]
                .compactMap { [weak self] type -> (AnonymousProfileType, ManagedAnonymousProfileType)? in
                    guard let managedType = self?.getProfileType(context: context, type: type) else {
                        return nil
                    }
                    return (type, managedType)
                }
                .map { type, managedType in
                    envelope
                        .publicKeys(for: type)
                        .map { publicKey -> ManagedAnonymousProfile in
                            let profile = ManagedAnonymousProfile(context: context)
                            profile.publicKey = publicKey
                            profile.addToTypes(managedType)
                            return profile
                        }
                }
                .reduce([ManagedAnonymousProfile](), +)
        }
        .asVoid()
        .eraseToAnyPublisher()
    }

    func getProfileType(context: NSManagedObjectContext, type: AnonymousProfileType) -> ManagedAnonymousProfileType {
        guard let entity = ManagedAnonymousProfileType.entityName else {
            fatalError("Unknown entity")
        }
        let predicate = NSPredicate(format: "rawType == '\(type.rawValue)'")

        let request = NSFetchRequest<ManagedAnonymousProfileType>(entityName: entity)
        request.predicate = predicate

        let objects = (try? context.fetch(request)) ?? []

        if let type = objects.first {
            return type
        }

        let profileType = ManagedAnonymousProfileType(context: context)
        profileType.type = type

        return profileType
    }

    func getProfiles(publicKeys: [String], type: AnonymousProfileType, context: NSManagedObjectContext?) -> [ManagedAnonymousProfile] {
        let context = context ?? persistenceManager.viewContext
        let nsArray = NSArray(array: publicKeys)
        let predicate = NSPredicate(format: "publicKey IN %@ AND ANY types.rawType == '\(type.rawValue)'", nsArray)
        return persistenceManager.loadSyncroniously(type: ManagedAnonymousProfile.self, context: context, predicate: predicate)
    }
}
