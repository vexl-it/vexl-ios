//
//  CLTextField.swift
//
//  Created by Daniel Fernandez on 11/11/20.
//

import SwiftUI

public struct CLTextField: View {
    var text: Binding<String>
    var placeholder: String
    var type: TextFieldType
    var disableAutocorrection: Bool
    var lineColor: Color = Color("Carbon_100")
    let textFieldHeight: CGFloat = 32

    public init(placeholder: String, text: Binding<String>, type: TextFieldType, disableAutocorrection: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.type = type
        self.disableAutocorrection = disableAutocorrection
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(placeholder)
                    .opacity(text.wrappedValue.isEmpty ? 0 : 1)
                    .offset(y: text.wrappedValue.isEmpty ? textFieldHeight : 0)
                    .animation(.default)

                Group {
                    if type == .password {
                        SecureTextField(placeholder: placeholder, text: text)
                    } else {
                        TextField(placeholder, text: text)
                    }
                }
                .frame(height: textFieldHeight)
                .disableAutocorrection(disableAutocorrection)
                .autocapitalization(type.autocapitalizationType)
                .keyboardType(type.keyboardType)
                .textContentType(type.textContentType)
                .disabled(type == .disabled)

            }

            Divider()
                .frame(height: 1)
                .background(lineColor)
        }
    }
}

struct SecureTextField: View {
    var placeholder: String
    @Binding var text: String
    @State private var shouldShowText: Bool = false

    var body: some View {
        HStack {
            if shouldShowText {
                TextField(placeholder, text: $text)
            } else {
                SecureField(placeholder, text: $text)
            }
            Button {
                self.shouldShowText.toggle()
            } label: {
                Image(systemName: shouldShowText ? "eye" : "eye.slash")
                    .renderingMode(.template)
                    .foregroundColor(Color("Carbon_100"))
            }
        }
    }
}

#if DEBUG
struct ClTextField_Previews : PreviewProvider {
    @State static var value = ""

    static var previews: some View {
        CLTextField(placeholder: "Here is some placeholder",
                    text: $value,
                    type: .default)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
