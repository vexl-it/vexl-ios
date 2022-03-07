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
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .makeCorneredBorder(color: Appearance.Colors.gray3, borderWidth: 1)
    }
}
