//
//  CloseButton.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct CloseButton: View {

    private let textColor: Color
    private let backgroundColor: Color
    let dismissAction: () -> Void

    init(textColor: Color = Appearance.Colors.whiteText,
         backgroundColor: Color = Appearance.Colors.gray1,
         dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        Button {
            dismissAction()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(textColor)
                .frame(size: Appearance.GridGuide.baseButtonSize)
                .background(backgroundColor)
                .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
