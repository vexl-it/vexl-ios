//
//  CLPhoneNumberField.swift
//  CleevioUI
//
//  Created by Thành Đỗ Long on 01.12.2020.
//

import SwiftUI

public struct CLPhoneNumberField: View {
    var text: Binding<String>
    var placeholder: String
    var type: TextFieldType
    var disableAutocorrection: Bool

    public init(placeholder: String, text: Binding<String>, disableAutocorrection: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.type = .telephoneNumber
        self.disableAutocorrection = disableAutocorrection
    }

    public var body: some View {
        CLTextField(placeholder: placeholder,
                    text: text,
                    type: type,
                    disableAutocorrection: disableAutocorrection)
    }
}

#if DEBUG
struct CLPhoneNumberField_Previews: PreviewProvider {
    @State static var value = ""

    static var previews: some View {
        CLPhoneNumberField(placeholder: "Fill in your phone number", text: $value)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
