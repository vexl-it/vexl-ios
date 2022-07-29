//
//  CorneredBorder.swift
//  Cleevio
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

public struct CorneredBorderModifier: ViewModifier {
    private let borderWidth: CGFloat
    private let cornerRadius: CGFloat
    private let borderColor: Color

    public init(
        color: Color,
        borderWidth: CGFloat = 2,
        cornerRadius: CGFloat = 8
    ) {
        self.borderColor = color
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

extension View {
    public func makeCorneredBorder(
        color: Color,
        borderWidth: CGFloat = 2,
        cornerRadius: CGFloat = 8
    ) -> some View {
        modifier(CorneredBorderModifier(color: color, borderWidth: borderWidth, cornerRadius: cornerRadius))
    }
}
