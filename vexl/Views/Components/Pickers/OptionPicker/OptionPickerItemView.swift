//
//  OptionPickerItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

struct OptionPickerItemView<Content: View>: View {

    let isSelected: Bool
    var useBackground = true
    var backgroundTint: Color?
    let content: () -> Content
    let action: () -> Void

    var foregroundColor: Color {
        isSelected
            ? Appearance.Colors.whiteText
            : Appearance.Colors.gray4
    }

    var backgroundColor: Color {
        if useBackground {
            if let color = backgroundTint {
                return color
            }
            return isSelected
                ? Appearance.Colors.gray2
                : Appearance.Colors.gray1
        } else {
            return Color.clear
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            content()
        }
        .padding(useBackground ? Appearance.GridGuide.padding : .zero)
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}
