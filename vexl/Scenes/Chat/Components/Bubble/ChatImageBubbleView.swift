//
//  ChatImageBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatImageBubbleView: View {

    let image: UIImage
    let text: String?
    let style: ChatBubbleStyle

    var body: some View {
        ChatBubbleView(style: style) {
            VStack(alignment: style == .contact ? .leading : .trailing,
                   spacing: .zero) {
                Image(uiImage: image)
                    .resizable()
                    .frame(maxWidth: Appearance.GridGuide.chatImageSize.width,
                           maxHeight: Appearance.GridGuide.chatImageSize.height)
                    .padding(Appearance.GridGuide.smallPadding)

                if let text = text {
                    Text(text)
                        .textStyle(.paragraphSmallMedium)
                        .padding(Appearance.GridGuide.smallPadding)
                }
            }
        }
    }
}

#if DEBUG || DEVEL

struct ChatImageBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!,
                                text: nil,
                                style: .contact)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!,
                                text: nil,
                                style: .user)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!,
                                text: "qwerty qwerty qwerty qwerty qwerty ",
                                style: .contact)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!,
                                text: "qwerty qwerty qwerty qwerty qwerty",
                                style: .user)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
