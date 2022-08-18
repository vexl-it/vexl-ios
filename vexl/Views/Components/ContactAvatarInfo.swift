//
//  ContactAvatarInfo.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import SwiftUI

struct ContactAvatarInfo: View {

    enum TitleType {
        case normal(String)
        case attributed(NSAttributedString)
    }

    enum Style {
        case regular
        case large
    }

    let avatar: Data?
    let isAvatarWithOpacity: Bool
    let titleType: TitleType
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
         titleType: TitleType,
         subtitle: String,
         style: Style = .regular,
         avatar: Data? = nil) {
        self.isAvatarWithOpacity = isAvatarWithOpacity
        self.titleType = titleType
        self.subtitle = subtitle
        self.style = style
        self.avatar = avatar
    }

    var body: some View {
        HStack {
            ZStack {
                ContactAvatarView(image: avatar,
                                  size: avatarSize)

                if isAvatarWithOpacity {
                    Appearance.Colors.gray1
                        .opacity(0.8)
                        .frame(size: avatarSize)
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }

            VStack(alignment: .leading) {
                switch titleType {
                case .normal(let title):
                    Text(title)
                        .textStyle(titleStyle)
                        .foregroundColor(Appearance.Colors.whiteText)
                case .attributed(let attributedTitle):
                    AttributedText(attributedText: attributedTitle)
                }

                Text(subtitle)
                    .textStyle(subtitleStyle)
                    .foregroundColor(Appearance.Colors.gray4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ContactAvatarInfoViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ContactAvatarInfo(
                isAvatarWithOpacity: false,
                titleType: .normal("My offer"),
                subtitle: "Added 12. 7. 2022"
            )

            ContactAvatarInfo(
                isAvatarWithOpacity: true,
                titleType: .normal("Sully is selling"),
                subtitle: "Friend of friend"
            )
        }
        .padding()
        .background(Color.black)
    }
}
