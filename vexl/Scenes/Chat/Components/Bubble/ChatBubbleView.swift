//
//  ChatContactBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatBubbleView<Content: View>: View {

    let style: ChatBubbleStyle
    let content: () -> Content

    var body: some View {
        content()
            .foregroundColor(style.textColor)
            .background(style.backgroundColor)
            .cornerRadius(Appearance.GridGuide.requestCorner)
            .frame(maxWidth: .infinity, alignment: style == .contact ? .leading : .trailing)
            .frame(minHeight: 40)
    }
}

enum ChatBubbleStyle {
    case contact
    case user

    var backgroundColor: Color {
        switch self {
        case .contact:
            return Appearance.Colors.gray1
        case .user:
            return Appearance.Colors.yellow100
        }
    }

    var textColor: Color {
        switch self {
        case .contact:
            return Appearance.Colors.whiteText
        case .user:
            return Appearance.Colors.primaryText
        }
    }

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .contact:
            return .leading
        case .user:
            return .trailing
        }
    }

    var alignment: Alignment {
        switch self {
        case .contact:
            return .leading
        case .user:
            return .trailing
        }
    }
}

#if DEBUG || DEVEL

struct ChatBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatTextBubbleView(text: "qwerty qwerty qwerty qwerty qwerty", style: .contact)

            ChatTextBubbleView(text: "qwerty", style: .user)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                                text: nil,
                                style: .contact)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                                text: nil,
                                style: .user)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                                text: "qwerty qwerty qwerty qwerty qwerty qwerty",
                                style: .contact)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                                text: "qwerty qwerty",
                                style: .user)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
