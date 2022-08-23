//
//  ChatIdentityRequestView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatRevealIdentityView: View {

    let image: Data?
    let isRequest: Bool

    private var title: String {
        isRequest ? L.chatMessageIdentityRevealRequestSent() : L.chatMessageIdentityRevealRequest()
    }

    private var subtitle: String {
        isRequest ? L.chatMessageIdentityRevealPending() : L.chatMessageIdentityRevealPendingTap()
    }

    var body: some View {
        VStack(spacing: .zero) {

            ContactAvatarView(image: image,
                              size: Appearance.GridGuide.chatRequestAvatarSize)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            HStack {

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                    .frame(maxWidth: .infinity)

                Text(L.chatMessageIdentityRevealHeader())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Appearance.Colors.gray3)
                    .textStyle(.description)
                    .padding(.bottom, Appearance.GridGuide.tinyPadding)
                    .frame(maxWidth: .infinity)

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                    .frame(maxWidth: .infinity)
            }

            Text(L.chatMessageIdentityRevealSubheader())
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.titleSmallSemiBold)
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)
        }
    }
}

#if DEBUG || DEVEL

struct ChatIdentityRequestViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatRevealIdentityView(image: R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1),
                                   isRequest: true)

            ChatRevealIdentityView(image: nil,
                                   isRequest: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
