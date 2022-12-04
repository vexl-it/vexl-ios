//
//  ChatUserLeftView.swift
//  vexl
//
//  Created by Adam Salih on 02.12.2022.
//

import SwiftUI

struct ChatUserLeftView: View {

    let username: String
    let avatarImage: Image

    var body: some View {
        VStack {
            avatarImage
                .resizable()
                .scaledToFill()
                .frame(size: Appearance.GridGuide.chatRequestAvatarSize)
                .clipped()
                .cornerRadius(Appearance.GridGuide.buttonCorner)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            HStack {
                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                .frame(maxWidth: .infinity)

                Text(L.chatDeleteTitle(username))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Appearance.Colors.gray3)
                    .textStyle(.description)
                    .padding(.bottom, Appearance.GridGuide.tinyPadding)
                    .frame(maxWidth: .infinity)

                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#if DEBUG || DEVEL

struct ChatUserLeftViewPreview: PreviewProvider {
    static var previews: some View {

        let image = R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 1)

        VStack {
            ChatUserLeftView(username: "Username",
                             avatarImage: Image(data: image, placeholder: ""))

            ChatUserLeftView(username: "Username",
                             avatarImage: Image(data: image, placeholder: ""))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
