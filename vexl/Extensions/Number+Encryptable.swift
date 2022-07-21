//
//  Number+Encryptable.swift
//  vexl
//
//  Created by Adam Salih on 11.07.2022.
//

import Foundation

extension Double: Encryptable {
    var asString: String { "\(self)" }
}

extension Int: Encryptable {
    var asString: String { "\(self)" }
}
