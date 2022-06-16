//
//  ChatTextBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatTextBubbleView: View {

    let text: String
    let style: ChatBubbleStyle

    var body: some View {
        ChatBubbleView(style: style) {
            Text(text)
                .textStyle(.paragraphSmallMedium)
                .padding(Appearance.GridGuide.smallPadding)
        }
    }
}

#if DEBUG || DEVEL

struct ChatTextBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatTextBubbleView(text: "qwerty qwerty qwerty qwerty ", style: .contact)

            ChatTextBubbleView(text: "qwerty qwerty qwerty qwerty", style: .user)
        }
        .frame(maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")

        VStack {
            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                                text: nil,
                                style: .contact)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                                text: nil,
                                style: .user)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
