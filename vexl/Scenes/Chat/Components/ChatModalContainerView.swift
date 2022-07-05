//
//  ChatModalContainerView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/06/22.
//

import SwiftUI

struct ChatModalContainerView: View {

    let modal: ChatViewModel.Modal
    let offerDetailViewData: OfferDetailViewData?
    let commonFriends: [ChatCommonFriendViewData]
    let action: (ChatViewModel.UserAction) -> Void

    var body: some View {
        switch modal {
        case .friends:
            commonFriendView
        case .block:
            blockView
        case .blockConfirmation:
            blockConfirmationView
        case .none:
            EmptyView()
        }
    }

    private var commonFriendView: some View {
        ChatCommonFriendsView(friends: commonFriends) {
            withAnimation {
                action(.dismissModal)
            }
        }
    }

    private var blockView: some View {
        ChatBlockConfirmationView(style: .regular,
                                  mainAction: {
            withAnimation {
                action(.blockTap)
            }
        },
                                  dismiss: {
            withAnimation {
                action(.dismissModal)
            }
        })
    }

    private var blockConfirmationView: some View {
        ChatBlockConfirmationView(style: .confirmation,
                                  mainAction: {
            withAnimation {
                action(.blockConfirmedTap)
            }
        },
                                  dismiss: {
            withAnimation {
                action(.dismissModal)
            }
        })
    }
}
