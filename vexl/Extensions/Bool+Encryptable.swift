//
//  Bool+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 07.07.2022.
//

import Foundation

extension Bool: Encryptable {
    var asString: String { self ? "true" : "false" }
}
