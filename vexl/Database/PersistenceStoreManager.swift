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

    func save(context: NSManagedObjectContext) -> AnyPublisher<Void, Error>
    func wipe() -> AnyPublisher<Void, Error>

    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error>
    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping (NSManagedObjectContext) -> [T]) -> AnyPublisher<[T], Error>

    func load<T: NSManagedObject>(
        type: T.Type,
        context: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate?
    ) -> AnyPublisher<[T], Error>

    func update<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping () -> T) -> AnyPublisher<T, Error>

    func delete<T: NSManagedObject>(context: NSManagedObjectContext, object: T) -> AnyPublisher<Void, Error>
    func delete<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping () -> [T]) -> AnyPublisher<Void, Error>
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

    func insert<T: NSManagedObject>(context: NSManagedObjectContext, provider: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error> {
        insert(context: context, provider: { [ provider($0) ] })
            .compactMap(\.first)
            .eraseToAnyPublisher()
    }

    func delete<T: NSManagedObject>(context: NSManagedObjectContext, object: T) -> AnyPublisher<Void, Error> {
        delete(context: context, editor: { [object] })
    }
}

class PersistenceStoreManager: PersistenceStoreManagerType {

    private let container = NSPersistentContainer(name: "VexlDataModel")

    private lazy var primaryBackgroundContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = container.persistentStoreCoordinator
        return context
    }()

    lazy var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = primaryBackgroundContext
        return context
    }()

    init() {
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
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil,
            queue: nil,
            using: { [weak context, weak viewContext] notification in
                guard let context = context, let viewContext = viewContext,
                    let notificationContext = notification.object as? NSManagedObjectContext else {
                    return
                }
                switch notificationContext {
                case viewContext:
                    context.mergeChanges(fromContextDidSave: notification)
                case context:
                    viewContext.mergeChanges(fromContextDidSave: notification)
                default:
                    break
                }
            }
        )
        return context
    }

    func save(context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        Future { promise in
            var tmpContext: NSManagedObjectContext? = context
            var saveError: Error?
            while tmpContext != nil && saveError != nil {
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
        primaryBackgroundContext
            .deleteAllData()
            .withUnretained(self)
            .flatMap { owner in
                owner.save(context: owner.primaryBackgroundContext)
            }
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
        .flatMapLatest(with: self) { owner, objects in
            owner.save(context: context)
                .map { objects }
        }
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
        .eraseToAnyPublisher()
    }

    func update<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping () -> T) -> AnyPublisher<T, Error> {
        Future { promise in
            context.perform {
                promise(.success(editor()))
            }
        }
        .flatMapLatest(with: self) { owner, objects in
            owner.save(context: context)
                .map { objects }
        }
        .eraseToAnyPublisher()
    }

    func delete<T: NSManagedObject>(context: NSManagedObjectContext, editor: @escaping () -> [T]) -> AnyPublisher<Void, Error> {
        Future { promise in
            context.perform {
                editor().forEach(context.delete)
                promise(.success(()))
            }
        }
        .flatMapLatest(with: self) { owner, objects in
            owner.save(context: context)
                .map { objects }
        }
        .eraseToAnyPublisher()
    }
}
