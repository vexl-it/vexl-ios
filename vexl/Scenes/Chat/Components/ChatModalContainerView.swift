//
//  ChatModalContainerView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/06/22.
//

import SwiftUI

struct ChatModalContainerView: View {

    let modal: ChatViewModel.Modal
    let commonFriends: [ChatCommonFriendViewData]
    let action: (ChatViewModel.UserAction) -> Void

    var body: some View {
        switch modal {
        case .offer:
            offerView
        case .friends:
            commonFriendView
        case .delete:
            deleteView
        case .deleteConfirmation:
            deleteConfirmationView
        case .block:
            blockView
        case .blockConfirmation:
            blockConfirmationView
        case .identityRevealRequest:
            identityRevealRequestView
        case .identityRevealConfirmation:
            identityRevealConfirmationView
        case .none:
            EmptyView()
        }
    }

    private var offerView: some View {
        ChatOfferView {
            withAnimation {
                action(.dismissModal)
            }
        }
    }

    private var commonFriendView: some View {
        ChatCommonFriendsView(friends: commonFriends) {
            withAnimation {
                action(.dismissModal)
            }
        }
    }

    private var deleteView: some View {
        ChatDeleteConfirmationView(style: .regular,
                                   mainAction: {
            withAnimation {
                action(.deleteTap)
            }
        },
                                   dismiss: {
            withAnimation {
                action(.dismissModal)
            }
        })
    }

    private var deleteConfirmationView: some View {
        ChatDeleteConfirmationView(style: .confirmation,
                                   mainAction: {
            withAnimation {
                action(.deleteConfirmedTap)
            }
        },
                                   dismiss: {
            withAnimation {
                action(.dismissModal)
            }
        })
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

    private var identityRevealRequestView: some View {
        ChatRevealConfirmationView(isRequest: true ,
                                   mainAction: {
            withAnimation {
                action(.revealRequestConfirmationTap)
            }
        },
                                   dismiss: {
            withAnimation {
                action(.dismissModal)
            }
        })
    }

    private var identityRevealConfirmationView: some View {
        ChatRevealConfirmationView(isRequest: false ,
                                   mainAction: {
            withAnimation {
                action(.revealResponseConfirmationTap)
            }
        },
                                   dismiss: {
            withAnimation {
                action(.dismissModal)
            }
        })
    }
}
