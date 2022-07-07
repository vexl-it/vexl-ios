//
//  NSManagedObject+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation
import CoreData

extension NSManagedObject {
    class var entityName: String? { self.entity().name }

    convenience init(context: NSManagedObjectContext) {
        guard let name = Self.entityName, let description = NSEntityDescription.entity(forEntityName: name, in: context) else {
            fatalError("Invalid entity decscription") // This is a developer error
        }
        self.init(entity: description, insertInto: context)
    }
}
