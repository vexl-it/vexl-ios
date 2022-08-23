//
//  ManagedSyncItem+.swift
//  vexl
//
//  Created by Adam Salih on 10.07.2022.
//

import Foundation
import CoreData

enum SyncQueueItemType: Int {
    case offerUpdate
    case offerCreate
    case offerEncryptionUpdate
}

extension ManagedSyncItem {

    var type: SyncQueueItemType? {
        get { SyncQueueItemType(rawValue: Int(typeRawType)) }
        set {
            guard let intValue = newValue?.rawValue else {
                return
            }
            typeRawType = Int64(intValue)
        }
    }
}
