//
//  ContactAvatarInfo.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import SwiftUI

struct ContactAvatarInfo: View {

    enum Style {
        case regular
        case large
    }

    let isAvatarWithOpacity: Bool
    let title: String
    let subtitle: String
    let style: Style

    private var avatarSize: CGSize {
        style == .regular ? Appearance.GridGuide.feedAvatarSize : Appearance.GridGuide.feedLargeAvatarSize
    }

    private var titleStyle: Appearance.TextStyle {
        style == .regular ? .paragraphSmallSemiBold : .titleSmallSemiBold
    }

    private var subtitleStyle: Appearance.TextStyle {
        style == .regular ? .micro : .paragraphSmallSemiBold
    }

    init(isAvatarWithOpacity: Bool,
         title: String,
         subtitle: String,
         style: Style = .regular) {
        self.isAvatarWithOpacity = isAvatarWithOpacity
        self.title = title
        self.subtitle = subtitle
        self.style = style
    }

    var body: some View {
        HStack {
            ZStack {
                Image(R.image.marketplace.defaultAvatar.name)
                    .resizable()
                    .frame(size: avatarSize)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)

                if isAvatarWithOpacity {
                    Appearance.Colors.gray1
                        .opacity(0.8)
                        .frame(size: avatarSize)
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }

            VStack(alignment: .leading) {
                Text(title)
                    .textStyle(titleStyle)
                    .foregroundColor(Appearance.Colors.whiteText)

                Text(subtitle)
                    .textStyle(subtitleStyle)
                    .foregroundColor(Appearance.Colors.gray4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG || DEVEL
struct ContactAvatarInfoViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ContactAvatarInfo(
                isAvatarWithOpacity: false,
                title: "My offer",
                subtitle: "Added 12. 7. 2022"
            )

            ContactAvatarInfo(
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
