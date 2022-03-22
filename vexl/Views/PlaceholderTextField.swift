//
//  PlaceholderTextField.swift
//  vexl
//
//  Created by Diego Espinoza on 22/03/22.
//

import Foundation
import SwiftUI

struct PlaceholderTextField: View {

    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Appearance.Colors.gray2)
            }

            TextField("", text: $text)
                .foregroundColor(Appearance.Colors.primaryText)
        }
    }
}
