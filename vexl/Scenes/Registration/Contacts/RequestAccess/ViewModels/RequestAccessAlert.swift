//
//  RequestAccessAlert.swift
//  vexl
//
//  Created by Diego Espinoza on 15/03/22.
//

import Foundation

struct RequestAccessContactsAlertType: Identifiable {
    var id: Int
    var title: String
    var message: String

    static var request: RequestAccessContactsAlertType {
        .init(id: 1, title: L.registerPhoneAlertRequestTitle(), message: L.registerPhoneAlertRequestDescription())
    }

    static var reject: RequestAccessContactsAlertType {
        .init(id: 2, title: L.registerPhoneAlertRejectTitle(), message: L.registerPhoneAlertRejectDescription())
    }
}
