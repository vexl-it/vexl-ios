//
//  ManagedGroup+.swift
//  vexl
//
//  Created by Adam Salih on 13.08.2022.
//

import SwiftUI

extension ManagedGroup {
    var color: Color {
        hexColor
            .flatMap { Color(hex: $0) }
            ?? Appearance.Colors.gray2
    }
}
