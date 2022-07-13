//
//  TimeInterval+.swift
//  vexl
//
//  Created by Diego Espinoza on 13/07/22.
//

import Foundation

extension TimeInterval {
    var seconds: Int {
        return Int(self.rounded())
    }

    var milliseconds: Int {
        return Int(self * 1_000)
    }
}
