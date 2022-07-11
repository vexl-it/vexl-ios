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

    private var displayImage: Image {
        if isAccepted {
            return avatarImage
        } else {
            return rejectImage
        }
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
            ChatRevealIdentityResponseView(username: "Username",
                                           avatarImage: Image(data: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1), placeholder: ""),
                                           rejectImage: Image(data: R.image.chat.rejectReveal()!.jpegData(compressionQuality: 1), placeholder: ""),
                                           isAccepted: true)

            ChatRevealIdentityResponseView(username: "Username",
                                           avatarImage: Image(data: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1), placeholder: ""),
                                           rejectImage: Image(data: R.image.chat.rejectReveal()!.jpegData(compressionQuality: 1), placeholder: ""),
                                           isAccepted: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
