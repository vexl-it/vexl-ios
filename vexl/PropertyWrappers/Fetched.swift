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
        currentValue.eraseToAnyPublisher()
    }

    var wrappedValue: [Entity] {
        currentValue.value.objects
    }

    var projectedValue: Fetched<Entity> {
        self
    }

    private let currentValue: CurrentValueSubject<FetchEvent<Entity>, Never>

    private let controller: NSFetchedResultsController<Entity>
    private var fetchDelegate: FetchedResultsControllerDelegate<Entity>!
    private var cancelBag: CancelBag = .init()

    init(
        contextType: FetchContextType = .view,
        sortDescriptors: [NSSortDescriptor] = [],
        predicate: NSPredicate? = nil
    ) {
        @Inject var persistence: PersistenceStoreManagerType

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

        guard let entity = Entity.entityName else {
            fatalError("Unknown entity")
        }
        let request = NSFetchRequest<Entity>(entityName: entity)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.controller = controller

        let objects: [Entity] = {
            do {
                try controller.performFetch()
                return controller.fetchedObjects ?? []
            } catch {
                return []
            }
        }()
        currentValue = .init((.loaded, objects))

        fetchDelegate = FetchedResultsControllerDelegate { [weak self] event in
            self?.currentValue.send(event)
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
            publishHandler((.change, fetchedObjects))
        case .update:
            publishHandler((.insert, fetchedObjects))
        @unknown default:
            break
        }
    }
}
