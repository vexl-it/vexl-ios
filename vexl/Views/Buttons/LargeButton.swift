//
//  LargeButton.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import SwiftUI

struct LargeButton: View {

    let title: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(TextStyle.h3.asFont)
                .foregroundColor(isEnabled ? ColorGuide.primaryText : ColorGuide.gray2)
        }
        .frame(height: GridGuide.largeButtonHeight)
        .frame(maxWidth: .infinity)
        .background(isEnabled ? color : ColorGuide.gray1)
        .cornerRadius(GridGuide.point)
        .disabled(!isEnabled)
    }
}
