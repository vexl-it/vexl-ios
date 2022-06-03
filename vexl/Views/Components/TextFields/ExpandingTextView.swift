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
        static let topPlaceholderPadding: CGFloat = 8
        static let minHeight: CGFloat = 150
    }

    let placeholder: String
    @Binding var text: String
    @State private var textEditorHeight: CGFloat = .zero
    private let minHeight: CGFloat
    private let textColor: Color

    init(placeholder: String,
         text: Binding<String>,
         height: CGFloat? = nil,
         textColor: Color? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = height ?? UIProperties.minHeight
        self.textColor = textColor ?? Appearance.Colors.gray3
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                smallPlaceholder
                    .padding([.bottom, .horizontal], UIProperties.placeholderPadding)
                    .padding(.top, UIProperties.topPlaceholderPadding)
            }

            Text(text)
                .textStyle(.paragraph)
                .foregroundColor(.clear)
                .readSize { size in
                    textEditorHeight = size.height
                }

            TextEditor(text: $text)
                .textStyle(.paragraph)
                .foregroundColor(textColor)
                .frame(height: max(minHeight, textEditorHeight))
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
               text: .constant(""),
               height: 40
           )
           .previewDisplayName("Small, Empty")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("Qwerty"),
               height: 40
           )
           .previewDisplayName("Small, with text")

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
