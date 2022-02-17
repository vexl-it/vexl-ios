//
//  LargeButton.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import SwiftUI

struct LargeButton: View {

    let title: String
    let backgroundColor: Color
    var foregroundColor: Color = Appearance.Colors.primaryText
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(Appearance.TextStyle.h3.asFont)
                .foregroundColor(isEnabled ? foregroundColor : Appearance.Colors.gray2)
        }
        .frame(height: Appearance.GridGuide.largeButtonHeight)
        .frame(maxWidth: .infinity)
        .background(isEnabled ? backgroundColor : Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.point)
        .disabled(!isEnabled)
    }
}
