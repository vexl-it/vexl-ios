//
//  NSManagedObjectContext+.swift
//  vexl
//
//  Created by Adam Salih on 06.07.2022.
//

import Foundation
import CoreData
import Combine

extension NSManagedObjectContext {
    func deleteAllData() -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let persistentStore = self?.persistentStoreCoordinator?.persistentStores.last else {
                promise(.failure(PersistenceError.wipeError))
                return
            }

            guard let url = self?.persistentStoreCoordinator?.url(for: persistentStore) else {
                promise(.failure(PersistenceError.wipeError))
                return
            }

            self?.performAndWait { [weak self] () -> Void in
                self?.reset()
                do {
                    try self?.persistentStoreCoordinator?.remove(persistentStore)
                    try FileManager.default.removeItem(at: url)
                    try self?.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
                    promise(.success(()))
                } catch {
                    promise(.failure(PersistenceError.wipeError))
                }
            }
        }.eraseToAnyPublisher()
    }
}
