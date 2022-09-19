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
            .cornerRadius(Appearance.GridGuide.requestAvatarCorner)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: style == .contact ? .leading : .trailing)
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
            ChatTextBubbleView(text: "qwerty qwerty qwerty qwerty qwerty", style: .contact, urlHandler: { _ in })

            ChatTextBubbleView(text: "qwerty", style: .user, urlHandler: { _ in })

            ChatImageBubbleView(image: Image(uiImage: R.image.onboarding.testAvatar()!),
                                text: nil,
                                style: .contact)

            ChatImageBubbleView(image: Image(uiImage: R.image.onboarding.testAvatar()!),
                                text: nil,
                                style: .user)

            ChatImageBubbleView(image: Image(uiImage: R.image.onboarding.testAvatar()!),
                                text: "qwerty qwerty qwerty qwerty qwerty qwerty",
                                style: .contact)

            ChatImageBubbleView(image: Image(uiImage: R.image.onboarding.testAvatar()!),
                                text: "qwerty qwerty",
                                style: .user)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
