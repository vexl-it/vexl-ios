//
//  ChatMessageActionView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

typealias ChatAction = ChatActionView.ChatAction

struct ChatActionView: View {

    let userIsRevealed: Bool
    let action: (ChatAction) -> Void

    private var availableActions: [ChatAction] {
        if userIsRevealed {
            return ChatAction.allCases.filter { $0 != .revealIdentity }
        } else {
            return ChatAction.allCases
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(availableActions) { chatAction in
                    Button(chatAction.title) {
                        action(chatAction)
                    }
                    .textStyle(.paragraphSmallMedium)
                    .padding(Appearance.GridGuide.point)
                    .background(Appearance.Colors.gray1)
                    .foregroundColor(Appearance.Colors.gray4)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }
        }
        .padding(.top, Appearance.GridGuide.smallPadding)
    }
}

extension ChatActionView {

    enum ChatAction: Identifiable, Hashable, CaseIterable {

        var id: ChatAction { self }

        case revealIdentity
        case showOffer
        case commonFriends
        case deleteChat
        case blockUser

        var title: String {
            switch self {
            case .revealIdentity:
                return L.chatMessageRevealIdentity()
            case .showOffer:
                return L.chatMessageOffer()
            case .commonFriends:
                return L.chatMessageCommonFriend()
            case .deleteChat:
                return L.chatMessageDeleteChat()
            case .blockUser:
                return L.chatMessageBlockUser()
            }
        }
    }
}
