//
//  ChatImageBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatImageBubbleView: View {

    let image: Image
    let text: String?
    let style: ChatBubbleStyle

    var body: some View {
        ChatBubbleView(style: style) {
            VStack(alignment: .center,
                   spacing: .zero) {
                image
                    .resizable()
                    .frame(maxWidth: Appearance.GridGuide.chatImageSize.width,
                           maxHeight: Appearance.GridGuide.chatImageSize.height)
                    .cornerRadius(Appearance.GridGuide.containerCorner)
                    .padding(Appearance.GridGuide.point)

                if let text = text, !text.isEmpty {
                    Text(text)
                        .textStyle(.paragraphSmallMedium)
                        .padding(.horizontal, Appearance.GridGuide.tinyPadding)
                        .padding(.bottom, Appearance.GridGuide.point)
                        .frame(width: Appearance.GridGuide.chatImageSize.width,
                               alignment: style == .contact ? .leading : .trailing)
                }
            }
        }
    }
}

#if DEBUG || DEVEL

struct ChatImageBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
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
