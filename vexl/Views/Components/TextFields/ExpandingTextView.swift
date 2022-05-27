//
//  ExpandingTextView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import SwiftUI

struct ExpandingTextView: View {
    private enum UIProperties {
        static let cornerRadius: CGFloat = 8
        static let placeholderPadding: CGFloat = 6
        static let minHeight: CGFloat = 150
    }

    let placeholder: String
    @Binding var text: String
    @State private var textEditorHeight: CGFloat = .zero

    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                smallPlaceholder
                    .padding(UIProperties.placeholderPadding)
            }

            Text(text)
                .textStyle(.paragraph)
                .foregroundColor(.clear)
                .readSize { size in
                    textEditorHeight = size.height
                }

            TextEditor(text: $text)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray3)
                .frame(height: max(UIProperties.minHeight, textEditorHeight))
        }
        .background(Appearance.Colors.gray1)
        .cornerRadius(UIProperties.cornerRadius)
    }

    private var smallPlaceholder: some View {
        Text(placeholder)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
    }
}

#if DEBUG
struct MainTextView_Previews: PreviewProvider {
   static var previews: some View {
       Group {
           ExpandingTextView(
               placeholder: "Email",
               text: .constant("")
           )
           .previewDisplayName("Empty, inactive")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("ios@cleevio.com")
           )
           .previewDisplayName("Filled, inactive")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("ios@cleeviocleeviocleeviocleeviocleevio.com")
           )
           .previewDisplayName("Filled, long text, inactive")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("")
           )
           .previewDisplayName("Empty, inactive")
       }
       .previewLayout(.sizeThatFits)
   }
}
#endif
