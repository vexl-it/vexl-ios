//
//  Bool+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 07.07.2022.
//

import Foundation

extension Bool {
    var string: String { self ? "true" : "false" }

    init?(_ value: String) {
        if value == "true" {
            self = true
        } else if value == "false" {
            self = false
        } else {
            return nil
        }
    }
}
