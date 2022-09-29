//
//  PublicKeysEnvelope.swift
//  vexl
//
//  Created by Adam Salih on 29.09.2022.
//

import Foundation

struct ContactPKsEnvelope {
    var firstDegree: [String]
    var secondDegree: [String]

    func publicKeys(for type: AnonymousProfileType) -> [String] {
        switch type {
        case .firstDegree:
            return firstDegree
        case .secondDegree:
            return secondDegree
        case .group:
            return []
        }
    }
}

struct GroupPKsEnvelope {
    var group: ManagedGroup
    var publicKeys: [String]
}
