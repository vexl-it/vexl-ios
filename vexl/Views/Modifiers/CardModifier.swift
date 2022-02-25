//
//  CardModifier.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
    var backgroundColor: Color = Color.white
    var shadowEnabled: Bool = true
    var shadowColor: Color = Color.black
    var corners: UIRectCorner = .allCorners
    var cornerRadius: CGFloat = Appearance.GridGuide.padding

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius, corners: corners)
            .shadow(color: shadowColor.opacity(shadowEnabled ? 0.05 : 0),
                    radius: Appearance.GridGuide.point,
                    x: 0,
                    y: 4)
    }
}
