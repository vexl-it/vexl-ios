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

    @Binding private var text: String
    private let placeholder: String
    private let isFirstResponder: Bool
    private let textColor: Color
    private let minHeight: CGFloat
    @DiffableState private var textEditorHeight: CGFloat = .zero
    
    private var height: CGFloat { max(minHeight, textEditorHeight) }
    

    init(placeholder: String,
         text: Binding<String>,
         isFirstResponder: Bool,
         minHeight: CGFloat = UIProperties.minHeight,
         textColor: Color = Appearance.Colors.gray3) {
        self.placeholder = placeholder
        self._text = text
        self.isFirstResponder = isFirstResponder
        self.minHeight = minHeight
        self.textColor = textColor
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
            
            TextView(text: $text,
                     textStyle: .paragraph,
                     textColor: UIColor(cgColor: textColor.cgColor!),
                     isFirstResponder: isFirstResponder)
            .frame(height: height, alignment: .bottom)
        }
        .offset(y: Appearance.GridGuide.tinyPadding)
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
               isFirstResponder: true,
               minHeight: Appearance.GridGuide.chatTextFieldHeight
           )
           .previewDisplayName("Small, Empty")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("Qwerty"),
               isFirstResponder: true,
               minHeight: 40
           )
           .previewDisplayName("Small, with text")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant(""),
               isFirstResponder: true
           )
           .previewDisplayName("Empty, inactive")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("ios@cleevio.com"),
               isFirstResponder: true
           )
           .previewDisplayName("Filled, inactive")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant("ios@cleeviocleeviocleeviocleeviocleevio.com"),
               isFirstResponder: true
           )
           .previewDisplayName("Filled, long text, inactive")

           ExpandingTextView(
               placeholder: "Email",
               text: .constant(""),
               isFirstResponder: true
           )
           .previewDisplayName("Empty, inactive")
       }
       .previewLayout(.sizeThatFits)
   }
}
#endif
