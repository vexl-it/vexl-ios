//
//  ChatCommonFriendsView.swift
//  vexl
//
//  Created by Diego Espinoza on 1/06/22.
//

import SwiftUI
import Cleevio

struct ChatCommonFriendsView: View {

    let friends: [ChatCommonFriendViewData]
    let dismiss: () -> Void

    var body: some View {
        GeometryReader { reader in
            VStack {
                VStack(alignment: .leading) {
                    Text(L.chatMessageCommonFriend())
                        .textStyle(.h2)
                        .padding(.top, Appearance.GridGuide.mediumPadding1)

                    ScrollView {
                        LazyVStack {
                            ForEach(friends) { friend in
                                ChatCommonFriendItemView(data: friend)
                            }
                        }
                    }
                    .frame(height: reader.size.height * 0.5)
                }
                .padding(.horizontal, Appearance.GridGuide.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Appearance.Colors.whiteText)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

                LargeSolidButton(title: L.buttonGotIt(),
                                 font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                                 style: .main,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: dismiss)
            }
            .padding(Appearance.GridGuide.point)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct ChatMessageCommonFriendsViewPreview: PreviewProvider {
    static var previews: some View {
        ChatCommonFriendsView(friends: [.stub, .stub],
                              dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
