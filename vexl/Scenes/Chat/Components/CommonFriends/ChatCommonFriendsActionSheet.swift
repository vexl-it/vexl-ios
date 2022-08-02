//
//  ChatCommonFriendsActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 1/08/22.
//

import SwiftUI
import Combine

final class ChatCommonFriendsSheetViewModel: BottomActionSheetViewModelProtocol {

    typealias CommonFriendBottomActionSheet = BottomActionSheet<ChatCommonFriendsActionSheetContent>

    var title: String = L.chatMessageCommonFriend()
    var primaryAction: CommonFriendBottomActionSheet.Action = .init(title: L.buttonGotIt(), isDismissAction: true)
    var secondaryAction: CommonFriendBottomActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: CommonFriendBottomActionSheet.ColorScheme = .main
    var content: ChatCommonFriendsActionSheetContent {
        ChatCommonFriendsActionSheetContent(friends: commonFriends)
    }

    private var commonFriends: [ChatCommonFriendViewData]

    init(contacts: [ManagedContact]) {
        self.commonFriends = contacts.compactMap { contact in
            guard let name = contact.name else {
                return nil
            }

            return ChatCommonFriendViewData(title: name,
                                            subtitle: contact.phoneNumber,
                                            avatar: contact.avatar)
        }
    }
}

struct ChatCommonFriendsActionSheetContent: View {

    let friends: [ChatCommonFriendViewData]

    var body: some View {
        ChatCommonFriendsView(friends: friends,
                              dismiss: {})
            .background(Appearance.Colors.gray6)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .padding(.bottom, Appearance.GridGuide.point)
    }
}

#if DEBUG || DEVEL
struct ChatCommonFriendsSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatCommonFriendsActionSheetContent(friends: [.stub, .stub])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
