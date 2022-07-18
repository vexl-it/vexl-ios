//
//  Bool+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 07.07.2022.
//

import Foundation

extension Bool {
    /// returns "true" and "false" as string
    var string: String { "\(self)" }

    init?(_ value: String) {
        guard let val = [true, false].first(where: { $0.string == value }) else {
            return nil
        }
        self = val
    }
}
