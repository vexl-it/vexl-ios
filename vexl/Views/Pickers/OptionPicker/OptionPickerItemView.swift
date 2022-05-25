//
//  OptionPickerItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import SwiftUI

struct OptionPickerItemView<Content: View>: View {

    let isSelected: Bool
    let content: () -> Content
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            content()
        }
        .padding()
        .foregroundColor(isSelected ? Appearance.Colors.whiteText: Appearance.Colors.gray4)
        .background(isSelected ? Appearance.Colors.gray2 : Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
        .transaction { transaction in
            transaction.animation = .easeInOut(duration: 0.25)
        }
    }
}
