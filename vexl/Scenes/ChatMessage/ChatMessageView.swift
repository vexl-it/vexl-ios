//
//  ChatMessageView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

typealias ChatMessageAction = ChatMessageView.ChatAction

struct ChatMessageView: View {

    @ObservedObject var viewModel: ChatMessageViewModel

    var body: some View {
        VStack(spacing: .zero) {
            header

            HLine(color: Appearance.Colors.whiteOpaque, height: 1)
                .padding(.top, Appearance.GridGuide.smallPadding)

            actions

            messages
                .frame(maxHeight: .infinity)

            ChatMessageInputView(text: $viewModel.currentMessage,
                                 sendAction: {
                viewModel.action.send(.messageSend)
            },
                                 cameraAction: {
                viewModel.action.send(.cameraTap)
            })
                .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var header: some View {
        HStack(spacing: .zero) {
            CloseButton {
                viewModel.action.send(.dismissTap)
            }

            VStack {
                ContactAvatarView(image: nil,
                                  size: Appearance.GridGuide.chatAvatarSize)

                HStack(spacing: .zero) {
                    Text(viewModel.username)
                        .foregroundColor(Appearance.Colors.whiteText)

                    Text(viewModel.offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell(""))
                        .foregroundColor(viewModel.offerType == .buy ? Appearance.Colors.green100 : Appearance.Colors.pink100)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.trailing, Appearance.GridGuide.baseButtonSize.width * 0.5)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }

    private var actions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(ChatAction.allCases) { action in
                    Button(action.title) {
                        viewModel.action.send(.chatActionTap(action: action))
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

    private var messages: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(viewModel.messages) { messageGroup in
                    ChatMessageDateView(date: messageGroup.date, isInitial: false)

                    ForEach(messageGroup.messages) { message in
                        ChatMessageBubbleView(text: message.text, style: message.isContact ? .contact : .user)
                    }
                }
            }
            .padding(.top, Appearance.GridGuide.padding)
        }
        .padding([.horizontal, .top], Appearance.GridGuide.point)
    }
}

extension ChatMessageView {

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

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
