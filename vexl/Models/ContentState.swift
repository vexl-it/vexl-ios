//
//  ContentState.swift
//  vexl
//
//  Created by Adam Salih on 20.06.2022.
//

import Foundation

enum ContentState<Data> {
    case content(Data)
    case loading
    case error(Error)

    var data: Data? {
        if case let .content(data) = self {
            return data
        }
        return nil
    }
}

extension ContentState: Equatable {
    static func == (lhs: ContentState<Data>, rhs: ContentState<Data>) -> Bool {
        switch (lhs, rhs) {
        case (.content, .content):
            return true
        case (.loading, .loading):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
