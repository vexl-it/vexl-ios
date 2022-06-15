//
//  ChatImageBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatImageBubbleView: View {

    let image: UIImage
    let style: ChatBubbleStyle

    var body: some View {
        ChatBubbleView(style: style) {
            Image(uiImage: image)
                .resizable()
                .frame(maxWidth: Appearance.GridGuide.chatImageFrame.width,
                       maxHeight: Appearance.GridGuide.chatImageFrame.height)
                .padding(Appearance.GridGuide.smallPadding)
        }
    }
}

#if DEBUG || DEVEL

struct ChatImageBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!,
                                style: .contact)

            ChatImageBubbleView(image: R.image.onboarding.testAvatar()!,
                                style: .user)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
