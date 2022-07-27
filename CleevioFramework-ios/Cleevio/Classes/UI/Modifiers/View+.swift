//
//  View+.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

extension View {
    public func asAnyView() -> AnyView {
        AnyView(self)
    }
}
