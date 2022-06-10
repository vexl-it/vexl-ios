//
//  BorderedTextField.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Combine
import Cleevio

struct BorderedTextField: View {

    let placeholder: String
    let textStyle: Appearance.TextStyle
    @Binding var text: String

    var body: some View {
        PlaceholderTextField(placeholder: placeholder, text: $text)
            .padding()
            .makeCorneredBorder(color: Appearance.Colors.gray3, borderWidth: 1)
            .textStyle(textStyle)
    }
}
