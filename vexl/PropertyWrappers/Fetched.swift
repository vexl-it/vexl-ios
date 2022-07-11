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

@propertyWrapper
final class Fetched<Entity: NSManagedObject> {
    let context: NSManagedObjectContext

    var publisher: AnyPublisher<[Entity], Never> {
        fetchDelegate.publisher.eraseToAnyPublisher()
    }

    var wrappedValue: [Entity] {
        fetchDelegate.publisher.value
    }

    var projectedValue: Fetched<Entity> {
        self
    }

    private let controller: NSFetchedResultsController<Entity>
    private let fetchDelegate: FetchedResultsControllerDelegate<Entity>
    private var cancelBag: CancelBag = .init()

    init(contextType: FetchContextType = .view, sortDescriptors: [NSSortDescriptor] = [], predicate: NSPredicate? = nil) {
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

        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try controller.performFetch()
            let objects = controller.fetchedObjects ?? []
            fetchDelegate = .init(objects)
        } catch {
            fetchDelegate = .init([])
        }

        controller.delegate = fetchDelegate
    }
}

class FetchedResultsControllerDelegate<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {

    var publisher: CurrentValueSubject<[Entity], Never>

    init(_ entities: [Entity]) {
        publisher = .init(entities)
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
        publisher.send(fetchedObjects)
    }
}
