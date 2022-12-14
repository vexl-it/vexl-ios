//
//  ChatMessageActionView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

typealias ChatActionOption = ChatActionView.ChatActionOption

struct ChatActionView: View {

    @ObservedObject var viewModel: ChatActionViewModel

    private var availableActions: [ChatActionOption] {
        var actions = ChatActionOption.allCases

        if !viewModel.showIdentityRequest {
            actions = actions.filter { $0 != .revealIdentity }
        }

        if viewModel.isChatBlocked {
            actions = actions.filter { $0 != .blockUser }
        }

        if viewModel.isOfferDeleted {
            actions = actions.filter { $0 != .showOffer && $0 != .commonFriends  }
        }

        return actions
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(availableActions) { chatAction in
                    Button(viewModel.title(for: chatAction)) {
                        viewModel.action.send(chatAction)
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

    enum ChatActionOption: Identifiable, Hashable, CaseIterable {

        var id: ChatActionOption { self }

        case revealIdentity
        case showOffer
        case commonFriends
        case deleteChat
        case blockUser

    }
}
