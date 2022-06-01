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

            SolidButton(Text(L.buttonGotIt()),
                        iconImage: nil,
                        isEnabled: .constant(true),
                        isLoading: .constant(false),
                        fullWidth: true,
                        loadingViewScale: 1,
                        font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                        colors: .main,
                        dimensions: .largeButton,
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
