//
//  ChatRevealIdentityResponseView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/07/22.
//

import SwiftUI

struct ChatRevealIdentityResponseView: View {

    let username: String
    let avatarImage: Image
    let rejectImage: Image
    let isAccepted: Bool
    let isRecevinng: Bool

    private var displayImage: Image {
        if isAccepted {
            return avatarImage
        } else {
            return rejectImage
        }
    }

    var title: String {
        isAccepted
            ? username
            : isRecevinng
                ? L.chatMessageIdentityRevealRejectReceived()
                : L.chatMessageIdentityRevealReject()
    }

    var body: some View {
        VStack {
            displayImage
                .resizable()
                .frame(size: Appearance.GridGuide.chatRequestAvatarSize)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
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

            Text(title)
                .foregroundColor(Appearance.Colors.whiteText)
                .textStyle(.titleSmallSemiBold)
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)
        }
    }
}

#if DEBUG || DEVEL

struct ChatRevealIdentityResponseViewPreview: PreviewProvider {
    static var previews: some View {

        let image = R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1)

        VStack {
            ChatRevealIdentityResponseView(username: "Username",
                                           avatarImage: Image(data: image, placeholder: ""),
                                           rejectImage: Image(data: image, placeholder: ""),
                                           isAccepted: true, isRecevinng: false)

            ChatRevealIdentityResponseView(username: "Username",
                                           avatarImage: Image(data: image, placeholder: ""),
                                           rejectImage: Image(data: image, placeholder: ""),
                                           isAccepted: false, isRecevinng: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
