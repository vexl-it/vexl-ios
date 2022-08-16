//
//  ManagedSyncItem+.swift
//  vexl
//
//  Created by Adam Salih on 10.07.2022.
//

import Foundation
import CoreData

enum SyncType: Int {
    case update
    case insert
    case offerEncryptionUpdate
}

extension ManagedSyncItem {

    var type: SyncType? {
        get { SyncType(rawValue: Int(typeRawType)) }
        set {
            guard let intValue = newValue?.rawValue else {
                return
            }
            typeRawType = Int64(intValue)
        }
    }
}
