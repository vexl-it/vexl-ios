//
//  ChatMessageCommonFriendsView.swift
//  vexl
//
//  Created by Diego Espinoza on 1/06/22.
//

import SwiftUI
import Cleevio

struct ChatMessageCommonFriendsView: View {

    let dismiss: () -> Void
    private let screenHeight: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(L.chatMessageCommonFriend())
                    .textStyle(.h2)
                    .padding(.top, Appearance.GridGuide.mediumPadding1)

                ScrollView {
                    ChatMessageCommonFriendItemView(title: "Hello there",
                                                    subtitle: "General Kenobi")
                }
                .frame(height: screenHeight * 0.5)
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
                             action: {
                dismiss()
            })
        }
        .padding(Appearance.GridGuide.point)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

struct ChatMessageCommonFriendsViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageCommonFriendsView(dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
