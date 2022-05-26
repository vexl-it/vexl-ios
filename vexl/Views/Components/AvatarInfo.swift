//
//  AvatarInfo.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import SwiftUI

struct AvatarInfo: View {
    let isAvatarWithOpacity: Bool
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            ZStack {
                Image(R.image.marketplace.defaultAvatar.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedAvatarSize)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)

                if isAvatarWithOpacity {
                    Appearance.Colors.gray1
                        .opacity(0.8)
                        .frame(size: Appearance.GridGuide.feedAvatarSize)
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }

            VStack(alignment: .leading) {
                Text(title)
                    .textStyle(.paragraphSmallSemiBold)
                    .foregroundColor(Appearance.Colors.whiteText)

                Text(subtitle)
                    .textStyle(.micro)
                    .foregroundColor(Appearance.Colors.gray4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG || DEVEL
struct AvatarInfoViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AvatarInfo(
                isAvatarWithOpacity: false,
                title: "My offer",
                subtitle: "Added 12. 7. 2022"
            )

            AvatarInfo(
                isAvatarWithOpacity: true,
                title: "Sully is selling",
                subtitle: "Friend of friend"
            )
        }
        .padding()
        .background(Color.black)
    }
}
#endif
