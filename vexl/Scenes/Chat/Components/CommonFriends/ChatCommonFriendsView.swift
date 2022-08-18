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
        ScrollView {
            LazyVStack {
                ForEach(friends) { friend in
                    ChatCommonFriendItemView(data: friend)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.35)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Appearance.Colors.whiteText)
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
