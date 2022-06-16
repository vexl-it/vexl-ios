//
//  ChatImageBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatImageBubbleView: View {

    let image: Data?
    let text: String?
    let style: ChatBubbleStyle

    var body: some View {
        ChatBubbleView(style: style) {
            VStack(alignment: .center,
                   spacing: .zero) {
                Image(data: image, placeholder: "")
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
