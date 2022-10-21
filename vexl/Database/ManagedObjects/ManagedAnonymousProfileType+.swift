//
//  ManagedAnonymousProfileType+.swift
//  vexl
//
//  Created by Adam Salih on 21.09.2022.
//

import Foundation

enum AnonymousProfileType: String {
    case firstDegree = "FIRST_DEGREE"
    case secondDegree = "SECOND_DEGREE"
    case group = "GROUP"

    var asOfferFriendDegree: OfferFriendDegree? {
        switch self {
        case .firstDegree:
            return .firstDegree
        case .secondDegree:
            return .secondDegree
        case .group:
            return nil
        }
    }
}

extension ManagedAnonymousProfileType {
    var type: AnonymousProfileType? {
        get { rawType.flatMap(AnonymousProfileType.init) }
        set { rawType = newValue?.rawValue }
    }
}
