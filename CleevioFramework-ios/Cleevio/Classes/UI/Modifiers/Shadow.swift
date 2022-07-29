//
//  Shadow.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

extension View {
    public func withShadow(opacity: Double = 0.1, radius: CGFloat = 24, x: CGFloat = 0, y: CGFloat = 7) -> some View {
        self.shadow(color: Color.black.opacity(opacity), radius: radius, x: x, y: y)
    }
}
