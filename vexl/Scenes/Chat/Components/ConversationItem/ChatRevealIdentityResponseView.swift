//
//  ChatRevealIdentityResponseView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/07/22.
//

import SwiftUI

struct ChatRevealIdentityResponseView: View {

    let username: String = ""
    let image: Data?
    let isAccepted: Bool

    private var displayImage: Data? {
        if isAccepted {
            if let image = image {
                return image
            } else {
                return R.image.marketplace.defaultAvatar()?.jpegData(compressionQuality: 1)
            }
        } else {
            return R.image.chat.rejectReveal()?.jpegData(compressionQuality: 1)
        }
    }

    var body: some View {
        VStack {
            ContactAvatarView(image: displayImage,
                              size: Appearance.GridGuide.chatRequestAvatarSize)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            HStack {

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                    .frame(maxWidth: .infinity)

                Text(isAccepted ? L.chatMessageIdentityRevealApproved() : L.chatMessageIdentityRevealHeader())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Appearance.Colors.gray3)
                    .textStyle(.description)
                    .padding(.bottom, Appearance.GridGuide.tinyPadding)
                    .frame(maxWidth: .infinity)

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                    .frame(maxWidth: .infinity)
            }

            Text(isAccepted ? username : L.chatMessageIdentityRevealReject())
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.titleSmallSemiBold)
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)
        }
    }
}

#if DEBUG || DEVEL

struct ChatRevealIdentityResponseViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatRevealIdentityResponseView(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1),
                                           isAccepted: true)

            ChatRevealIdentityResponseView(image: nil,
                                           isAccepted: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
