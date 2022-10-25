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
    func getProfile(publicKey: String) -> ManagedAnonymousProfile?
}

final class AnonymousProfileRepository: AnonymousProfileRepositoryType {
    @Inject private var persistenceManager: PersistenceStoreManagerType

    func saveNewContacts(envelope: ContactPKsEnvelope) -> AnyPublisher<Void, Error> {
        let context = persistenceManager.viewContext
        let firstDegree = getProfileType(context: context, type: .firstDegree)
        let secondDegree = getProfileType(context: context, type: .secondDegree)
        return persistenceManager.insert(context: context) { [weak self] context -> [ManagedAnonymousProfile] in
            envelope.hashMap.compactMap { publicKey, friendLevels -> ManagedAnonymousProfile? in
                let predicate = NSPredicate(format: "publicKey == '\(publicKey)'")
                let profile = self?.persistenceManager.loadSyncroniously(
                    type: ManagedAnonymousProfile.self,
                    context: context,
                    predicate: predicate
                ).first
                let types = friendLevels.compactMap { level in
                    switch level {
                    case .firstDegree:
                        return firstDegree
                    case .secondDegree:
                        return secondDegree
                    case .group:
                        return nil
                    }
                }
                if let profile {
                    types.forEach(profile.addToTypes)
                    return nil
                } else {
                    let profile = ManagedAnonymousProfile(context: context)
                    profile.publicKey = publicKey
                    types.forEach(profile.addToTypes)
                    return profile
                }
            }
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

    func getProfile(publicKey: String) -> ManagedAnonymousProfile? {
        let context = persistenceManager.viewContext
        let predicate = NSPredicate(format: "publicKey == '\(publicKey)'")
        return persistenceManager.loadSyncroniously(type: ManagedAnonymousProfile.self, context: context, predicate: predicate).first
    }
}
