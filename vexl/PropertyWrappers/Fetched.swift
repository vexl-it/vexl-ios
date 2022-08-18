//
//  Fetched.swift
//  vexl
//
//  Created by Adam Salih on 04.07.2022.
//

import Foundation
import CoreData
import Combine
import Cleevio

enum FetchContextType {
    case view
    case background
    case edit
}

enum PublishEvent {
    case insert
    case delete
    case change
    case move
    case loaded
}

typealias FetchEvent<T: NSManagedObject> = (event: PublishEvent, objects: [T])

@propertyWrapper
final class Fetched<Entity: NSManagedObject> {
    let context: NSManagedObjectContext

    var publisher: AnyPublisher<FetchEvent<Entity>, Never> {
        currentValue
            .filterNil()
            .eraseToAnyPublisher()
    }

    var wrappedValue: [Entity] {
        currentValue.value?.objects ?? []
    }

    var projectedValue: Fetched<Entity> {
        self
    }

    private let currentValue: CurrentValueSubject<FetchEvent<Entity>?, Never> = .init(nil)

    private var controller: NSFetchedResultsController<Entity>?
    private var fetchDelegate: FetchedResultsControllerDelegate<Entity>!
    private var cancelBag: CancelBag = .init()
    private var currentSortDescriptors: [NSSortDescriptor]
    private var currentPredicate: NSPredicate?

    init(
        fetchImmediately: Bool = true,
        contextType: FetchContextType = .view,
        sortDescriptors: [NSSortDescriptor] = [],
        predicate: NSPredicate? = nil
    ) {
        @Inject var persistence: PersistenceStoreManagerType
        currentSortDescriptors = sortDescriptors
        currentPredicate = predicate

        context = {
            switch contextType {
            case .view:
                return persistence.viewContext
            case .background:
                return persistence.newBackgroundContext()
            case .edit:
                return persistence.newEditContext()
            }
        }()

        if fetchImmediately {
            load()
        }
    }

    func load(
        sortDescriptors: [NSSortDescriptor]? = nil,
        predicate: NSPredicate? = nil
    ) {
        guard let entity = Entity.entityName else {
            fatalError("Unknown entity")
        }

        if let sortDescriptors = sortDescriptors {
            self.currentSortDescriptors = sortDescriptors
        }

        if let predicate = predicate {
            self.currentPredicate = predicate
        }

        let request = NSFetchRequest<Entity>(entityName: entity)
        request.predicate = currentPredicate
        request.sortDescriptors = currentSortDescriptors

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.controller = controller

        fetchDelegate = FetchedResultsControllerDelegate { [weak self] event in
            self?.currentValue.send(event)
        }

        do {
            try controller.performFetch()
            let objects = controller.fetchedObjects ?? []
            currentValue.send((.loaded, objects))
        } catch {
            currentValue.send((.loaded, []))
        }

        controller.delegate = fetchDelegate
    }
}

class FetchedResultsControllerDelegate<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {

    var publishHandler: (FetchEvent<Entity>) -> Void

    init(_ publishHandler: @escaping (FetchEvent<Entity>) -> Void) {
        self.publishHandler = publishHandler
        super.init()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let fetchedObjects = controller.fetchedObjects as? [Entity] else {
            return
        }
        switch type {
        case .insert:
            publishHandler((.insert, fetchedObjects))
        case .delete:
            publishHandler((.delete, fetchedObjects))
        case .move:
            publishHandler((.move, fetchedObjects))
        case .update:
            publishHandler((.change, fetchedObjects))
        @unknown default:
            break
        }
    }
}
