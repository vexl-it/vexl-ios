//
//  ManagedMessage+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation

extension ManagedMessage {
    var type: MessageType {
        get { typeRawType.flatMap(MessageType.init) ?? .invalid }
        set { typeRawType = newValue.rawValue }
    }

    var contentType: ContentType {
        get { contentTypeRawType.flatMap(ContentType.init) ?? .none }
        set { contentTypeRawType = newValue.rawValue }
    }

    var date: Date {
        get { Date(timeIntervalSince1970: time) }
        set { time = newValue.timeIntervalSince1970 }
    }

    var formatedDate: String {
        Formatters.chatDateFormatter.string(from: date)
    }
}
