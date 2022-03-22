//
//  PlaceholderTextView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/03/22.
//

import Foundation
import SwiftUI

struct PlaceholderTextView: View {

    @Binding var text: String
    var placeholder: String

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
