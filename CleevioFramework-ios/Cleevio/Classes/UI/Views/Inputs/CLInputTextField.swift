//
//  InputTextField.swift
//  Cleevio
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

public struct CLInputTextField: View {
    
    private let tintColor: Color
    private let textColor: Color
    private let textFont: Font
    
    @ObservedObject var viewModel: ViewModel

    public init(viewModel: ViewModel,
                tintColor: Color = Color(.systemBlue),
                textColor: Color = Color(.label),
                textFont: Font) {
        self.viewModel = viewModel
        self.tintColor = tintColor
        self.textFont = textFont
        self.textColor = textColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.placeholder)
                .font(Font.caption)
                .foregroundColor(textColor)
            TextField("", text: $viewModel.inputText, onEditingChanged: { value in
                viewModel.isActive = value
            })
            .font(textFont)
            .foregroundColor(textColor)
            .accentColor(tintColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .makeCorneredBorder(color: viewModel.isActive ? tintColor : tintColor.opacity(0.3))
    }
}

extension CLInputTextField {
    public class ViewModel: ObservableObject {
        let placeholder: String
        @Binding var inputText: String
        @Binding var isActive: Bool

        public init(placeholder: String, inputText: Binding<String>, isActive: Binding<Bool> = .constant(false)) {
            self.placeholder = placeholder
            self._inputText = inputText
            self._isActive = isActive
        }
    }
}
