//
//  DottedButton.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct DottedButton<Content: View>: View {

    let color: Color
    let content: () -> Content
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            content()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: Appearance.GridGuide.buttonCorner)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                .foregroundColor(color)
        )
        .padding(Appearance.GridGuide.point)
    }
}
