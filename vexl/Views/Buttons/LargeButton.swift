//
//  LargeButton.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import SwiftUI

struct LargeButton<Content: View>: View {
    @Binding var isEnabled: Bool
    let backgroundColor: Color
    let content: () -> Content
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            content()
        }
        .frame(height: Appearance.GridGuide.largeButtonHeight)
        .frame(maxWidth: .infinity)
        .background(isEnabled ? backgroundColor : Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.point)
        .disabled(!isEnabled)
    }
}
