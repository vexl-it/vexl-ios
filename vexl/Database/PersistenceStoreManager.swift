//
//  PersistenceStoreManager.swift
//  vexl
//
//  Created by Adam Salih on 01.07.2022.
//

import Foundation
import CoreData
import Combine

protocol PersistenceStoreManagerType {

    var viewContext: NSManagedObjectContext { get }

    func newEditContext() -> NSManagedObjectContext
    func newBackgroundContext() -> NSManagedObjectContext

    func wipe() -> AnyPublisher<Void, Error>

    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error>
    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping (NSManagedObjectContext) -> [T]) -> AnyPublisher<[T], Error>

    func load<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate?
    ) -> AnyPublisher<[T], Error>

    func loadSyncroniously<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate?
    ) -> [T]

    func loadSyncroniously<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        objectID: NSManagedObjectID
    ) -> T?

    func update<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error>

    func delete<T: NSManagedObject>(context: NSManagedObjectContext, object: T) -> AnyPublisher<Void, Error>
    func delete<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping (NSManagedObjectContext) -> [T]) -> AnyPublisher<Void, Error>
}

// swiftlint:disable:next file_types_order
extension PersistenceStoreManagerType {
    func load<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor] = [],
        predicate: NSPredicate? = nil
    ) -> AnyPublisher<[T], Error> {
        load(type: type, context: context, sortDescriptors: sortDescriptors, predicate: predicate)
    }

    func loadSyncroniously<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor] = [],
        predicate: NSPredicate? = nil
    ) -> [T] {
        loadSyncroniously(type: type, context: context, sortDescriptors: sortDescriptors, predicate: predicate)
    }

    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error> {
        insert(context: context, provider: { [ provider($0) ] })
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }

    func delete<T: NSManagedObject>(context: NSManagedObjectContext, object: T) -> AnyPublisher<Void, Error> {
        delete(context: context, editor: { _ in [object] })
    }
}

final class PersistenceStoreManager: PersistenceStoreManagerType {

    let viewContext: NSManagedObjectContext

    private let primaryBackgroundContext: NSManagedObjectContext
    private let container = NSPersistentContainer(name: "VexlDataModel")

    init() {
        let primaryContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        primaryContext.persistentStoreCoordinator = container.persistentStoreCoordinator
        primaryBackgroundContext = primaryContext

        let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.parent = primaryBackgroundContext
        self.viewContext = viewContext
        loadPersistentStore()
    }

    private func loadPersistentStore() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }

    func newEditContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext
        return context
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = primaryBackgroundContext
        // TODO: synchronize background contexts when possible
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name.NSManagedObjectContextDidSave,
//            object: nil,
//            queue: nil,
//            using: { [context, weak viewContext, weak primaryBackgroundContext] notification in
//                guard let viewContext = viewContext,
//                    let primaryBackgroundContext = primaryBackgroundContext,
//                    let notificationContext = notification.object as? NSManagedObjectContext else {
//                    return
//                }
//                switch notificationContext {
//                case viewContext, primaryBackgroundContext:
//                    context.mergeChanges(fromContextDidSave: notification)
//                case context:
//                    viewContext.mergeChanges(fromContextDidSave: notification)
//                default:
//                    break
//                }
//            }
//        )
        return context
    }

    private func save(context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        Future { promise in
            var tmpContext: NSManagedObjectContext? = context
            var saveError: Error?
            while tmpContext != nil && saveError == nil {
                tmpContext?.performAndWait {
                    do {
                        try tmpContext?.save()
                        tmpContext = tmpContext?.parent
                    } catch {
                        tmpContext = nil
                        saveError = error
                    }
                }
            }
            if let saveError = saveError {
                promise(.failure(saveError))
            } else {
            promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func wipe() -> AnyPublisher<Void, Error> {
        let context = newEditContext()
        return Future<Void, Error> { [weak self] promise in
            guard let owner = self else {
                return
            }
            let users = owner.loadSyncroniously(type: ManagedUser.self, context: context)
            users.forEach(context.delete)
            let offers = owner.loadSyncroniously(type: ManagedOffer.self, context: context)
            offers.forEach(context.delete)
            let contacts = owner.loadSyncroniously(type: ManagedContact.self, context: context)
            contacts.forEach(context.delete)
            let syncItems = owner.loadSyncroniously(type: ManagedSyncItem.self, context: context)
            syncItems.forEach(context.delete)
            let groups = owner.loadSyncroniously(type: ManagedGroup.self, context: context)
            groups.forEach(context.delete)
            // The rest of entities will be removedy by cascading rule
            promise(.success(()))
        }
        .receive(on: RunLoop.main)
        .flatMapLatest(with: self) { owner, _ in
            owner.save(context: context)
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping(NSManagedObjectContext) -> [T]) -> AnyPublisher<[T], Error> {
        Future { promise in
            context.perform {
                let objects = provider(context)
                objects.forEach(context.insert)
                promise(.success(objects))
            }
        }
        .receive(on: RunLoop.main)
        .flatMapLatest(with: self) { (owner, objects: [T]) -> AnyPublisher<[T], Error> in
            owner.save(context: context)
                .map { objects }
                .eraseToAnyPublisher()
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func load<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor] = [],
        predicate: NSPredicate? = nil
    ) -> AnyPublisher<[T], Error> {
        guard let entity = T.entityName else {
            fatalError("Unknown entity")
        }
        return Future { promise in
            context.perform {
                let request = NSFetchRequest<T>(entityName: entity)
                request.predicate = predicate
                request.sortDescriptors = sortDescriptors
                do {
                    let results = try context.fetch(request)
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func loadSyncroniously<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate?
    ) -> [T] {
        guard let entity = T.entityName else {
            return []
        }
        let request = NSFetchRequest<T>(entityName: entity)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }

    func loadSyncroniously<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        objectID: NSManagedObjectID
    ) -> T? {
        guard let object = context.object(with: objectID) as? T else {
            return nil
        }
        return object
    }

    func update<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            context.perform {
                promise(.success(editor(context)))
            }
        }
        .receive(on: RunLoop.main)
        .flatMapLatest(with: self) { owner, objects in
            owner.save(context: context)
                .map { objects }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func delete<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping (NSManagedObjectContext) -> [T]) -> AnyPublisher<Void, Error> {
        Future { promise in
            context.perform {
                editor(context).forEach(context.delete)
                promise(.success(()))
            }
        }
        .receive(on: RunLoop.main)
        .flatMapLatest(with: self) { owner, objects in
            owner.save(context: context)
                .map { objects }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
