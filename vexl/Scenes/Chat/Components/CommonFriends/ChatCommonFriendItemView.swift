//
//  ChatMessageCommonFriendItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 1/06/22.
//

import SwiftUI

typealias ChatCommonFriendViewData = ChatCommonFriendItemView.ViewData

struct ChatCommonFriendItemView: View {

    let data: ViewData

    var body: some View {
        HStack {
            ContactAvatarView(image: data.avatar,
                              size: Appearance.GridGuide.mediumIconSize)

            VStack(alignment: .leading) {
                Text(data.title)
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.primaryText)

                if let subtitle = data.subtitle {
                    Text(subtitle)
                        .textStyle(.description)
                        .foregroundColor(Appearance.Colors.gray3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ChatCommonFriendItemView {

    struct ViewData: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let subtitle: String?
        let avatar: Data?

        static var stub: ViewData {
            .init(title: "Username", subtitle: "Description goes here", avatar: nil)
        }
    }
}

struct ChatMessageCommonFriendItemViewPreview: PreviewProvider {
    static var previews: some View {
        ChatCommonFriendItemView(data: .init(title: "Name goes here",
                                             subtitle: "Description goes here bla bla",
                                             avatar: nil))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
