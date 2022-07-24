//
//  ManagedChat+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation

extension ManagedChat {

    var lastMessage: ManagedMessage? {
        messages?
            .sortedArray(
                using: [
                    NSSortDescriptor(key: "time", ascending: true)
                ]
            ).last as? ManagedMessage
    }
}
