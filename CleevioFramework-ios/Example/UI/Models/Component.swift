//
//  Component.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import Foundation

struct Component: Identifiable {
    let id: Identifier
    let name: String
    let author: String
}

extension Component {
    enum Identifier {
        case mapScene
        case pinCode
        case passwordValidation
        case phoneNumberScene
        case oneTimePassword
    }
}

extension Component {
    static let mockedData: [Component] = [
        Component(id: .mapScene, name: "Map Scene", author: "Jakub Truhlář"),
        Component(id: .pinCode, name: "PIN code scene", author: "Petr Škorňok"),
        Component(id: .passwordValidation, name: "Password validation scene", author: "Daniel Fernandez"),
        Component(id: .phoneNumberScene, name: "Phone number scene", author: "Thành Đỗ Long"),
        Component(id: .oneTimePassword, name: "One time password scene", author: "Martin Vidovič")
    ]
}
