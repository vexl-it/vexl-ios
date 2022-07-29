//
//  ViewWidth.swift
//  CleevioUI
//
//  Created by Diego on 10/01/22.
//

import Foundation
import SwiftUI

struct ViewWidthModifier: ViewModifier {
    let fullWidth: Bool

    func body(content: Content) -> some View {
        switch fullWidth {
        case true:
            return AnyView(
                content
                    .frame(minWidth: 0, maxWidth: .infinity)
            )
        case false:
            return AnyView(content)
        }
    }
}
