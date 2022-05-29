//
//  CloseButton.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct CloseButton: View {

    let dismissAction: () -> Void

    var body: some View {
        Button {
            dismissAction()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(Color.white)
                .frame(size: Appearance.GridGuide.baseButtonSize)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
