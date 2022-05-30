//
//  ChatMessageView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

typealias ChatMessageGroup = ChatMessageView.MessageGroup
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

            messageInput
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

                    Text(" is Buying")
                        .foregroundColor(Appearance.Colors.whiteText)
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

    private var messageInput: some View {
        HStack {
            Button("Image") {
                print("will show image picker")
            }

            HStack {
                PlaceholderTextField(placeholder: "Type something",
                                     textColor: Appearance.Colors.gray4,
                                     text: $viewModel.currentMessage)

                Button("send") {
                    print("will send message")
                }
            }
            .padding()
            .frame(height: Appearance.GridGuide.chatTextFieldHeight)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.chatTextFieldHeight * 0.5)
        }
        .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
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
                return ".revealIdentityTap"
            case .showOffer:
                return ".showOfferTap"
            case .commonFriends:
                return ".commonFriendTap"
            case .deleteChat:
                return ".deleteChatTap"
            case .blockUser:
                return ".blockUserTap"
            }
        }
    }

    struct MessageGroup: Identifiable, Hashable {
        let id = UUID()
        let date: Date
        let messages: [Message]

        // swiftlint: disable nesting
        struct Message: Identifiable, Hashable {
            let id = UUID()
            let text: String
            let isContact: Bool
        }

        static var stub: [MessageGroup] {
            [
                .init(date: Date(), messages: [
                    .init(text: "Hello there", isContact: true),
                    .init(text: "General Kenobi", isContact: false)
                ]),
                .init(date: Date(), messages: [
                    .init(text: "Haha you are a bold one", isContact: false)
                ])
            ]
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
