//
//  ManagedInbox+.swift
//  
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation

extension ManagedInbox {
    var type: ChatInbox.InboxType? {
        get { typeRawValue.flatMap(ChatInbox.InboxType.init) }
        set { typeRawValue = newValue?.rawValue }
    }
}
